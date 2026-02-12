import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'models/trainingsplan.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class _uebungsKastenData {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController saetzeController = TextEditingController();
  final TextEditingController wiederhController = TextEditingController();
}

class TrainingsplanScreen extends StatefulWidget {
  const TrainingsplanScreen({Key? key}) : super(key: key);

  @override
  State<TrainingsplanScreen> createState() => _TrainingsplanScreenState();
}

class _TrainingsplanScreenState extends State<TrainingsplanScreen> {
  final TextEditingController _planNameController = TextEditingController();

  final List<_uebungsKastenData> _uebungsData = [];

  // Übung hinzufügen
  void _addUebung() {
    setState(() {
      _uebungsData.add(_uebungsKastenData());
    });
  }

  // Trainingsplan speichern
  Future<void> _savePlan() async {
    String planName = _planNameController.text.trim();
    if (planName.isEmpty) return;

    List<Uebung> uebungenListe = _uebungsData.map((data) {
      return Uebung(
        name: data.nameController.text,
        saetze: int.tryParse(data.saetzeController.text) ?? 0,
        wiederholungen: int.tryParse(data.wiederhController.text) ?? 0,
      );
    }).toList();

    Trainingsplan plan =
        Trainingsplan(name: planName, uebungen: uebungenListe);

    final uid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance.collection('trainingsplaene').add({
      ...plan.toMap(),
      'ownerUid': uid,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Trainingsplan gespeichert!')),
    );

    Navigator.pop(context);
  }

  @override
  void dispose() {
    _planNameController.dispose();
    for (var e in _uebungsData) {
      e.nameController.dispose();
      e.saetzeController.dispose();
      e.wiederhController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trainingsplan erstellen')),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            InkWell(
              onTap: _addUebung,
              child: Row(
                children: const [
                  Icon(Icons.add),
                  SizedBox(width: 6),
                  Text('Übung hinzufügen'),
                ],
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _savePlan,
              child: const Text('Fertig'),
            ),
          ],
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _planNameController,
              decoration: const InputDecoration(
                labelText: 'Name des Trainingsplans',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            Row(
              children: const [
                Expanded(flex: 3, child: Center(child: Text('Übung', style: TextStyle(fontWeight: FontWeight.bold)))),
                Expanded(flex: 1, child: Center(child: Text('Sätze', style: TextStyle(fontWeight: FontWeight.bold)))),
                Expanded(flex: 1, child: Center(child: Text('Wh', style: TextStyle(fontWeight: FontWeight.bold)))),
              ],
            ),
            const SizedBox(height: 10),

            Expanded(
              child: ListView.builder(
                itemCount: _uebungsData.length,
                itemBuilder: (context, index) => _uebungsKasten(index),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _uebungsKasten(int index) {
    final data = _uebungsData[index];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: TextField(
              controller: data.nameController,
              decoration: const InputDecoration(
                hintText: 'Name...',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 1,
            child: TextField(
              controller: data.saetzeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Sätze',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 1,
            child: TextField(
              controller: data.wiederhController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Wh',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
