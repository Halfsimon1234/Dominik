import 'package:flutter/material.dart';

class RepService extends ChangeNotifier {
  int currentReps = 0;
  bool finished = false;

  void updateFromBluetooth(String decoded) {
    if (decoded.isEmpty) return;

    decoded = decoded.trim(); //entfernt Leerzeichen

    String prefix = decoded[0];
    String value = decoded.substring(1);
    int number = int.tryParse(value) ?? 0;

    if (prefix == "u") {
      if (number == 0) {
        // Neustart vom ESP32 signalisiert → Counter zurücksetzen
        currentReps = 0;
        finished = false;
      } else {
        // Sonst setzen wir den Wert auf die empfangene Zahl
        currentReps = number;
      }
      notifyListeners();
    }

    if (prefix == "f") {
      // Fertig – Wert übernehmen
      currentReps = number;
      finished = true;
      notifyListeners();
    }
  }

  void resetFinished() {
    finished = false;
    notifyListeners();
  }
}