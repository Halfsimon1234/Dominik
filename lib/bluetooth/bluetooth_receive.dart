import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

// UUIDs vom ESP32 - Müssen exakt mit dem Arduino-Code übereinstimmen
const String SERVICE_UUID = "1234abcd-0000-1000-8000-00805f9b34fb";
const String CHAR_UUID = "1234abcd-0001-1000-8000-00805f9b34fb";

void main() => runApp(const MaterialApp(
      home: BleReceiverPage(),
      debugShowCheckedModeBanner: false,
    ));

class BleReceiverPage extends StatefulWidget {
  const BleReceiverPage({super.key});

  @override
  State<BleReceiverPage> createState() => _BleReceiverPageState();
}

class _BleReceiverPageState extends State<BleReceiverPage> {
  List<ScanResult> devices = [];
  BluetoothDevice? connectedDevice;
  String receivedData = "Warte auf Wiederholung...";
  bool isConnecting = false;

  @override
  void initState() {
    super.initState();
    _initBle();
  }

  Future<void> _initBle() async {
    if (!Platform.isAndroid && !Platform.isIOS) return;

    // Berechtigungen anfordern
    await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();

    startScan();
  }

  void startScan() {
    if (!Platform.isAndroid && !Platform.isIOS) return;

    setState(() => devices.clear());
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));
    
    FlutterBluePlus.scanResults.listen((results) {
      if (mounted) {
        setState(() {
          devices = results;
        });
      }
    });
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    setState(() => isConnecting = true);

    try {
      await FlutterBluePlus.stopScan();

      // 1. Verbindung aufbauen
      await device.connect(autoConnect: false);
      connectedDevice = device;

      // 2. MTU für Android erhöhen (wichtig für stabile String-Übertragung)
      if (Platform.isAndroid) {
        await device.requestMtu(223);
      }

      // 3. Services suchen
      List<BluetoothService> services = await device.discoverServices();

      for (var service in services) {
        if (service.uuid.toString().toLowerCase() == SERVICE_UUID.toLowerCase()) {
          for (var char in service.characteristics) {
            if (char.uuid.toString().toLowerCase() == CHAR_UUID.toLowerCase()) {
              
              // 4. Benachrichtigungen (Notify) aktivieren
              await char.setNotifyValue(true);

              // 5. Auf Daten lauschen (onValueReceived ist der aktuelle Standard)
              char.onValueReceived.listen((value) {
                if (value.isEmpty) return;

                try {
                  // Versuch die Bytes als Text zu lesen
                  String data = utf8.decode(value).trim();
                  print("Empfangene Reps: $data");
                  
                  if (mounted) {
                    setState(() {
                      receivedData = data;
                    });
                  }
                } catch (e) {
                  // Fallback: Falls der ESP32 nur ein rohes Byte schickt
                  if (mounted) {
                    setState(() {
                      receivedData = value[0].toString();
                    });
                  }
                }
              });
            }
          }
        }
      }
    } catch (e) {
      print("Verbindungsfehler: $e");
    } finally {
      if (mounted) setState(() => isConnecting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Rep-Track V1.0 Receiver"),
        backgroundColor: Colors.blueGrey[900],
        foregroundColor: Colors.white,
      ),
      body: connectedDevice == null ? _buildScanList() : _buildDataView(),
    );
  }

  Widget _buildScanList() {
    return Column(
      children: [
        if (isConnecting) const LinearProgressIndicator(),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton.icon(
            onPressed: startScan,
            icon: const Icon(Icons.refresh),
            label: const Text("Geräte suchen"),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: devices.length,
            itemBuilder: (context, index) {
              final d = devices[index].device;
              
              // FILTER: Nur unseren ESP32 anzeigen
              if (d.platformName != "Rep-Track V1.0") {
                return const SizedBox.shrink();
              }

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: ListTile(
                  leading: const Icon(Icons.fitness_center, color: Colors.blue),
                  title: Text(d.platformName),
                  subtitle: Text(d.remoteId.str),
                  onTap: () => connectToDevice(d),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDataView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Verbunden mit ${connectedDevice!.platformName}",
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 40),
          const Text("Wiederholungen:", style: TextStyle(fontSize: 20)),
          Text(
            receivedData,
            style: const TextStyle(
              fontSize: 16, 
              fontWeight: FontWeight.bold, 
              color: Colors.blue
            ),
          ),
          const SizedBox(height: 50),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[100]),
            onPressed: () async {
              await connectedDevice?.disconnect();
              setState(() {
                connectedDevice = null;
                receivedData = "Warte auf Wiederholung...";
              });
            },
            child: const Text("Verbindung trennen", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}