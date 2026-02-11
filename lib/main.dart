import 'package:flutter/material.dart';
import 'bluetooth/bluetooth_receive.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BLE Test App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const BleTestPage(),  
    );
  }
}
