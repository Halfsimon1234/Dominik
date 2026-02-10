// Screen für Training starten
import 'package:flutter/material.dart';

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