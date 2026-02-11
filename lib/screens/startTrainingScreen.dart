// Screen für Training starten
/*import 'package:flutter/material.dart';

class Starttrainingscreen extends StatelessWidget {
  const Starttrainingscreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Training starten')),
      body: const Center(
        child: Text(
          'Training starten',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
*/
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';  // Zugriff auf Datenbank
import 'package:firebase_auth/firebase_auth.dart';  // Zugriff auf Authentifizierung (User)
import 'trainingsDetailScreen.dart'; // Screen zum Tracken der Übungen (auf den wird navigiert)

class Starttrainingscreen extends StatelessWidget { // Stateless, da Screen nur Daten anzeigt, keine Interaktion (außer Navigation)
  const Starttrainingscreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Training starten')),
        body: const Center(child: Text('Kein User eingeloggt')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Training starten')),
      body: StreamBuilder<QuerySnapshot>( // StreamBuilder reagiert auf Änderungen in der Datenbank (z.B. neuer Trainingsplan) und baut die Seite neu auf
        stream: FirebaseFirestore.instance
            .collection('trainingsplaene')  // Zugriff auf Trainingspläne
            .where('ownerUid', isEqualTo: user.uid) // filtert nur eigene Pläne
            .snapshots(), // Echtzeit-Stream der Datenbank, daher Änderungen werden sofort angezeigt
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {  // zeigt Ladeindikator, solange Daten geladen werden
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) { // sind Pläne vorhanden?
            return const Center(child: Text('Bisher keine Trainingspläne'));
          }

          final plans = snapshot.data!.docs;  // Liste der Trainingspläne (Dokumente)

          return ListView.builder(  // scrollbare Liste der Trainingspläne
            padding: const EdgeInsets.all(16),
            itemCount: plans.length,  // Anzahl der Pläne 
            itemBuilder: (context, index) {
              final plan = plans[index];
              final planName = plan['name'] ?? 'Unbenannt'; // Name des Plans, falls nicht vorhanden "Unbenannt" anzeigen

              return GestureDetector( // erkennt Klicks auf den Plan
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TrainingsDetailScreen(  // Navigation zum Detialscreen 
                        planId: plan.id,
                        planData: plan.data() as Map<String, dynamic>,
                      ),
                    ),
                  );
                },
                // Styling des Plan-Kästchens
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue),
                  ),
                  child: Text(
                    planName,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
