import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'add_task_page.dart';
import 'package:http/http.dart' as http;
import '../api_config.dart';
import 'login_page.dart';

class TaskPage extends StatefulWidget {
  final int points;
  final String rockName;
  final Function(String) onRockNameChanged;
  final String? equippedRock;
  final String? equippedHat;
  final String? equippedEyes;
  final String? equippedNeck;
  final String? equippedBody;
  final String? equippedBg;
  final Function(int) onPointsChanged;

  const TaskPage({
    super.key,
    required this.points,
    required this.rockName,
    required this.onRockNameChanged,
    required this.onPointsChanged,
    this.equippedRock,
    this.equippedHat,
    this.equippedEyes,
    this.equippedNeck,
    this.equippedBody,
    this.equippedBg,
  });

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  List<Map<String, dynamic>> tasks = [];
  DateTime selectedDate = DateTime.now();

  String username = "";

  int weekOffset = 0;

  int currentStreak = 0;
  int bestStreak = 0;

  void goToToday() {
    setState(() {
      selectedDate = DateTime.now();
      weekOffset = 0;
    });
  }

  Widget buildCalendar() {
    DateTime baseDate = selectedDate;
    DateTime startOfWeek = baseDate.subtract(
      Duration(days: baseDate.weekday % 7),
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(7, (index) {
          DateTime day = startOfWeek.add(Duration(days: index));
          bool isSelected =
              day.year == selectedDate.year &&
              day.month == selectedDate.month &&
              day.day == selectedDate.day;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedDate = day;
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color.fromARGB(255, 255, 217, 136)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Text(["日", "一", "二", "三", "四", "五", "六"][index]),
                  Text("${day.day}", style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  String? equippedRock;
  String? equippedHat;
  String? equippedEyes;
  String? equippedNeck;
  String? equippedBody;
  String? equippedBg;

  int getTodayTotalTasks() {
    return tasks.where((task) {
      if (task["hiddenDates"] != null &&
          task["hiddenDates"].contains(getDateKey(selectedDate))) {
        return false;
      }

      if (task["type"] == "one-time") {
        if (task["date"] == null) return false;

        String todayStr = getDateKey(selectedDate);

        return task["date"] == todayStr;
      }

      return true;
    }).length;
  }

  int getTodayDoneTasks() {
    return tasks.where((task) {
      String todayKey = getDateKey(selectedDate);
      return (task["doneDates"] ?? []).contains(todayKey);
    }).length;
  }

  Future<void> saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tasks', jsonEncode(tasks));
  }

  Future<void> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString('tasks');

    if (data != null) {
      tasks = List<Map<String, dynamic>>.from(jsonDecode(data));

      for (var task in tasks) {
        task["doneDates"] ??= [];
        task["hiddenDates"] ??= [];
        if (task["type"] == "custom") {
          task["customDays"] = (task["customDays"] ?? [])
              .map((e) => int.parse(e.toString()))
              .toList();
        }
      }
    }

    setState(() {});
  }

  Future<void> loadStreak() async {
    final prefs = await SharedPreferences.getInstance();
    String username = prefs.getString("username") ?? "";

    try {
      final response = await http.get(Uri.parse("$baseUrl/streak/$username"));

      print("status: ${response.statusCode}");
      print("body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          currentStreak = data["current_streak"];
          bestStreak = data["best_streak"];
        });

        print("目前連續: $currentStreak");
        print("最高連續: $bestStreak");
      }
    } catch (e) {
      print("streak error: $e");
    }
  }

  Future<void> loadUsername() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      username = prefs.getString("username") ?? "";
    });
  }

  @override
  void initState() {
    super.initState();

    // ===== 先給預設（防爆）=====
    equippedRock = 'assets/rock/rock01.png';
    equippedHat = null;
    equippedEyes = null;
    equippedNeck = null;
    equippedBody = null;
    equippedBg = null;

    // ===== 再載入資料（會覆蓋）=====
    loadTasks();
    // ===== 讀取連續簽到 =====
    loadStreak();
    loadUsername();
  }

  String getDateKey(DateTime date) {
    String month = date.month.toString().padLeft(2, '0');
    String day = date.day.toString().padLeft(2, '0');

    return "${date.year}-$month-$day";
  }

  String formatCustomDays(List<int> days) {
    List<String> weekMap = ["一", "二", "三", "四", "五", "六", "日"];

    days.sort();

    return "每週" + days.map((d) => weekMap[d - 1]).join("、");
  }

  bool isSameDay(String dateStr, DateTime date) {
    DateTime taskDate = DateTime.parse(dateStr);
    return taskDate.year == date.year &&
        taskDate.month == date.month &&
        taskDate.day == date.day;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,

        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.rockName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(width: 6),

            GestureDetector(
              onTap: () {
                TextEditingController controller = TextEditingController(
                  text: widget.rockName,
                );

                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text("修改名稱"),
                      content: TextField(controller: controller),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text("取消"),
                        ),
                        TextButton(
                          onPressed: () {
                            String newName = controller.text.trim(); // 🔥 去空白

                            if (newName.length > 10) {
                              newName = newName.substring(0, 10);
                            }

                            if (newName.isEmpty) {
                              newName = "我的俗頭"; // 🔥 預設名稱
                            }

                            widget.onRockNameChanged(newName);

                            Navigator.pop(context);
                          },
                          child: Text("確定"),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Icon(Icons.edit, size: 18),
            ),
          ],
        ),

        actions: [
          PopupMenuButton<String>(
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.account_circle),

            onSelected: (value) async {
              if (value == "logout") {
                final prefs = await SharedPreferences.getInstance();

                await prefs.remove("username");

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              }
            },

            itemBuilder: (context) => [
              PopupMenuItem(enabled: false, child: Text("帳號：$username")),

              const PopupMenuDivider(),

              const PopupMenuItem(value: "logout", child: Text("登出")),
            ],
          ),
        ],
      ),

      floatingActionButton: SizedBox(
        width: 56,
        height: 56,
        child: FloatingActionButton(
          onPressed: () async {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddTaskPage(
                  onAddTask: (newTask) {
                    setState(() {
                      tasks.add(newTask);
                    });
                    saveTasks();
                  },
                ),
              ),
            );
          },
          backgroundColor: const Color.fromARGB(255, 255, 217, 136), // 🔥 改顏色
          elevation: 2, // 🔥 陰影變淡（更精緻）
          child: Icon(
            Icons.add_rounded,
            size: 25, // 🔥 icon 也縮小
            color: Colors.black,
          ),
        ),
      ),

      body: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.35, // 🔥 關鍵：控制高度
            child: FittedBox(
              fit: BoxFit.contain,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 🟢 背景（最底）
                  if (widget.equippedBg != null)
                    Image.asset(widget.equippedBg!),

                  // 🟢 石頭（主體）
                  Image.asset(widget.equippedRock ?? 'assets/rock/rock01.png'),

                  // 🟢 身體
                  if (widget.equippedBody != null)
                    Image.asset(widget.equippedBody!),

                  // 🟢 脖子
                  if (widget.equippedNeck != null)
                    Image.asset(widget.equippedNeck!),

                  // 🟢 眼睛
                  if (widget.equippedEyes != null)
                    Image.asset(widget.equippedEyes!),

                  // 🟢 帽子（最上）
                  if (widget.equippedHat != null)
                    Image.asset(widget.equippedHat!),
                ],
              ),
            ),
          ),

          // SizedBox(height: 10),

          // 👇 第一排：日期（左）＋點數（右）
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 🔹 左：日期 + ▼ + 今日
                Row(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );

                        if (picked != null) {
                          setState(() {
                            selectedDate = picked;
                            weekOffset = 0;
                          });
                        }
                      },
                      child: Row(
                        children: [
                          Text(
                            "${selectedDate.year}年${selectedDate.month}月",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Icon(Icons.keyboard_arrow_down, size: 18),
                        ],
                      ),
                    ),

                    SizedBox(width: 8),

                    // 👉 今日（只有不是今天才顯示）
                    if (!isSameDay(DateTime.now().toString(), selectedDate))
                      ElevatedButton(
                        onPressed: goToToday,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: 13,
                            vertical: 8,
                          ), // 🔥 關鍵：縮左右
                          minimumSize: Size(0, 0), // 🔥 不強制撐大
                          tapTargetSize:
                              MaterialTapTargetSize.shrinkWrap, // 🔥 去掉多餘空間
                        ),
                        child: Text("今日", style: TextStyle(fontSize: 12)),
                      ),
                  ],
                ),

                // // 🔹 右：點數
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: [
                //     Icon(Icons.diamond, color: Colors.orange, size: 23),
                //     SizedBox(width: 4),
                //     Text(
                //       "${widget.points} pt",
                //       style: TextStyle(
                //         fontSize: 16,
                //         fontWeight: FontWeight.bold,
                //       ),
                //     ),
                //   ],
                // ),

                // 🔹 右：點數 + streak
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.diamond, color: Colors.orange, size: 23),
                        SizedBox(width: 4),
                        Text(
                          "${widget.points} pt",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 2),

                    Text(
                      "🔥連續 $currentStreak 天",
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 15),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10), // 🔥 整體往內縮
            child: Row(
              children: [
                // 👈 上一週
                IconButton(
                  icon: Icon(Icons.arrow_left),
                  onPressed: () {
                    setState(() {
                      weekOffset--;

                      // 🔥 同步選中的日期（往前7天）
                      selectedDate = selectedDate.subtract(Duration(days: 7));
                    });
                  },
                ),

                // 👇 日曆（只留這一個）
                Expanded(child: buildCalendar()),

                // 👉 下一週
                IconButton(
                  icon: Icon(Icons.arrow_right),
                  onPressed: () {
                    setState(() {
                      weekOffset++;

                      // 🔥 同步選中的日期（往後7天）
                      selectedDate = selectedDate.add(Duration(days: 7));
                    });
                  },
                ),
              ],
            ),
          ),

          SizedBox(height: 15),

          Text(
            "今日完成：${getTodayDoneTasks()} / ${getTodayTotalTasks()}",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: getTodayDoneTasks() == getTodayTotalTasks()
                  ? const Color.fromARGB(255, 234, 157, 4)
                  : Colors.black,
            ),
          ),

          SizedBox(height: 12),

          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.only(bottom: 80),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                var task = tasks[index];
                String todayKey = getDateKey(selectedDate);

                // 🔥 防舊資料炸掉
                task["doneDates"] ??= [];
                task["hiddenDates"] ??= [];

                // 🔥 今天被隱藏就不顯示
                if (task["hiddenDates"].contains(todayKey)) {
                  return SizedBox();
                }

                // 🔥 單次任務 → 用「選擇的日期」
                if (task["type"] == "one-time") {
                  if (task["date"] == null) return SizedBox();

                  String todayStr = getDateKey(selectedDate);

                  if (task["date"] != todayStr) {
                    return SizedBox();
                  }
                }

                if (task["type"] == "custom") {
                  List<int> days = List<int>.from(
                    (task["customDays"] ?? []).map(
                      (e) => int.parse(e.toString()),
                    ),
                  );

                  int weekday = selectedDate.weekday;

                  // 🔥 如果你有用 %7（週日=0），這裡要修正
                  if (weekday == 0) weekday = 7;

                  if (!days.contains(weekday)) {
                    return SizedBox();
                  }
                }

                bool isDone = task["doneDates"].contains(todayKey);

                return Dismissible(
                  key: Key(task["title"] + index.toString()),

                  onDismissed: (direction) {
                    setState(() {
                      if (task["type"] == "daily" || task["type"] == "custom") {
                        // 👉 每日 / 自訂：只隱藏今天
                        task["hiddenDates"].add(todayKey);
                      } else if (task["type"] == "one-time") {
                        // 👉 單次：真的刪掉
                        tasks.removeAt(index);
                      }
                    });
                    saveTasks();
                  },

                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(left: 20),
                    child: Icon(Icons.delete, color: Colors.white),
                  ),

                  child: GestureDetector(
                    onLongPress: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text("刪除任務"),
                          content: Text("確定要永久刪除這個任務嗎？"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text("取消"),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  tasks.removeAt(index);
                                });
                                saveTasks();
                                Navigator.pop(context);
                              },
                              child: Text("刪除"),
                            ),
                          ],
                        ),
                      );
                    },

                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                      padding: EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black12, width: 1.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // 🔥 類型標籤（每日 / 單次）
                          // 🔥 類型標籤（改成顯示內容）
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              task["type"] == "daily"
                                  ? "每日"
                                  : task["type"] == "one-time"
                                  ? "單次"
                                  : formatCustomDays(
                                      List<int>.from(
                                        (task["customDays"] ?? []).map(
                                          (e) => int.parse(e.toString()),
                                        ),
                                      ),
                                    ),
                            ),
                          ),

                          // 任務名稱
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                task["title"],
                                style: TextStyle(
                                  decoration: isDone
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                  color: isDone ? Colors.grey : Colors.black,
                                ),
                              ),
                            ),
                          ),

                          // 按鈕
                          Column(
                            mainAxisSize: MainAxisSize.min, // 🔥 不撐滿高度（超重要）
                            children: [
                              // Text("10pt", style: TextStyle(fontSize: 12)),
                              IconButton(
                                constraints: BoxConstraints(), // 🔥 去掉預設大空間
                                padding: EdgeInsets.zero,
                                icon: Icon(Icons.check_rounded, size: 20),
                                onPressed: () {
                                  if (!isDone) {
                                    setState(() {
                                      task["doneDates"].add(todayKey);
                                    });

                                    widget.onPointsChanged(widget.points + 10);
                                    saveTasks();
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
