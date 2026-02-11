// Trainingsplan erstellen Screen
import 'package:flutter/material.dart';
 
class TrainingsplanScreen extends StatefulWidget {  // stateful, da man dynamisch Übungen hinzufügt
  const TrainingsplanScreen({Key? key}) : super(key: key);

  @override
  State<TrainingsplanScreen> createState() => _TrainingsplanScreenState();  // TrainingsplanSCreenState ist der Speicher + Logik für die Seite
}

class _TrainingsplanScreenState extends State<TrainingsplanScreen> {  // State-Klasse
  // Liste der Übungen (nur für die Anzahl der Kästchen)
  final List<int> _uebungen = []; // Anzahl der Übungen -> wie viele Kästchen gezeichnet werden sollen

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
                  _uebungen.add(_uebungen.length);
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
              onPressed: () {
                // TODO: Fertig
                print('Trainingsplan fertig');
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
                itemBuilder: (context, index) { // jedes Kästchen einzeln zeichnen 
                  return _uebungsKasten();
                },
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
  Widget _uebungsKasten() {
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


