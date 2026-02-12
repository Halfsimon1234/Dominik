/*#include <Arduino.h>
#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>
#include <Wire.h>
// Pin für den Sender

int SENDEN = 21;

// Pin für das vom Objekt reflektierte Signal

int ECHO = 22;

int LED = 18;
// Variable fü die Speicherung der Entfernung

long Entfernung = 0;
 
// UUIDs müssen exakt übereinstimmen
#define SERVICE_UUID        "1234abcd-0000-1000-8000-00805f9b34fb"
#define CHARACTERISTIC_UUID "1234abcd-0001-1000-8000-00805f9b34fb"
 
BLEServer* pServer = nullptr;
BLECharacteristic* pCharacteristic = nullptr;
 
 
void setup() {
  Serial.begin(115200);
  Serial.println("Starting BLE...");

  pinMode(SENDEN, OUTPUT);

  pinMode(ECHO, INPUT);

  pinMode(LED, OUTPUT);
 
  // BLE Device initialisieren
  BLEDevice::init("ESP32_BLE");
 
  // Server erstellen
  pServer = BLEDevice::createServer();
 
  // Service erstellen
  BLEService* pService = pServer->createService(SERVICE_UUID);
 
  // Characteristic erstellen
  pCharacteristic = pService->createCharacteristic(
                      CHARACTERISTIC_UUID,
                      BLECharacteristic::PROPERTY_READ   |
                      BLECharacteristic::PROPERTY_NOTIFY
                    );
 
  // Notification aktivieren
  pCharacteristic->addDescriptor(new BLE2902());
 
  // Service starten
  pService->start();
 
  // BLE Werbung starten
  BLEAdvertising* pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(SERVICE_UUID);
  pAdvertising->setScanResponse(true);
  pAdvertising->setMinPreferred(0x06);  // empfohlen
  pAdvertising->setMinPreferred(0x12);
  BLEDevice::startAdvertising();
 
  Serial.println("BLE Device is now advertising...");
}
 
void loop() {
    digitalWrite(SENDEN, LOW);

  delay(5);

  digitalWrite(SENDEN, HIGH);

  delayMicroseconds(10);

  digitalWrite(SENDEN, LOW);

  long Zeit = pulseIn(ECHO, HIGH);

  Entfernung = (Zeit / 2) * 0.03432;

  delay(50);

  // Beispiel: sende jede Sekunde einen Zähler
  String msg = "Wert: " + String(Entfernung);
  pCharacteristic->setValue(msg.c_str());
  pCharacteristic->notify(); // sendet Notification an App
  Serial.println("Distanz: " + msg);
 
  delay(1000);
}*/