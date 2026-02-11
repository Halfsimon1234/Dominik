/*#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>
#include <Arduino.h>
 
// UUIDs müssen exakt übereinstimmen
#define SERVICE_UUID        "1234abcd-0000-1000-8000-00805f9b34fb"
#define CHARACTERISTIC_UUID "1234abcd-0001-1000-8000-00805f9b34fb"
 
BLEServer* pServer = nullptr;
BLECharacteristic* pCharacteristic = nullptr;
 
int counter = 0;
 
void setup() {
  Serial.begin(115200);
  Serial.println("Starting BLE...");
 
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
  // Beispiel: sende jede Sekunde einen Zähler
  String msg = "Wert: " + String(counter);
  pCharacteristic->setValue(msg.c_str());
  pCharacteristic->notify(); // sendet Notification an App
  Serial.println("Gesendet: " + msg);
 
  counter++;
  delay(1000);
}*/