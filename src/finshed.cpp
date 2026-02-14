#include <Arduino.h>
#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLEServer.h>
#include <BLE2902.h>

// --- HARDWARE CONFIG ---
const int TRIG_PIN = 21;
const int ECHO_PIN = 22;

// Button
const int Butt_PIN = 12;

// --- BLUETOOTH CONFIG ---
#define SERVICE_UUID        "1234abcd-0000-1000-8000-00805f9b34fb"
#define CHARACTERISTIC_UUID "1234abcd-0001-1000-8000-00805f9b34fb"

BLECharacteristic *pCharacteristic;
bool deviceConnected = false;

// --- LOGIK & SCHUTZ VARIABLEN ---
int currentDist = 0;
int startDist = 0;      
int repCounter = 0;
unsigned long lastRepTime = 0;
const int REP_RANGE = 22; 
int workoutMode = 0; 
bool repIsArmed = false;
bool barLifted = false;

// Schutz-Filter
int lastValidDist = 0;
const int MAX_SUDDEN_JUMP = 50; // Schutz gegen Personen, die durchlaufen

// Auto-Rekalibrierung
unsigned long stabilityTimer = 0;
int lastCheckDist = 0;
const int STABILITY_DURATION = 5000; 

// --- EFFIZIENTE MESS-FUNKTION (PLOSIONS-SCHUTZ) ---
int getDistance() {
  digitalWrite(TRIG_PIN, LOW); delayMicroseconds(2);
  digitalWrite(TRIG_PIN, HIGH); delayMicroseconds(10);
  digitalWrite(TRIG_PIN, LOW);
  
  // Timeout auf 12000ms begrenzt (~2 Meter) für maximale Effizienz
  long duration = pulseIn(ECHO_PIN, HIGH, 12000); 
  int d = duration * 0.034 / 2;
  
  if (d <= 0 || d > 200) return lastValidDist; // Filtert Fehlerwerte aus

  // Plausibilitäts-Schutz: Wenn der Wert zu krass springt, ist es wahrscheinlich ein Passant
  if (lastValidDist != 0 && abs(d - lastValidDist) > MAX_SUDDEN_JUMP) {
      return lastValidDist; 
  }

  lastValidDist = d;
  return d;
}

class MyServerCallbacks: public BLEServerCallbacks {
    void onConnect(BLEServer* pServer) { deviceConnected = true; }
    void onDisconnect(BLEServer* pServer) {
        deviceConnected = false;
        pServer->getAdvertising()->start();
    }
};

void calibrate() {
  Serial.println("\n[SYSTEM] Rep-Track V1.0 - Kalibrierung läuft...");
  long sum = 0;
  int validCount = 0;
  for(int i=0; i<20; i++) { // Mehr Messungen für präzisere Basis
    int val = getDistance();
    if(val > 0) { sum += val; validCount++; }
    delay(60);
  }
  startDist = (validCount > 0) ? sum / validCount : 50;
  lastValidDist = startDist;

  // Modus-Entscheidung (Boden vs. Rack)
  workoutMode = (startDist < 35) ? 2 : 1; 
  
  Serial.println("----------------------------------------");
  Serial.printf("  BASIS: %d cm | MODUS: %s\n", startDist, (workoutMode == 1 ? "RACK/BANK" : "BODEN"));
  Serial.println("  SCHUTZ-FILTER: Aktiviert");
  Serial.println("----------------------------------------\n");
  
  barLifted = false;
  repCounter = 0;
  stabilityTimer = 0;
  if (deviceConnected) { pCharacteristic->setValue("0"); pCharacteristic->notify(); }
}

void setup() {
  Serial.begin(115200);
  pinMode(TRIG_PIN, OUTPUT); 
  pinMode(ECHO_PIN, INPUT);

  pinMode(Butt_PIN, INPUT);

  BLEDevice::init("Rep-Track V1.0");
  BLEServer *pServer = BLEDevice::createServer();
  pServer->setCallbacks(new MyServerCallbacks());
  BLEService *pService = pServer->createService(SERVICE_UUID);
  pCharacteristic = pService->createCharacteristic(CHARACTERISTIC_UUID, BLECharacteristic::PROPERTY_READ | BLECharacteristic::PROPERTY_NOTIFY);
  pCharacteristic->addDescriptor(new BLE2902());
  pService->start();
  pServer->getAdvertising()->start();

  calibrate(); 
}

void loop() {

    // 1️⃣ Warten bis gedrückt
  while (digitalRead(Butt_PIN) == LOW) {
    Serial.println("not pressed");
    delay(100);
    // warten
  }

  delay(50); // Entprellen

  // 2️⃣ Warten bis losgelassen
  while (digitalRead(Butt_PIN) == HIGH) {
    Serial.println("pressed");
    delay(100);
    // warten
  }

  delay(50); // Entprellen

    
  while (digitalRead(Butt_PIN) == LOW) {
        currentDist = getDistance();
    if (currentDist <= 0) return;

    // Erst nach dem ersten Anheben der Stange wird die Zählung aktiviert
    if (!barLifted) {
        if (abs(currentDist - startDist) > 10) { 
        barLifted = true;
        Serial.println("[START] Zählung aktiv. Counter bleibt bis zum Neustart bestehen.");
        }
    } 
    else {
        // MODUS 1: BANKDRÜCKEN / RACK
        if (workoutMode == 1) {
        if (currentDist < (startDist - REP_RANGE)) repIsArmed = true;
        if (currentDist > (startDist - 8) && repIsArmed) {
            // Sperrzeit von 1,1 Sekunde gegen Doppelzählung durch Zittern
            if (millis() - lastRepTime > 1100) {
            repCounter++;
            lastRepTime = millis();
            repIsArmed = false;
            Serial.printf("  [REP] %d\n", repCounter);
            if (deviceConnected) { 
                char b[8];
                b[0] = 'u';                  // Prefix setzen
                itoa(repCounter, &b[1], 10); // Zahl ab Position 1 schreiben

                pCharacteristic->setValue(b); 
                pCharacteristic->notify(); 
            }
            }
        }
        } 
        // MODUS 2: BODENÜBUNG
        else {
        if (currentDist > (startDist + REP_RANGE)) repIsArmed = true;
        if (currentDist < (startDist + 8) && repIsArmed) {
            if (millis() - lastRepTime > 1100) {
            repCounter++;
            lastRepTime = millis();
            repIsArmed = false;
            Serial.printf("  [REP] %d\n", repCounter);
            if (deviceConnected) { 
                char b[8];
                b[0] = 'u';                  // Prefix setzen
                itoa(repCounter, &b[1], 10); // Zahl ab Position 1 schreiben

                pCharacteristic->setValue(b); 
                pCharacteristic->notify(); 
            }
            }
        }
        }
    }

    // KEINE AUTO-REKALIBRIERUNG MEHR HIER.
    // Das System zählt einfach stumpf weiter.

    delay(30); 
    }

    while(digitalRead(Butt_PIN) == HIGH)
    {
        Serial.println("pressed");
    }

    delay(30);

    char b[8];
    b[0] = 'f';                  // Prefix setzen
    itoa(repCounter, &b[1], 10); // Zahl ab Position 1 schreiben

    pCharacteristic->setValue(b); 
    pCharacteristic->notify(); 
    delay(30);

    repCounter = 0;

}