import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/task_page.dart';
import 'pages/shop_page.dart';
import 'pages/calendar_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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

  String equippedRock = "assets/rock/rock01.png";
  String? equippedHat;
  String? equippedEyes;

  Future<void> saveEquip() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('equippedRock', equippedRock);
    await prefs.setString('equippedHat', equippedHat ?? '');
    await prefs.setString('equippedEyes', equippedEyes ?? '');
  }

  Future<void> loadEquip() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      equippedRock = prefs.getString('equippedRock') ?? "assets/rock/rock01.png";

      String hat = prefs.getString('equippedHat') ?? '';
      String eyes = prefs.getString('equippedEyes') ?? '';

      equippedHat = hat.isEmpty ? null : hat;
      equippedEyes = eyes.isEmpty ? null : eyes;
    });
  }

  @override
  void initState() {
    super.initState();
    loadEquip(); // 👈 載入裝備
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      TaskPage(
        points: points,
        onPointsChanged: (newPoints) {
          setState(() {
            points = newPoints;
          });
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
      },
      onEquip: (rock, hat, eyes) {
        setState(() {
          if (rock != null)  {
            equippedRock = rock;
          }

          equippedHat = hat;
          equippedEyes = eyes;  
        });
        saveEquip();
      },
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
          BottomNavigationBarItem(icon: Icon(Icons.check), label: "任務"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: "月曆"),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: "商店"),
        ],
      ),
    );
  }
}
