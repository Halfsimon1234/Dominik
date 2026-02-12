import 'package:flutter/material.dart';
// WICHTIG: Hier wird auf euren Unterordner verwiesen
import 'bluetooth/bluetooth_receive.dart'; 

void main() {
  runApp(const MaterialApp(
    home: BluetoothReceivePage(),
    debugShowCheckedModeBanner: false,
  ));
}