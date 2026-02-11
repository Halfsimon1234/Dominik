import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

// UUIDs vom ESP32
const String SERVICE_UUID = "1234abcd-0000-1000-8000-00805f9b34fb";
const String CHAR_UUID = "1234abcd-0001-1000-8000-00805f9b34fb";

void main() => runApp(const MaterialApp(home: BleReceiverPage()));

class BleReceiverPage extends StatefulWidget {
  const BleReceiverPage({super.key});

  @override
  State<BleReceiverPage> createState() => _BleReceiverPageState();
}

class _BleReceiverPageState extends State<BleReceiverPage> {
  List<ScanResult> devices = [];
  BluetoothDevice? connectedDevice;
  BluetoothCharacteristic? dataChar;
  String receivedData = "Keine Daten";

  @override
  void initState() {
    super.initState();
    _initBle();
  }

  Future<void> _initBle() async {
    if (!Platform.isAndroid && !Platform.isIOS) return;

    // Permissions anfordern
    await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();

    // Scan starten
    startScan();
  }

  void startScan() {
    if (!Platform.isAndroid && !Platform.isIOS) return;

    devices.clear();
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 6));
    FlutterBluePlus.scanResults.listen((results) {
      setState(() {
        devices = results;
      });
    });
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    if (!Platform.isAndroid && !Platform.isIOS) return;

    // Scan stoppen
    FlutterBluePlus.stopScan();

    // Verbindung herstellen
    await device.connect(autoConnect: false);
    connectedDevice = device;

    // Services entdecken
    List<BluetoothService> services = await device.discoverServices();

    for (var service in services) {
      if (service.uuid.toString().toLowerCase() == SERVICE_UUID.toLowerCase()) {
        for (var char in service.characteristics) {
          if (char.uuid.toString().toLowerCase() == CHAR_UUID.toLowerCase()) {
            dataChar = char;

            // Notify aktivieren
            await char.setNotifyValue(true);

            // Wertänderungen abhören
            char.value.listen((value) {
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
      appBar: AppBar(title: const Text("ESP32 BLE Receiver")),
      body: connectedDevice == null
          ? Column(
              children: [
                const SizedBox(height: 10),
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
                  const Text("Empfangene Daten:", style: TextStyle(fontSize: 16)),
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
}
