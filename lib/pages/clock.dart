import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'testtimer.dart';

class Clock extends StatelessWidget {
  const Clock({super.key});

  @override
  Widget build(BuildContext context) {
    final store = TimerStore.instance;

    return ValueListenableBuilder<Color>(
      valueListenable: store.bgColor,
      builder: (_, bg, __) {
        // 【移除】原本這裡的 MainPage.backgroundColor.value = bg; (不再需要)

        return Container(
          // 這裡改成 Container，因為外層已有 Scaffold
          width: double.infinity,
          height: double.infinity,
          color: bg,
          child: Column(
            children: [
              const SizedBox(height: 150),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  PopupMenuButton<int>(
                    icon: const Icon(Icons.settings, color: Colors.white),
                    offset: const Offset(0, 40),
                    onSelected: (int value) {
                      store.setTime(value);
                      store.mode.value = TimerMode.focus;
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 2, child: Text('test')),
                      PopupMenuItem(value: 1500, child: Text('25 min')),
                      PopupMenuItem(value: 1800, child: Text('30 min')),
                      PopupMenuItem(value: 3000, child: Text('50 min')),
                    ],
                  ),
                ],
              ),
              ValueListenableBuilder<String>(
                valueListenable:
                    store.title, // 確保 store 裡有這個 ValueNotifier<String>
                builder: (_, currentTitle, __) {
                  return Text(
                    currentTitle, // 這裡會隨 store.title.value 改變而即時更新
                    style: const TextStyle(
                      fontSize: 40,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
              ValueListenableBuilder<int>(
                valueListenable: store.seconds,
                builder: (_, sec, __) {
                  final min = (sec ~/ 60).toString().padLeft(2, '0');
                  final s = (sec % 60).toString().padLeft(2, '0');
                  return Text(
                    "$min:$s",
                    style: const TextStyle(fontSize: 80, color: Colors.white),
                  );
                },
              ),
              const SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      store.start(); // 觸發開始
                      // 如果需要按下瞬間立刻變色，確保 store.start() 內部有修改 bgColor.value
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(120, 50),
                      backgroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Text(
                      "Start",
                      style: const TextStyle(fontSize: 30, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: store.stop,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(120, 50),
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Text(
                      "End",
                      style: const TextStyle(fontSize: 30, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
