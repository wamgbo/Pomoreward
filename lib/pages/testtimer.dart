// testtimer.dart
import 'dart:async';
import 'package:flutter/material.dart';

enum TimerMode { focus, breakTime }

class TimerStore {
  static final TimerStore instance = TimerStore._();
  TimerStore._();

  Timer? _timer;

  final ValueNotifier<int> seconds = ValueNotifier<int>(1500);
  final ValueNotifier<String> title = ValueNotifier<String>("Time to focus");
  final ValueNotifier<TimerMode> mode =
      ValueNotifier<TimerMode>(TimerMode.focus);
  final ValueNotifier<Color> bgColor =
      ValueNotifier<Color>(Colors.blue);

  void start() {
    if (_timer?.isActive ?? false) return;

    bgColor.value =
        mode.value == TimerMode.focus ? Colors.red : Colors.green;

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (seconds.value > 0) {
        seconds.value--;
      } else {
        _timer?.cancel();

        if (mode.value == TimerMode.focus) {
          mode.value = TimerMode.breakTime;
          seconds.value = 1;
          bgColor.value = Colors.green;
          title.value = "Time to rest";
        } else {
          mode.value = TimerMode.focus;
          seconds.value = 1500;
          bgColor.value = Colors.red;
          title.value = "Time to focus";
        }
      }
    });
  }

  void stop() {
    _timer?.cancel();
    bgColor.value = Colors.blue;
  }

  void setTime(int value) {
    stop();
    seconds.value = value;
  }
}
