import 'package:flutter/material.dart';
import 'pages/clock.dart';
import 'pages/timer.dart';
import 'pages/happwheel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/counter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  Counter.instance.count.value =
      prefs.getInt('lucky_tickets') ?? 0; //從手機硬碟讀取抽獎次數，如果為空就為0再交給Counter

  runApp(const MaterialApp(home: MainPage()));
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MyAppState();
}

class _MyAppState extends State<MainPage> {
  int _index = 0;
  final pages = [const Clock(), FortuneWheelPage()];

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
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.asset("assets/icon_home.png"),
              ),
            ),
          ),
          body: pages[_index],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _index,
            onTap: (i) => setState(() => _index = i),
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.timer), label: '計時器'),
              BottomNavigationBarItem(icon: Icon(Icons.home), label: '首頁'),
            ],
          ),
        );
      },
    );
  }
}
