import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'rep_service.dart';

// UUIDs vom ESP32
const String TARGET_SERVICE_UUID = "1234abcd-0000-1000-8000-00805f9b34fb";
const String TARGET_CHAR_UUID = "1234abcd-0001-1000-8000-00805f9b34fb";

class BluetoothReceivePage extends StatefulWidget {
  const BluetoothReceivePage({super.key});

  @override
  State<BluetoothReceivePage> createState() => BluetoothReceivePageState();
}

class BluetoothReceivePageState extends State<BluetoothReceivePage> {
  BluetoothDevice? connectedDevice;
  List<ScanResult> scanResults = [];
  bool isScanning = false;
  StreamSubscription? _valueSubscription;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    if (Platform.isAndroid) {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.location,
      ].request();

      if (statuses.values.any((element) => element.isDenied)) {
        debugPrint("Berechtigungen wurden abgelehnt");
      }
    }
    _startScan();
  }

  void _startScan() {
    setState(() {
      scanResults.clear();
      isScanning = true;
    });
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));

    FlutterBluePlus.scanResults.listen((results) {
      if (mounted) setState(() => scanResults = results);
    });

    FlutterBluePlus.isScanning.listen((scanning) {
      if (mounted && !scanning) setState(() => isScanning = false);
    });
  }

  Future<void> _connect(BluetoothDevice device) async {
    try {
      // 1. Verbindung aufbauen
      await device.connect(autoConnect: false);
      setState(() => connectedDevice = device);

      // 2. MTU für Android optimieren
      if (Platform.isAndroid) {
        await device.requestMtu(223);
        await Future.delayed(const Duration(milliseconds: 500));
      }

      // 3. Services suchen
      List<BluetoothService> services = await device.discoverServices();
      for (var service in services) {
        if (service.uuid == Guid(TARGET_SERVICE_UUID)) {
          for (var char in service.characteristics) {
            if (char.uuid == Guid(TARGET_CHAR_UUID)) {
              // 4. Benachrichtigungen (Notify) aktivieren
              await char.setNotifyValue(true);

              // 5. Alten Stream schließen, falls vorhanden
              await _valueSubscription?.cancel();

              // 6. Auf Daten hören
              _valueSubscription = char.onValueReceived.listen((value) {
                if (value.isNotEmpty && mounted) {
                  String decoded = utf8.decode(value);
                  // Provider aufrufen – listen: false, da wir im Stream sind
                  Provider.of<RepService>(context, listen: false)
                      .updateFromBluetooth(decoded);
                }
              });

              // Einmalig lesen, falls schon ein Wert da ist
              await char.read();
            }
          }
        }
      }
    } catch (e) {
      debugPrint("Verbindungsfehler: $e");
    }
  }

  Future<void> _disconnect() async {
    await _valueSubscription?.cancel();
    await connectedDevice?.disconnect();
    setState(() {
      connectedDevice = null;
    });
    // Reset in Provider optional
    Provider.of<RepService>(context, listen: false).resetFinished();
  }

  @override
  void dispose() {
    _valueSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Rep-Counter V1.0"),
        backgroundColor: Colors.blueAccent,
      ),
      body: connectedDevice == null ? _buildScanList() : _buildCounterView(),
    );
  }

  Widget _buildScanList() {
    return Column(
      children: [
        if (isScanning) const LinearProgressIndicator(),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: isScanning ? null : _startScan,
          icon: const Icon(Icons.search),
          label: const Text("Nach Rep-Track suchen"),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: scanResults.length,
            itemBuilder: (context, index) {
              final d = scanResults[index].device;
              final name =
                  d.platformName.isEmpty ? "Unbekanntes Gerät" : d.platformName;

              // Optional: Filter auf euren Gerätenamen
              if (d.platformName != "Rep-Track V1.0") return const SizedBox.shrink();

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                child: ListTile(
                  title: Text(name),
                  subtitle: Text(d.remoteId.str),
                  trailing:
                      const Icon(Icons.bluetooth_connected, color: Colors.blue),
                  onTap: () => _connect(d),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCounterView() {
    return Center(
      child: Consumer<RepService>(
        builder: (context, repService, child) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("WIEDERHOLUNGEN",
                  style: TextStyle(fontSize: 18, color: Colors.grey)),
              Text(
                repService.currentReps.toString(),
                style: const TextStyle(
                    fontSize: 150,
                    fontWeight: FontWeight.w900,
                    color: Colors.blueAccent),
              ),
              if (repService.finished)
                const Text(
                  "FERTIG!",
                  style: TextStyle(fontSize: 24, color: Colors.redAccent),
                ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _disconnect,
                style:
                    ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                child: const Text("Verbindung trennen",
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }
}
