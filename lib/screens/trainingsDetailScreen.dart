// genaue Anzeige der Übungen eines Trainingsplans
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'homescreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../bluetooth/rep_service.dart';
 
class TrainingsDetailScreen extends StatefulWidget {
  final String planId;
  final Map<String, dynamic> planData;
 
  const TrainingsDetailScreen({
    Key? key,
    required this.planId,
    required this.planData,
  }) : super(key: key);
 
  @override
  State<TrainingsDetailScreen> createState() =>
      _TrainingsDetailScreenState();
}
 
class _TrainingsDetailScreenState extends State<TrainingsDetailScreen> {
 
  late List<Map<String, dynamic>> uebungen;
  late Map<int, List<int>> wiederholungsCounter;
 
  int? aktiveUebungIndex;
  int? aktiverSatzIndex;
 
  late RepService repService;
 
  @override
  void initState() {
    super.initState();
 
    uebungen = List<Map<String, dynamic>>.from(
        widget.planData['uebungen'] ?? []);
 
    wiederholungsCounter = {};
 
    for (int i = 0; i < uebungen.length; i++) {
      int saetze = uebungen[i]['saetze'] ?? 0;
      wiederholungsCounter[i] =
          List.generate(saetze, (index) => 0);
    }
 
    // 🔥 Listener nach dem ersten Frame registrieren
    WidgetsBinding.instance.addPostFrameCallback((_) {
      repService = Provider.of<RepService>(context, listen: false);
      repService.addListener(_onRepUpdate);
    });
  }
 
  void _onRepUpdate() {
    if (!mounted) return;
 
    if (aktiveUebungIndex != null && aktiverSatzIndex != null) {
      setState(() {
        wiederholungsCounter[aktiveUebungIndex!]![aktiverSatzIndex!] =
            repService.currentReps;
      });
 
      if (repService.finished) {
        repService.resetFinished();
        setState(() {
          aktiveUebungIndex = null;
          aktiverSatzIndex = null;
        });
      }
    }
  }
 
  @override
  void dispose() {
    repService.removeListener(_onRepUpdate);
    super.dispose();
  }
 
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
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.planData['name'] ?? 'Training'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: uebungen.length,
        itemBuilder: (context, index) {
          final uebung = uebungen[index];
          final saetze = uebung['saetze'] ?? 0;
 
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
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
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
                        child: Row(
                          children: [
                            Checkbox(
                              value: aktiveUebungIndex == index &&
                                  aktiverSatzIndex == satzIndex,
                              onChanged: (value) {
                                setState(() {
                                  if (value == true) {
                                    aktiveUebungIndex = index;
                                    aktiverSatzIndex = satzIndex;
                                  } else {
                                    aktiveUebungIndex = null;
                                    aktiverSatzIndex = null;
                                  }
                                });
                              },
                            ),
                            Expanded(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${satzIndex + 1}. Satz:',
                                    style: const TextStyle(
                                        fontWeight:
                                            FontWeight.w500),
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
            await trainingSpeichern();
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (_) => HomeScreen()),
              (route) => false,
            );
          },
          child: const Text('Fertig'),
        ),
      ),
    );
  }
}