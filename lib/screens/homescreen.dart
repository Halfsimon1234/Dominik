// Testkommentar
import 'package:flutter/material.dart'; // Material Design Widgets importieren

// Globale Variable
double buttonSpace = 20.0;

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
            const SizedBox(height: 60), // Abstand

            // Button 1: Training starten
            ElevatedButton(
              onPressed: () {
                // TODO: Navigation zum Training starten Screen
                print('Training starten gedrückt');
              },
              child: const Text('Training starten'),  // Text auf dem Button
            ),
            SizedBox(height: buttonSpace), // Abstand zwischen Buttons

            // Button 2: Letzte Trainings
            ElevatedButton(
              onPressed: () {
                // TODO: Navigation zum Letzte Trainings Screen
                print('Letzte Trainings gedrückt');
              },
              child: const Text('Letzte Trainings'),  
            ),
            SizedBox(height: buttonSpace), // Abstand zwischen Buttons

            // Button 3: Trainingsplan erstellen
            ElevatedButton(
              onPressed: () {
                // TODO: Navigation zum Trainingsplan erstellen Screen
                print('Trainingsplan erstellen gedrückt');
              },
              child: const Text('Trainingsplan erstellen'),
            ),
            SizedBox(height: buttonSpace),

            // Button 4: Logout
            ElevatedButton(
              onPressed: () {
                // TODO: Navigation zum Logout
                print('Logout gedrückt');
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
