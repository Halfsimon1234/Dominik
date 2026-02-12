// Testkommentar
import 'package:flutter/material.dart'; // Material Design Widgets importieren
import 'package:firebase_auth/firebase_auth.dart';
import 'createTrainingScreen.dart';
import 'startTrainingScreen.dart';
import 'lastTrainingsScreen.dart';
import 'login_screen.dart';



// Globale Variable
double buttonSpace = 20.0;

class HomeScreen extends StatelessWidget {  // neues Widget HomeScreen, das von StatelessWidget erbt (stateless = Bildschirm ändert sich nicht dynamisch)
  const HomeScreen({Key? key}) : super(key: key); // Konstruktor; key optionales Parameter (kann helfen widget zu identifizieren)

  @override
  Widget build(BuildContext context) {  // jedes Widget braucht build Methode -> Informationen über Position, Umgebung, ...
    return Scaffold(  // Grundgerüst für eine Seite
      appBar: AppBar( // obere Leiste der Seite
        title: const Text('Rep-Track'),
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
                print('Training starten gedrückt');
                Navigator.push( // auf eine neue Seite navigieren
                  context,
                  MaterialPageRoute(  // erstelle eine neue Route (Seite)
                    builder: (context) => const Starttrainingscreen(),  // definiert, welche Seite angezeigt wird
                  ),
                );
              },
              child: const Text('Training starten'),  // Text auf dem Button
            ),
            SizedBox(height: buttonSpace), // Abstand zwischen Buttons

            // Button 2: Letzte Trainings
            ElevatedButton(
              onPressed: () {
                print('Letzte Trainings gedrückt');
                 Navigator.push( // auf eine neue Seite navigieren
                  context,
                  MaterialPageRoute(  // erstelle eine neue Route (Seite)
                    builder: (context) => const LastTrainingsScreen(),  // definiert, welche Seite angezeigt wird
                  ),
                );
              },
              child: const Text('Letzte Trainings'),  
            ),
            SizedBox(height: buttonSpace), // Abstand zwischen Buttons

            // Button 3: Trainingsplan erstellen
            ElevatedButton(
              onPressed: () {
                print('Trainingsplan erstellen gedrückt');
                Navigator.push( // auf eine neue Seite navigieren
                  context,
                  MaterialPageRoute(  // erstelle eine neue Route (Seite)
                    builder: (context) => const TrainingsplanScreen(),  // definiert, welche Seite angezeigt wird
                  ),
                );
              },
              child: const Text('Trainingsplan erstellen'),
            ),
            SizedBox(height: buttonSpace),

            // Button 4: Button: Bluetoothverbindung
            ElevatedButton(
              onPressed: () {
                print('Button Bluetoothverbindung gedrückt');
                /*
                Navigator.push( // auf eine neue Seite navigieren
                  context,
                  MaterialPageRoute(  // erstelle eine neue Route (Seite)
                    builder: (context) => const BleReceiverPage(),  // definiert, welche Seite angezeigt wird
                  ),
                );
                */
              },
              child: const Text('Bluetooth-Verbindung'),
            ),
            SizedBox(height: buttonSpace),

            // Button 5: Logout
            ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();  // loggt User aus 

                Navigator.pushAndRemoveUntil( // neue Seiten auf den Stack legen und alte Seiten löschen, damit man nicht mehr zurück zum HomeScreen kann ohne Login
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
