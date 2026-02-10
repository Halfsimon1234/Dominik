#include <Arduino.h>

#include <Wire.h>
// Pin für den Sender

int SENDEN = 21;

// Pin für das vom Objekt reflektierte Signal

int ECHO = 22;

int LED = 18;
// Variable fü die Speicherung der Entfernung

long Entfernung = 0;

void setup()

{

  pinMode(SENDEN, OUTPUT);

  pinMode(ECHO, INPUT);

  pinMode(LED, OUTPUT);

  // Seriellen Monitor starten

  Serial.begin(9600);

}

void loop()

{

  // Sender kurz ausschalten um Störungen des Signal zu vermeiden

  digitalWrite(SENDEN, LOW);

  delay(5);

  // Signal für 10 Micrsekunden senden, danach wieder ausschalten

  digitalWrite(SENDEN, HIGH);

  delayMicroseconds(10);

  digitalWrite(SENDEN, LOW);

  // pulseIn -> Zeit messen, bis das Signal zurückkommt

  long Zeit = pulseIn(ECHO, HIGH);

  // Entfernung in cm berechnen

  // Zeit/2 -> nur eine Strecke

  Entfernung = (Zeit / 2) * 0.03432;

  delay(500);

  // nur Entfernungen < 100 anzeigen

  if (Entfernung < 100)

  {

    // Messdaten anzeigen

    Serial.print("Entfernung in cm: ");

    Serial.println(Entfernung);

    if(Entfernung > 20)
    {
        digitalWrite(LED, HIGH);
    }
    else
    {
        digitalWrite(LED, LOW);
    }
  }

}