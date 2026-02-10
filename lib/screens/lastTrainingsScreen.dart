// Letzte TrainingsScreen
import 'package:flutter/material.dart';

class LastTrainingsScreen extends StatelessWidget {
  const LastTrainingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Letzte Trainings')),
      body: const Center(
        child: Text(
          'Letzte Trainings',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
