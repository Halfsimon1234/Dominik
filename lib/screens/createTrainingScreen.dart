// Trainingsplan erstellen Screen
import 'package:flutter/material.dart';

class TrainingsplanScreen extends StatelessWidget {
  const TrainingsplanScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trainingsplan erstellen')),
      body: const Center(
        child: Text(
          'Trainingsplan erstellen',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
