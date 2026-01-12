import 'package:flutter/material.dart';
import '../main.dart';
import 'sandbox.dart';
import 'clock.dart';
import 'testtimer.dart';

class sandbox2 extends StatelessWidget {
  const sandbox2({super.key});
  @override
  Widget build(BuildContext context) {
    final store = TimerStore.instance;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () {
            sandbox.globalValue.value = 1;
          },
          child: const Text('1'),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: () {
            sandbox.globalValue.value = 2;
          },
          child: const Text('2'),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: () {
            sandbox.globalValue.value = 3;
          },
          child: const Text('3'),
        ),
      ],
    );
  }
}
