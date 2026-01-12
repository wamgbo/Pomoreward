import 'package:flutter/material.dart';
import 'sandbox2.dart';
import '../main.dart';
import 'testtimer.dart';

class sandbox extends StatefulWidget {
  const sandbox({super.key});
  static final ValueNotifier<int> globalValue = ValueNotifier<int>(0);
  @override
  State<sandbox> createState() => PageAState();
}

class PageAState extends State<sandbox> {
  final  store=TimerStore.instance;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('A Widget')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Value = ${store.seconds}', style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 20),
          sandbox2(),
        ],
      ),
    );
  }
}
