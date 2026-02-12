/*
import 'package:flutter/material.dart';
 
/// Flutter code sample for [TextField].
 
class ObscuredTextFieldSample extends StatelessWidget {
  const ObscuredTextFieldSample({super.key});
 
  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 250,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Username',
              prefixIcon: Icon(Icons.person),
            ),
          ),
          SizedBox(height: 16), // Abstand
          TextField(
            obscureText: true,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Password',
              prefixIcon: Icon(Icons.lock),
 
            ),
          ),
          SizedBox(height: 16), // Abstand
 
         
         
 
        ],
      ),
    );
  }
}
 
class TextFieldExampleApp extends StatelessWidget {
  const TextFieldExampleApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Obscured Textfield')),
        body: const Center(child: ObscuredTextFieldSample()),
      ),
    );
  }
}
 
void main() => runApp(const TextFieldExampleApp());
*/
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'homeScreen.dart'; // weiterleitung nach dem Login
 
class LoginScreen extends StatefulWidget {  // Stateful -> UI muss dynamisch reagieren
  const LoginScreen({Key? key}) : super(key: key);
 
  @override
  State<LoginScreen> createState() => _LoginScreenState();  // speichert den State (Eingabe)
}
 
class _LoginScreenState extends State<LoginScreen> {
 
  final TextEditingController _emailController = TextEditingController(); // zum speichern der Texteingaben
  final TextEditingController _passwordController = TextEditingController();
 
  // Login Funktion
  Future<void> _login() async { // async -> Login geht über Internet
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword( // loggt User ein (Email und Passwort werden geprüft)
        email: _emailController.text.trim(),  // trim() entfernt unnötige Leerzeichen am Anfang und Ende
        password: _passwordController.text.trim(),
      );
 
      if (!mounted) return; // prüft, ob das Widget noch existiert
 
      Navigator.pushReplacement(  // Leitet zum HomeScreen weiter
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
 
    } on FirebaseAuthException catch (e) {  // Fehlerbehandlung, falls Login fehlschlägt (z.B. falsches Passwort, kein Internet, ...)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Login fehlgeschlagen")),
      );
    }
  }
 
  // Registrierung Funktion (ähnlich wie Login, aber erstellt einen neuen Account)
  Future<void> _register() async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword( // erstellt neuen User mit Email und Passwort
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
 
      if (!mounted) return;
 
      Navigator.pushReplacement(  // weiterleitung zum HomeScreen nach erfolgreicher Registrierung
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
 
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Registrierung fehlgeschlagen")),
      );
    }
  }
 
  @override
  Widget build(BuildContext context) {  // build-Methode -> Aufbau der UI
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Center(
        child: SizedBox(
          width: 300,
          child: Column(  // Vertikal
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
 
              TextField(
                controller: _emailController, // Textfeld mit Controller verbinden
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
              ),
 
              const SizedBox(height: 16),
 
              TextField(
                controller: _passwordController,
                obscureText: true,  // versteckt das Passwort
                decoration: const InputDecoration(
                  labelText: "Passwort",
                  border: OutlineInputBorder(),
                ),
              ),
 
              const SizedBox(height: 20),
 
              // Login Button
              ElevatedButton(
                onPressed: _login,
                child: const Text("Login"),
              ),
 
              const SizedBox(height: 10),
 
              // Registrieren Button
              ElevatedButton(
                onPressed: _register,
                child: const Text("Registrieren"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
 