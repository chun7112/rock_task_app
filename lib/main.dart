import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/task_page.dart';
import 'pages/shop_page.dart';
import 'pages/calendar_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:rock_task_app/api_config.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 255, 247, 208),
        ),
      ),
      home: MainPage(),
    );
  }
}

/// 🌟 主頁（控制 points）
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int currentIndex = 0;
  int points = 0;

  Future<void> savePoints() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('points', points);
  }

  // 🔥 載入 points
  Future<void> loadPoints() async {
    final prefs = await SharedPreferences.getInstance();
    points = prefs.getInt('points') ?? 0;
  }

  Widget buildPoint(int p) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.diamond, size: 18, color: Colors.orange),
        SizedBox(width: 4),
        Text("$p pt"),
      ],
    );
  }

  String rockName = "";

  String equippedRock = "assets/rock/rock01.png";
  String? equippedHat;
  String? equippedEyes;

  // Future<void> loadPoints() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   points = prefs.getInt('points') ?? 0;
  // }

  Future<void> saveEquip() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('equippedRock', equippedRock);
    await prefs.setString('equippedHat', equippedHat ?? '');
    await prefs.setString('equippedEyes', equippedEyes ?? '');
  }

  Future<void> saveRockName() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('rockName', rockName);
  }

  Future<void> loadEquip() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      equippedRock =
          prefs.getString('equippedRock') ?? "assets/rock/rock01.png";

      String hat = prefs.getString('equippedHat') ?? '';
      String eyes = prefs.getString('equippedEyes') ?? '';

      equippedHat = hat.isEmpty ? null : hat;
      equippedEyes = eyes.isEmpty ? null : eyes;
      rockName = prefs.getString('rockName') ?? "我的俗頭";
    });
  }

  @override
  void initState() {
    super.initState();
    loadEquip(); // 👈 載入裝備
    loadPoints();
    checkDailyQuote();
  }

  Future<void> checkDailyQuote() async {
    final prefs = await SharedPreferences.getInstance();

    String today = DateTime.now().toString().substring(0, 10);
    String? lastShown = prefs.getString("last_quote_date");

    // 👉 如果今天還沒顯示過
    if (lastShown != today) {
      List<String> fallbackQuotes = [
        "今天也要加油 💪",
        "慢慢來也沒關係",
        "你已經很努力了"
      ];

      String quote = fallbackQuotes[Random().nextInt(fallbackQuotes.length)];

      try {
        final response = await http.get(Uri.parse("$baseUrl/quote"));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          quote = data["quote"];
        }
      } catch (e) {
        print("quote error: $e");
        // 👉 失敗就用 fallback（不用做事）
      }

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("每日一句"),
          content: Text(quote),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("知道了"),
            ),
          ],
        ),
      );

      // 👉 記錄今天已顯示
      await prefs.setString("last_quote_date", today);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      TaskPage(
        points: points,

        // 🔥👇 一定要加這兩個
        rockName: rockName,
        onRockNameChanged: (newName) {
          setState(() {
            rockName = newName;
          });
          saveRockName(); // 🔥 存本地
        },

        onPointsChanged: (newPoints) {
          setState(() {
            points = newPoints;
          });
          savePoints();
        },

        equippedRock: equippedRock,
        equippedHat: equippedHat,
        equippedEyes: equippedEyes,
      ),
      CalendarPage(),
      ShopPage(
        points: points,
        onPointsChanged: (newPoints) {
          setState(() {
            points = newPoints;
          });
          savePoints();
        },
        onEquip: (rock, hat, eyes) {
          setState(() {
            if (rock != null) {
              equippedRock = rock;
            }

            equippedHat = hat;
            equippedEyes = eyes;
          });
          saveEquip();
        },

        buildPoint: buildPoint,

        equippedRock: equippedRock,
        equippedHat: equippedHat,
        equippedEyes: equippedEyes,
      ),
    ];

    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.checklist_rtl_rounded),
            label: "任務",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_rounded),
            label: "月曆",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_grocery_store_rounded),
            label: "商店",
          ),
        ],
      ),
    );
  }
}
