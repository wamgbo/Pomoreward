import 'package:flutter/material.dart';
import 'pages/clock.dart';

void main() {
  runApp(const MaterialApp(home: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(child: Clock(),),
    );
  }
}
