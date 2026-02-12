import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LastTrainingsScreen extends StatelessWidget {
  const LastTrainingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Nicht eingeloggt")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Letzte Trainings')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("letzteTrainings")
            .where("ownerUid", isEqualTo: user.uid)
            .orderBy("datum", descending: true)
            .snapshots(),
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "Noch keine Trainings vorhanden",
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          final trainings = snapshot.data!.docs;

          return ListView.builder(
            itemCount: trainings.length,
            itemBuilder: (context, index) {
              final data = trainings[index];
              final dataMap = data.data() as Map<String, dynamic>;
              final planName = dataMap["planName"] ?? "Unbekannt";
              final uebungen =
                  List<Map<String, dynamic>>.from(dataMap["uebungen"] ?? []);
              final Timestamp timestamp = dataMap["datum"];
              final date = timestamp.toDate();

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(
                    planName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "${date.day}.${date.month}.${date.year} - "
                    "${date.hour}:${date.minute.toString().padLeft(2, '0')}",
                  ),
                  trailing: const Icon(Icons.visibility),
                  onTap: () {
                    // ⚡ hier die sauberen Daten an Dialog übergeben
                    _showTrainingDetails(context, planName, uebungen);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  // 🔥 Dialog mit Übungen + Sätzen + Wiederholungen
  void _showTrainingDetails(
      BuildContext context, String planName, List<Map<String, dynamic>> uebungen) {

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(planName),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: uebungen.map((uebung) {

                  final name = uebung["name"] ?? "Übung";
                  final reps = List<int>.from(uebung["wiederholungen"] ?? []);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Column(
                        children: List.generate(reps.length, (i) {
                          return Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Satz ${i + 1}: ${reps[i]} Wiederholungen",
                              style: const TextStyle(fontSize: 14),
                            ),
                          );
                        }),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Schließen"),
            )
          ],
        );
      },
    );
  }
}
