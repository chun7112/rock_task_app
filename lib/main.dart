import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/task_page.dart';
import 'pages/shop_page.dart';
import 'pages/calendar_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:rock_task_app/api_config.dart';
import 'dart:math';
import 'pages/login_page.dart';

void main() {
  runApp(const MyApp());
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool loading = true;
  bool loggedIn = false;

  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  Future<void> checkLogin() async {
    final prefs = await SharedPreferences.getInstance();

    String? username = prefs.getString("username");

    setState(() {
      loggedIn = username != null && username.isNotEmpty;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (loggedIn) {
      return const MainPage();
    }

    return const LoginPage();
  }
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
      home: const AuthGate(),
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

  int currentStreak = 0;
  int bestStreak = 0;

  String username = "";

  Future<void> savePoints() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('points', points);
  }

  // 🔥 載入 points
  Future<void> loadPoints() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      points = prefs.getInt('points') ?? 0;
    });
  }

  Future<void> loadUsername() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      username = prefs.getString("username") ?? "";
    });

    print("目前登入帳號：$username");
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove("username");

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  Future<void> loadStreak() async {
    final prefs = await SharedPreferences.getInstance();
    String username = prefs.getString("username") ?? "";

    try {
      final response = await http.get(Uri.parse("$baseUrl/streak/$username"));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          currentStreak = data["current_streak"];
          bestStreak = data["best_streak"];
        });
      }
    } catch (e) {
      print("streak error: $e");
    }
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
  String? equippedNeck;
  String? equippedBody;
  String? equippedBg;

  // Future<void> loadPoints() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   points = prefs.getInt('points') ?? 0;
  // }

  Future<void> saveEquip() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('equippedRock', equippedRock);
    await prefs.setString('equippedHat', equippedHat ?? '');
    await prefs.setString('equippedEyes', equippedEyes ?? '');
    await prefs.setString('equippedNeck', equippedNeck ?? '');
    await prefs.setString('equippedBody', equippedBody ?? '');
    await prefs.setString('equippedBg', equippedBg ?? '');
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
      String neck = prefs.getString('equippedNeck') ?? '';
      String body = prefs.getString('equippedBody') ?? '';
      String bg = prefs.getString('equippedBg') ?? '';

      equippedHat = hat.isEmpty ? null : hat;
      equippedEyes = eyes.isEmpty ? null : eyes;
      equippedNeck = neck.isEmpty ? null : neck;
      equippedBody = body.isEmpty ? null : body;
      equippedBg = bg.isEmpty ? null : bg;
      rockName = prefs.getString('rockName') ?? "我的俗頭";
    });
  }

  @override
  void initState() {
    super.initState();
    loadUsername();
    loadEquip();
    loadPoints();
    loadStreak();
    checkDailyQuote();
  }

  Future<void> checkDailyQuote() async {
    final prefs = await SharedPreferences.getInstance();

    String today = DateTime.now().toString().substring(0, 10);
    String? lastShown = prefs.getString("last_quote_date");

    // 今天還沒顯示過
    if (lastShown != today) {
      List<String> fallbackQuotes = ["今天也要加油 💪", "慢慢來也沒關係", "你已經很努力了"];

      // 預設用 fallback（避免 API 爆掉）
      String quote = fallbackQuotes[Random().nextInt(fallbackQuotes.length)];

      try {
        final response = await http.get(Uri.parse("$baseUrl/quote"));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);

          // API 有回才覆蓋
          if (data["quote"] != null) {
            quote = data["quote"];
          }
        }
      } catch (e) {
        print("quote error: $e");
        // 失敗就用 fallback
      }

      // ===== 呼叫後端簽到 API =====
      String username = prefs.getString("username") ?? "";

      try {
        final response = await http.post(
          Uri.parse("$baseUrl/checkin"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"user_id": username}),
        );

        print(response.body);
      } catch (e) {
        print("checkin error: $e");
      }

      // ===== 發簽到獎勵 =====
      int currentPoints = prefs.getInt("points") ?? 0;
      int newPoints = currentPoints + 30;
      await prefs.setInt("points", newPoints);

      await loadPoints();

      // 顯示 Dialog（含獎勵）
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Center(child: Text("歡迎回來～")),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(quote),
              SizedBox(height: 12),
              Text(
                "🎁 今日簽到 +30 pt",
                style: TextStyle(
                  color: const Color.fromARGB(255, 0, 0, 0),
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 8),

              Text(
                "🔥 連續簽到 $currentStreak 天",
                style: TextStyle(color: Colors.grey[700]),
              ),

              SizedBox(height: 4),

              Text(
                "🏆 最高紀錄 $bestStreak 天",
                style: TextStyle(color: Colors.grey[700]),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("知道了"),
            ),
          ],
        ),
      );

      // 記錄今天已顯示（= 已領）
      await prefs.setString("last_quote_date", today);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      TaskPage(
        points: points,
        rockName: rockName,
        onRockNameChanged: (newName) {
          setState(() {
            rockName = newName;
          });
          saveRockName();
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
        equippedNeck: equippedNeck,
        equippedBody: equippedBody,
        equippedBg: equippedBg,
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
        onEquip: (rock, hat, eyes, neck, body, bg) {
          setState(() {
            if (rock != null) {
              equippedRock = rock;
            }

            equippedHat = hat;
            equippedEyes = eyes;
            equippedNeck = neck;
            equippedBody = body;
            equippedBg = bg;
          });
          saveEquip();
        },

        buildPoint: buildPoint,

        equippedRock: equippedRock,
        equippedHat: equippedHat,
        equippedEyes: equippedEyes,
        equippedNeck: equippedNeck,
        equippedBody: equippedBody,
        equippedBg: equippedBg,
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
