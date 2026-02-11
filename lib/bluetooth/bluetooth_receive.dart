import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

// UUIDs vom ESP32, exakt wie auf dem Gerät
const String SERVICE_UUID = "1234abcd-0000-1000-8000-00805f9b34fb";
const String CHAR_UUID = "1234abcd-0001-1000-8000-00805f9b34fb";

class BleTestPage extends StatefulWidget {
  const BleTestPage({super.key});

  @override
  State<BleTestPage> createState() => _BleTestPageState();
}

class _BleTestPageState extends State<BleTestPage> {
  List<ScanResult> devices = [];
  BluetoothDevice? connectedDevice;
  BluetoothCharacteristic? dataChar;

  String receivedData = "Keine Daten";

  @override
  void initState() {
    super.initState();
    requestPermissions();
    startScan();
  }

  void startScan() {
    devices.clear();
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 6));

    FlutterBluePlus.scanResults.listen((results) {
      setState(() {
        devices = results;
      });
    });
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    // Stopp den Scan bevor wir verbinden
    FlutterBluePlus.stopScan();

    // Verbindung herstellen (autoConnect false)
    await device.connect(autoConnect: false);
    connectedDevice = device;

    // Services entdecken
    List<BluetoothService> services = await device.discoverServices();
    await Future.delayed(const Duration(milliseconds: 200)); // kleine Pause

    // Service & Characteristic suchen
    for (var service in services) {
      if (service.uuid.toString().toLowerCase() == SERVICE_UUID.toLowerCase()) {
        for (var char in service.characteristics) {
          if (char.uuid.toString().toLowerCase() == CHAR_UUID.toLowerCase()) {
            dataChar = char;

            // Notification aktivieren
            await char.setNotifyValue(true);

            // Listen auf Werte
            char.value.listen((value) {
              print("Raw BLE data: $value"); // Debug: Rohdaten
              String data = utf8.decode(value, allowMalformed: true);
              setState(() {
                receivedData = data;
              });
            });
          }
        }
      }
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("BLE Test Verbindung")),
      body: connectedDevice == null
          ? Column(
              children: [
                ElevatedButton(
                  onPressed: startScan,
                  child: const Text("Neu scannen"),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: devices.length,
                    itemBuilder: (context, index) {
                      final d = devices[index].device;
                      final name = d.name.isNotEmpty ? d.name : "Unbekanntes Gerät";

                      return ListTile(
                        title: Text(name),
                        subtitle: Text(d.id.id),
                        trailing: const Icon(Icons.bluetooth),
                        onTap: () => connectToDevice(d),
                      );
                    },
                  ),
                ),
              ],
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Verbunden mit:\n${connectedDevice!.name}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Empfangene Daten:",
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    receivedData,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      await connectedDevice?.disconnect();
                      setState(() {
                        connectedDevice = null;
                        dataChar = null;
                        receivedData = "Keine Daten";
                      });
                    },
                    child: const Text("Trennen"),
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> requestPermissions() async {
  await [
    Permission.bluetoothScan,
    Permission.bluetoothConnect,
    Permission.location,
  ].request();
}
}
