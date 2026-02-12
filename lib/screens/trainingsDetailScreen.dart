// Testkommentar
// genaue Anzeige der Übungen eines Trainingsplans, hier wird auch getrackt, welche Sätze erledigt wurden
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'homescreen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TrainingsDetailScreen extends StatefulWidget { // Stateful, dass sich Screen ändert (counter hochzählt))
  final String planId;
  final Map<String, dynamic> planData;  // die Daten des Trainingsplans als Map 

  // Konstruktor
  const TrainingsDetailScreen({
    Key? key,
    required this.planId,
    required this.planData,
  }) : super(key: key); // für Widget-Logik, nicht wichtig für uns

   @override
  State<TrainingsDetailScreen> createState() =>
      _TrainingsDetailScreenState();
}  

class _TrainingsDetailScreenState extends State<TrainingsDetailScreen> {  // hier sind dynamischen daten 

  late List<Map<String, dynamic>> uebungen; // speichert alle Übungen 
  late Map<int, List<int>> wiederholungsCounter;

  int? aktiveUebungIndex;
  int? aktiverSatzIndex;


  @override
  void initState() {  // läuft einmal, wenn Screen gestartet wird 
    super.initState();

    uebungen = List<Map<String, dynamic>>.from(widget.planData['uebungen'] ?? []);  // Übungen laden 
    wiederholungsCounter = {};

    // Counter vorbereitet für Wiederholungen 
    for (int i = 0; i < uebungen.length; i++) {
      int saetze = uebungen[i]['saetze'] ?? 0;
      wiederholungsCounter[i] = List.generate(saetze, (index) => 0);
    }
  }

  // das training speichern (damit es in "letzte Trainings" angezeigt wird)
Future<void> trainingSpeichern() async {
  final firestore = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) return;

  List<Map<String, dynamic>> gespeicherteUebungen = [];

  for (int i = 0; i < uebungen.length; i++) {
    gespeicherteUebungen.add({
      "name": uebungen[i]["name"],
      "saetze": uebungen[i]["saetze"],
      "wiederholungen": wiederholungsCounter[i],
    });
  }

  await firestore.collection("letzteTrainings").add({
    "planId": widget.planId,
    "planName": widget.planData["name"],
    "datum": Timestamp.now(),
    "ownerUid": user.uid, 
    "uebungen": gespeicherteUebungen,
  });
}

  // FÜR SENSOR HOCHZÄHLEN -> SPÄTER BENUTZEN 
  /*
  void wiederholungErhoehen() {
    if (aktiveUebungIndex != null &&  // Wenn eine Übung und ein Satz aktiv ist, dann erhöhen 
        aktiverSatzIndex != null) {

      setState(() {
        wiederholungsCounter[aktiveUebungIndex!]!
            [aktiverSatzIndex!]++;
      });

    }
  }
  */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.planData['name'] ?? 'Training')),
      body: ListView.builder( // scrollbare Liste der Übungen
        padding: const EdgeInsets.all(16),
        itemCount: uebungen.length, // Anzahl der Übungen im Plan
        itemBuilder: (context, index) {
          final uebung = uebungen[index];
          final saetze = uebung['saetze'] ?? 0;

          // Einzelne Übung anzeigen 
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    uebung['name'] ?? 'Übung',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  // Unterkästchen für jeden Satz
                  Column(
                    children: List.generate(saetze, (satzIndex) {
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: (aktiveUebungIndex == index &&
                                aktiverSatzIndex == satzIndex)
                            ? Colors.blue.shade100
                            : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row( // Row enthät Checkbox und SatzText und Wiederholungszahl
                          children: [
                            Checkbox( // Checkbox nur aktiv, wenn es die aktuelle Übung der aktuelle Satz ist
                              value: aktiveUebungIndex == index &&
                                    aktiverSatzIndex == satzIndex,
                              onChanged: (value) {
                                setState(() { // alles neu Zeichnen, wenn sich etwas ändert 
                                  if (value == true) {  // wenn man Kästchen anklcikt, man kann nur eine Übung gleichzeitig, da nur 1 index speicherstelle 
                                    // Dieser Satz wird aktiv
                                    aktiveUebungIndex = index;
                                    aktiverSatzIndex = satzIndex;
                                  } else {
                                    // Falls man wieder deaktivieren will
                                    aktiveUebungIndex = null;
                                    aktiverSatzIndex = null;
                                  }
                                });
                              },
                            ),

                            Expanded( // sorgt dafür, dass Text den restlichen Platz einnimmt
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${satzIndex + 1}. Satz:',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500),
                                  ),
                                  Text(
                                    '${wiederholungsCounter[index]![satzIndex]} Wiederholungen',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () async {
            await trainingSpeichern();  // das Training speichern

            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => HomeScreen()),
              (route) => false,
            ); // zurück zum HomeScreen
          },
          child: const Text('Fertig'),
        ),
      ),
    );
  }
}
