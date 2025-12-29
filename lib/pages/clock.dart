import 'package:flutter/material.dart';
import 'dart:async';

class Clock extends StatefulWidget {
  const Clock({super.key});
  @override
  State<Clock> createState() => _ClockState(); // 修正了原本的拼字 _ClocState
}

class _ClockState extends State<Clock> {
  int _defaultTime = 1500;
  int _seconds = 1500;
  Timer? _timer;
  Color _bgColor = Colors.blue;
  Color _appColor = Colors.blueGrey;

  // --- Start Timer ---
  void _startTimer() {
    // 1. 防呆：如果 Timer 正在跑，或者頁面已經不在了，直接退出
    if ((_timer?.isActive ?? false) || !mounted) return;

    // 2. 更新 UI 狀態為「開始」
    setState(() {
      _bgColor = Colors.red;
      _appColor = Colors.red;
    });

    // 3. 確保舊的 Timer 被取消 (雖然 isActive 擋住了，但這是好習慣)
    _timer?.cancel();

    // 4. 啟動 Timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // [關鍵修復]：每次 Timer 跳動前，先檢查頁面是否還在
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        if (_seconds > 0) {
          _seconds--;
        } else {
          // 時間到，停止 Timer
          timer.cancel();
          _bgColor = Colors.blue; // 時間到變回藍色
          _appColor = Colors.blue;
        }
      });
    });
  }

  // --- Stop Timer ---
  void _stopTimer() {
    if (!mounted) return;
    
    // 停止 Timer
    _timer?.cancel();
    
    setState(() {
      // 變回藍色，但不重置時間 (保留剩餘時間)
      _bgColor = Colors.blue;
      _appColor = Colors.blue;
    });
  }

  // --- Reset (Optional) ---
  // 如果你需要重置功能，可以把這段加回去
  // void _resetTimer() {
  //   _stopTimer();
  //   setState(() {
  //     _seconds = _defaultTime;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    // 計算分與秒
    String min = (_seconds ~/ 60).toString().padLeft(2, '0');
    String sec = (_seconds % 60).toString().padLeft(2, '0');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: _appColor,
        leading: IconButton(
          onPressed: () {
            print("點擊了圖片");
          },
          icon: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            // 注意：確保 assets/icon_home.png 存在於 pubspec.yaml 中，否則會報錯
            child: Image.asset("assets/icon_home.png", 
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.home), // 防呆：如果找不到圖，顯示 icon
            ),
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: _bgColor, 
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                PopupMenuButton<int>(
                  icon: const Icon(Icons.settings, color: Colors.white), // 設定按鈕顏色，避免在深色背景看不到
                  offset: const Offset(0, 40),
                  onSelected: (value) {
                    // 切換時間設定時，先停止目前的 Timer 比較安全
                    _stopTimer(); 
                    setState(() {
                      _defaultTime = value;
                      _seconds = value;
                    });
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 1500, child: Text('25 min')),
                    PopupMenuItem(value: 1800, child: Text('30 min')),
                    PopupMenuItem(value: 3000, child: Text('50 min')),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 150),
            const Text( // 加 const 優化效能
              "Time to focus",
              style: TextStyle(
                fontSize: 40,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "$min:$sec",
              style: const TextStyle(fontSize: 80, color: Colors.white),
            ),

            const SizedBox(height: 50), // 增加一點間距
            
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _startTimer,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(120, 50),
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 5,
                  ),
                  child: const Text(
                    "Start",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _stopTimer,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(120, 50),
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 5,
                  ),
                  child: const Text(
                    "Stop",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel(); // 銷毀頁面時務必取消 Timer
    super.dispose();
  }
}