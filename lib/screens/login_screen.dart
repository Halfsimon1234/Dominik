import 'package:flutter/material.dart';
// adfsdf
/// Flutter code sample for [TextField].
class ObscuredTextFieldSample extends StatelessWidget {
  const ObscuredTextFieldSample({super.key});

  @override
  Widget build(BuildContext context) 
  {
    return const SizedBox(
      width: 250,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: 
        [
          TextField
          (
            decoration: InputDecoration
            (
              border: OutlineInputBorder(),
              labelText: 'Username',
            ),
          ),

          SizedBox(height: 16), // Abstand

          TextField
          (
            obscureText: true,
            decoration: InputDecoration
            (
              border: OutlineInputBorder(),
              labelText: 'Password',
            ),
          ),
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
        appBar: AppBar(title: const Text('Dominik Login')),
        body: const Center(child: ObscuredTextFieldSample()),
      ),
    );
  }
  
}
