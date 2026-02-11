// Trainingsplan erstellen Screen
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'models/trainingsplan.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class _uebungsKastenData {  // gruppiert Controller für eine Übung
  final TextEditingController nameController = TextEditingController(); // speichert die aktuelle Eingabe
  final TextEditingController saetzeController = TextEditingController();
  final TextEditingController wiederhController = TextEditingController();
}

 
class TrainingsplanScreen extends StatefulWidget {  // stateful, da man dynamisch Übungen hinzufügt
  const TrainingsplanScreen({Key? key}) : super(key: key);

  @override
  State<TrainingsplanScreen> createState() => _TrainingsplanScreenState();  // TrainingsplanSCreenState ist der Speicher + Logik für die Seite
}

class _TrainingsplanScreenState extends State<TrainingsplanScreen> {  // State-Klasse
  // Liste der Übungen (nur für die Anzahl der Kästchen)
  final TextEditingController _planNameController = TextEditingController();  // speichert namen des Trainingsplans 
  final List<int> _uebungen = []; // Anzahl der Übungen -> wie viele Kästchen gezeichnet werden sollen
  final List<_uebungsKastenData> _uebungsData = []; // eigentliche Controller-Daten für jede Übung 

  @override
  Widget build(BuildContext context) {  // build-Methode zeichnet die Seite (Flutter ruft sie beim ersten Anzeigen und bei setState() auf)
    return Scaffold(  // Grundgerüst
      appBar: AppBar(
        title: const Text('Trainingsplan erstellen'),
      ),

      
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Übung hinzufügen (links)
            InkWell(
              onTap: () {
                setState(() {
                  _uebungen.add(_uebungen.length);  // fügt ein neues Kästchen hinzu
                  _uebungsData.add(_uebungsKastenData()); // erstellt Controller für das neue Kästchen
                });
              },
              child: Row(
                children: const [
                  Icon(Icons.add),  // Plus-Symbol, von Material Bibliothek
                  SizedBox(width: 6),
                  Text('Übung hinzufügen'),
                ],
              ),
            ),

            const Spacer(),

            // Fertig Button (rechts)
            ElevatedButton(
              onPressed: () async { 
                String planName = _planNameController.text; // holt sich den Namen vom Controller
                if (planName.isEmpty) return;

                // Textfield-Daten der Übungen in Uebung-Objekte umwandeln
                List<Uebung> uebungenListe = _uebungsData.map((data) {
                  return Uebung(
                    name: data.nameController.text,
                    saetze: int.tryParse(data.saetzeController.text) ?? 0,
                    wiederholungen: int.tryParse(data.wiederhController.text) ?? 0,
                  );
                }).toList();  // zu einer Liste machen

                Trainingsplan plan = Trainingsplan(name: planName, uebungen: uebungenListe);  // Trainingsplan-Objekt erstellen

                // UID des angemeldeten Users holen 
                final String uid = FirebaseAuth.instance.currentUser!.uid;

                // Trainingsplan in Firebase speichern, mit ownerUid
                await FirebaseFirestore.instance.collection('trainingsplaene').add({
                  ...plan.toMap(),     // alle bisherigen Felder
                  'ownerUid': uid,     // <--- hier die UID hinzufügen
    });
                // Bestätigung anzeigen (context ist wichtig, damit Flutter weiß, wo die Snackbar angezeigt werden soll))
                ScaffoldMessenger.of(context).showSnackBar( 
                  SnackBar(content: Text('Trainingsplan gespeichert!'))
                );
 
                Navigator.popUntil(context, (route) => route.isFirst); // zurück zur vorherigen Seite
              },
              child: const Text('Fertig'),
            ),

          ],
        ),
      ),


      body: Padding(
        padding: const EdgeInsets.all(16),  // Abstand zum Rand
        child: Column(  // alles untereinander ausrichten
          children: [
            // Name des Trainingsplans
            TextField(
              controller: _planNameController,
              decoration: const InputDecoration(   // Styling
                labelText: 'Name des Trainingsplans',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            // Überschriften
            Row(  // alles nebeneinander ausrichten
              children: const [
                Expanded(
                  flex: 3,  // Feld 3 Mal so breit wie die anderen
                  child: Center(
                    child: Text(
                      'Übung',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Center(
                    child: Text(
                      'Sätze',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Center(
                    child: Text(
                      'Wiederh.',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Dynamische Liste der Übungs-Kästchen
            Expanded( // damit die Liste scrollen kann
              child: ListView.builder(
                itemCount: _uebungen.length,  // soviele Kästchen, wie Elemente in _uebungen
                itemBuilder: (context, index) => _uebungsKasten(index), // jedes Kästcheen zeichnen 
              ),
            ),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  // Ausgelagerte Funktion
  // Einzelnes Übungs-Kästchen
  Widget _uebungsKasten(int index) {
    final data = _uebungsData[index];
    return Container( // Rahmen um die Textfelder
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [ // 3 Felder nebeneinander 
          // Übungsname
          Expanded(
            flex: 3,
            child: TextField(
              controller: data.nameController,  // verbindet TextField mit Controller
              decoration: const InputDecoration(
                hintText: 'Name...',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Sätze
          Expanded(
            flex: 1,
            child: TextField(
              controller: data.saetzeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Sätze...',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Wiederholungen
          Expanded(
            flex: 1,
            child: TextField(
              controller: data.wiederhController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Wh...',
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


