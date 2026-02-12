import 'package:flutter/material.dart';
 
class RepService extends ChangeNotifier {
  int currentReps = 0;
  bool finished = false;
 
  void updateFromBluetooth(String decoded) {
    if (decoded.isEmpty) return;
 
    String prefix = decoded[0];
    String value = decoded.substring(1);
 
    if (prefix == "u") {
      // überschreiben
      currentReps = int.tryParse(value) ?? currentReps;
      notifyListeners();
    }
 
    if (prefix == "f") {
      finished = true;
      notifyListeners();
    }
  }
 
  void resetFinished() {
    finished = false;
  }
}
