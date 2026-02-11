import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

const String SERVICE_UUID = "1234abcd-0000-1000-8000-00805f9b34fb";
const String CHAR_UUID    = "1234abcd-0001-1000-8000-00805f9b34fb";

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
    FlutterBluePlus.stopScan();
    await device.connect();
    connectedDevice = device;

    List<BluetoothService> services = await device.discoverServices();

    for (var service in services) {
      if (service.uuid.toString() == SERVICE_UUID) {
        for (var char in service.characteristics) {
          if (char.uuid.toString() == CHAR_UUID) {
            dataChar = char;
            await char.setNotifyValue(true);

            char.value.listen((value) {
              String data = utf8.decode(value);
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
                ],
              ),
            ),
    );
  }
}
