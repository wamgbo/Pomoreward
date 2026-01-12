import 'package:flutter/material.dart';
import 'pages/clock.dart';
import 'pages/sandbox.dart';
import 'pages/sandbox2.dart';
import 'pages/testtimer.dart'; // 確保導入 TimerStore

void main() {
  runApp(const MaterialApp(home: MainPage()));
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MyAppState();
}

class _MyAppState extends State<MainPage> {
  int _index = 0;
  final pages = [const sandbox(), const sandbox2(), const Clock()];

  @override
  Widget build(BuildContext context) {
    // 獲取計時器的 Store 實例
    final store = TimerStore.instance;

    return ValueListenableBuilder<Color>(
      valueListenable: store.bgColor, // MainPage 這裡直接聽 Store 的顏色
      builder: (context, currentBgColor, child) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: currentBgColor, // 按下 Start，這裡會立刻變色
            elevation: 0,
            leading: IconButton(
              onPressed: () => print("點擊了圖片"),
              icon: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.asset(
                  "assets/icon_home.png",
                  errorBuilder: (_, __, ___) => const Icon(Icons.home, color: Colors.white),
                ),
              ),
            ),
          ),
          body: pages[_index],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _index,
            onTap: (i) => setState(() => _index = i),
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: '首頁'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: '我的'),
              BottomNavigationBarItem(icon: Icon(Icons.timer), label: '計時器'),
            ],
          ),
        );
      },
    );
  }
}