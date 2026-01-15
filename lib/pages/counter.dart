import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Counter {
  static final Counter instance = Counter._();
  Counter._();

  final ValueNotifier<int> count = ValueNotifier<int>(0);
  int get currentValue => count.value;

  // 初始化：由 main.dart 呼叫，確保啟動時載入
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    count.value = prefs.getInt('lucky_tickets') ?? 0;
  }

  // 對應計時器完成時呼叫的方法
  void increment() {
    count.value++;
    _saveToDisk();
  }

  // 轉盤抽獎時呼叫
  void useTicket() {
    if (count.value > 0) {
      count.value--;
      _saveToDisk();
    }
  }

  Future<void> _saveToDisk() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('lucky_tickets', count.value);
  }
}