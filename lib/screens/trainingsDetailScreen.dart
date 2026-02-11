// genaue Anzeige der Übungen eines Trainingsplans, hier wird auch getrackt, welche Sätze erledigt wurden
import 'package:flutter/material.dart';

class TrainingsDetailScreen extends StatelessWidget { // Screen selber ändert seinen State nicht, daher stateless
  final String planId;
  final Map<String, dynamic> planData;  // die Daten des Trainingsplans als Map 

// Konstruktor
  const TrainingsDetailScreen({
    Key? key,
    required this.planId,
    required this.planData,
  }) : super(key: key); // für Widget-Logik, nicht wichtig für uns

  @override
  Widget build(BuildContext context) {
    final uebungen = List<Map<String, dynamic>>.from(planData['uebungen'] ?? []); // umwandeln von dynamische Liste in Liste aus Maps (leere Liste falls keine Übungen) 

    return Scaffold(
      appBar: AppBar(title: Text(planData['name'] ?? 'Training')),
      body: ListView.builder( // scrollbare Liste der Übungen
        padding: const EdgeInsets.all(16),
        itemCount: uebungen.length, // Anzahl der Übungen im Plan
        itemBuilder: (context, index) {
          final uebung = uebungen[index];
          // Einzelne Übung anzeigen 
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              title: Text(uebung['name'] ?? 'Übung'),
              subtitle: Text(
                  'Sätze: ${uebung['saetze']}, Wiederholungen: ${uebung['wiederholungen']}'),
              trailing: IconButton(
                icon: const Icon(Icons.check_box_outline_blank),
                onPressed: () {
                  // Hier kannst du markieren, dass ein Satz erledigt wurde
                },
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () {
            Navigator.popUntil(context, (route) => route.isFirst);
          },
          child: const Text('Fertig'),
        ),
      ),
    );
  }
}
