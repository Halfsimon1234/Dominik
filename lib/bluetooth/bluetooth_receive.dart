import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

const String SERVICE_UUID = "1234abcd-0000-1000-8000-00805f9b34fb";
const String CHAR_UUID    = "1234abcd-0001-1000-8000-00805f9b34fb";

class BlePage extends StatefulWidget {
  const BlePage({super.key});

  @override
  State<BlePage> createState() => _BlePageState();
}

class _BlePageState extends State<BlePage> {
  BluetoothDevice? device;
  BluetoothCharacteristic? distanceChar;
  String distanceValue = "Warte auf Daten...";

  @override
  void initState() {
    super.initState();
    scanForDevice();
  }

  void scanForDevice() {
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));

    FlutterBluePlus.scanResults.listen((results) async {
      for (ScanResult r in results) {
        if (r.device.name == "ESP32-Fitness") {   // Name vom ESP32
          device = r.device;
          FlutterBluePlus.stopScan();
          await connectToDevice();
          break;
        }
      }
    });
  }

  Future<void> connectToDevice() async {
    await device!.connect();
    List<BluetoothService> services = await device!.discoverServices();

    for (var service in services) {
      if (service.uuid.toString() == SERVICE_UUID) {
        for (var char in service.characteristics) {
          if (char.uuid.toString() == CHAR_UUID) {
            distanceChar = char;
            await char.setNotifyValue(true);

            char.value.listen((value) {
              String data = utf8.decode(value);
              setState(() {
                distanceValue = data;
              });
            });
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Fitness BLE")),
      body: Center(
        child: Text(
          "Distanz: $distanceValue",
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
