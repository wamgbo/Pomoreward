import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'counter.dart';

class Prize {
  String name;
  final Color color;
  final IconData icon;

  Prize({required this.name, required this.color, required this.icon});

  Map<String, dynamic> toMap() => {'name': name, 'color': color.value, 'icon': icon.codePoint};
  factory Prize.fromMap(Map<String, dynamic> map) => Prize(
    name: map['name'],
    color: Color(map['color']),
    icon: IconData(map['icon'], fontFamily: 'MaterialIcons'),
  );
}

class FortuneWheelPage extends StatefulWidget {
  const FortuneWheelPage({super.key});
  @override
  State<FortuneWheelPage> createState() => _FortuneWheelPageState();
}

class _FortuneWheelPageState extends State<FortuneWheelPage> {
  final StreamController<int> controller = StreamController<int>();
  bool _spinning = false;
  int _lastIndex = 0;

  List<Prize> prizeSettings = [
    Prize(name: '吃大餐', color: Colors.orange, icon: Icons.stars),
    Prize(name: '喝杯飲料', color: Colors.blue, icon: Icons.card_giftcard),
    Prize(name: '打電動20分鐘', color: Colors.green, icon: Icons.coffee),
    Prize(name: '滑5分鐘手機', color: Colors.grey, icon: Icons.emoji_emotions),
  ];

  List<Prize> myInventory = [];

  @override
  void initState() {
    super.initState();
    _loadPageData();
  }

  void _loadPageData() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? savedInv = prefs.getStringList('my_inventory');
    List<String>? savedNames = prefs.getStringList('prize_names');

    if (!mounted) return;
    setState(() {
      if (savedInv != null) {
        myInventory = savedInv.map((e) => Prize.fromMap(jsonDecode(e))).toList();
      }
      if (savedNames != null) {
        for (int i = 0; i < prizeSettings.length && i < savedNames.length; i++) {
          prizeSettings[i].name = savedNames[i];
        }
      }
    });
  }

  void _savePageData() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> invRaw = myInventory.map((p) => jsonEncode(p.toMap())).toList();
    await prefs.setStringList('my_inventory', invRaw);
    List<String> nameSettings = prizeSettings.map((p) => p.name).toList();
    await prefs.setStringList('prize_names', nameSettings);
  }

  void _showEditDialog() {
    List<TextEditingController> controllers = prizeSettings.map((p) => TextEditingController(text: p.name)).toList();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("修改獎品名稱"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(4, (i) => TextField(
            controller: controllers[i],
            decoration: InputDecoration(labelText: "獎項 ${i + 1}"),
          )),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("取消")),
          ElevatedButton(onPressed: () {
            setState(() {
              for (int i = 0; i < 4; i++) prizeSettings[i].name = controllers[i].text;
            });
            _savePageData();
            Navigator.pop(ctx);
          }, child: const Text("儲存")),
        ],
      ),
    );
  }

  void _spin() {
    if (_spinning || Counter.instance.currentValue <= 0) return;
    setState(() {
      _spinning = true;
      _lastIndex = Random().nextInt(4);
      Counter.instance.useTicket();
    });
    controller.add(_lastIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("幸運抽獎"),
        actions: [
          IconButton(icon: const Icon(Icons.settings), onPressed: _showEditDialog),
          IconButton(
            icon: const Icon(Icons.shopping_bag), 
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (ctx) => InventoryPage(
              inventory: myInventory, 
              onUse: (index) {
                setState(() => myInventory.removeAt(index));
                _savePageData();
              }
            )))
          ),
        ],
      ),
      body: Column(
        children: [
          ValueListenableBuilder<int>(
            valueListenable: Counter.instance.count,
            builder: (_, val, __) => Padding(
              padding: const EdgeInsets.all(16.0),
              child: Chip(label: Text("剩餘次數: $val", style: const TextStyle(fontWeight: FontWeight.bold))),
            ),
          ),
          Expanded(
            child: FortuneWheel(
              selected: controller.stream,
              animateFirst: false,
              items: prizeSettings.map((p) => FortuneItem(
                child: Text(p.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style: FortuneItemStyle(color: p.color),
              )).toList(),
              onAnimationEnd: () {
                setState(() {
                  _spinning = false;
                  myInventory.add(prizeSettings[_lastIndex]);
                });
                _savePageData();
                _showResult(prizeSettings[_lastIndex]);
              },
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: _spinning ? null : _spin, child: const Text("抽獎")),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  void _showResult(Prize p) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("🎊 恭喜！"),
        content: Text("獲得了「${p.name}」！已放入背包。"),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("確定"))],
      ),
    );
  }
}

// 💡 修改後的卡片盒設計背包頁面（支援即時移除卡片）
class InventoryPage extends StatefulWidget {
  final List<Prize> inventory;
  final Function(int) onUse; // 這是外層傳進來更新 SharedPreferences 的邏輯

  const InventoryPage({super.key, required this.inventory, required this.onUse});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("我的背包 (${widget.inventory.length})"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: widget.inventory.isEmpty
          ? const Center(
              child: Text("背包是空的，快去抽獎吧！", 
              style: TextStyle(color: Colors.grey, fontSize: 16)))
          : GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,      // 一行兩個卡片
                childAspectRatio: 0.75, // 調整卡片長寬比，讓內容不擁擠
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: widget.inventory.length,
              itemBuilder: (ctx, i) {
                final item = widget.inventory[i];
                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 物品圖標
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: item.color.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(item.icon, color: item.color, size: 45),
                      ),
                      const SizedBox(height: 10),
                      // 物品名稱
                      Text(
                        item.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 15),
                      // 使用按鈕
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(horizontal: 25),
                        ),
                        onPressed: () {
                          _confirmUse(context, i, item.name);
                        },
                        child: const Text("使用"),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  // 彈出確認對話框
  void _confirmUse(BuildContext context, int index, String itemName) {
    showDialog(
      context: context,
      builder: (alertCtx) => AlertDialog(
        title: const Text("物品使用"),
        content: Text("確定要使用「$itemName」嗎？"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(alertCtx),
            child: const Text("取消"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(alertCtx); // 關閉對話框
              
              // 執行外層傳入的刪除邏輯（更新 SharedPreferences）
              widget.onUse(index);
              
              // 💡 關鍵：通知當前頁面 UI 刷新，卡片會立刻消失
              setState(() {}); 

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("您已成功使用：$itemName！"), duration: const Duration(seconds: 1)),
              );
            },
            child: const Text("確定使用"),
          ),
        ],
      ),
    );
  }
}