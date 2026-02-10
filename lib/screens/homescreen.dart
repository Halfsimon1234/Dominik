// Testkommentar
import 'package:flutter/material.dart'; // Material Design Widgets importieren

class HomeScreen extends StatelessWidget {  // neues Widget HomeScreen, das von StatelessWidget erbt (stateless = Bildschirm ändert sich nicht dynamisch)
  const HomeScreen({Key? key}) : super(key: key); // Konstruktor; key optionales Parameter (kann helfen widget zu identifizieren)

  @override
  Widget build(BuildContext context) {  // jedes Widget braucht build Methode -> Informationen über Position, Umgebung, ...
    return Scaffold(  // Grundgerüst für eine Seite
      appBar: AppBar( // obere Leiste der Seite
        title: const Text('Gym App'),
      ),
      body: Padding(  // Hauptinhalt
        padding: const EdgeInsets.all(16.0),  // rundherum 16 Pixel Abstand
        child: Column(  // Column stapelt Widgets vertikal
          mainAxisAlignment: MainAxisAlignment.center,  // vertikal zentrieren
          crossAxisAlignment: CrossAxisAlignment.stretch, // horizontal ausdehnen
          children: [ // einzelnen Widgets
            // Text oben
            const Text(
              'Start Strong - Finish Stronger',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40), // Abstand

            // Button 1: Training starten
            ElevatedButton(
              onPressed: () {
                // TODO: Navigation zum Training starten Screen
                print('Training starten gedrückt');
              },
              child: const Text('Training starten'),  // Text auf dem Button
            ),
            const SizedBox(height: 16), // Abstand zwischen Buttons

            // Button 2: Trainingsplan erstellen
            ElevatedButton(
              onPressed: () {
                // TODO: Navigation zum Trainingsplan erstellen Screen
                print('Trainingsplan erstellen gedrückt');
              },
              child: const Text('Trainingsplan erstellen'),
            ),
          ],
        ),
      ),
    );
  }
}
