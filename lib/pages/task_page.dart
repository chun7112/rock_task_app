import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'add_task_page.dart';

class TaskPage extends StatefulWidget {
  final int points;
  final String? equippedRock;
  final String? equippedHat;
  final String? equippedEyes;
  final Function(int) onPointsChanged;

  const TaskPage({
    super.key,
    required this.points,
    required this.onPointsChanged, // 🔥 這行是關鍵
    this.equippedRock,
    this.equippedHat,
    this.equippedEyes,
  });

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  List<Map<String, dynamic>> tasks = [];
  DateTime selectedDate = DateTime.now();

  int weekOffset = 0;

  void goToToday() {
    setState(() {
      selectedDate = DateTime.now();
      weekOffset = 0; // 👈 很重要：週也要歸零
    });
  }

  Widget buildCalendar() {
    DateTime baseWeek =
      selectedDate.subtract(Duration(days: selectedDate.weekday - 1));

    DateTime startOfWeek =
        baseWeek.add(Duration(days: weekOffset * 7));
          

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(7, (index) {
        DateTime day = startOfWeek.add(Duration(days: index));
        bool isSelected = isSameDay(day.toString(), selectedDate);

        return GestureDetector(
          onTap: () {
            setState(() {
              selectedDate = day;
            });
          },
          child: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected ? Colors.orange : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Text(
                  ["一", "二", "三", "四", "五", "六", "日"][index],
                ),
                Text("${day.day}"),
              ],
            ),
          ),
        );
      }),
    );
  }

  String? equippedHat;
  String? equippedEyes;

  

  int getTodayTotalTasks() {
    return tasks.where((task) {
      if (task["hiddenDates"] != null &&
          task["hiddenDates"].contains(getDateKey(selectedDate))) {
        return false;
      }

      if (task["type"] == "one-time" &&
          task["createdDate"] != null &&
          !isSameDay(task["createdDate"], selectedDate)) {
        return false;
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

  /// 存 tasks（points 不存了，交給 MainPage）
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
      }
    }

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    loadTasks();

    // 🔥 測試用（之後會改成商店控制）
    equippedHat = 'assets/rock2.png';
    equippedEyes = 'assets/rock3.png';
  }

  String getDateKey(DateTime date) {
    return "${date.year}-${date.month}-${date.day}";
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
      appBar: AppBar(title: Text("俗頭養成記")),

      floatingActionButton: FloatingActionButton(
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
        child: Icon(Icons.add),
      ),

      body: Column(
        children: [
          SizedBox(
            width: 330,
            height: 330,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.asset(
                  widget.equippedRock ?? 'assets/rock/rock01.png',
                ),

                if (widget.equippedEyes != null)
                  Image.asset(widget.equippedEyes!),

                if (widget.equippedHat != null)
                  Image.asset(widget.equippedHat!),
              ],
            ),
          ),

          SizedBox(height: 10),

          Text("點數：${widget.points}", style: TextStyle(fontSize: 20)),

          SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              // 👈 上一週
              IconButton(
                icon: Icon(Icons.arrow_left),
                onPressed: () {
                  setState(() {
                    weekOffset--;
                  });
                },
              ),

              // 👇 日曆（只留這一個）
              Expanded(
                child: buildCalendar(),
              ),

              // 👉 下一週
              IconButton(
                icon: Icon(Icons.arrow_right),
                onPressed: () {
                  setState(() {
                    weekOffset++;
                  });
                },
              ),
            ],
          ),

          if (!isSameDay(DateTime.now().toString(), selectedDate))
            ElevatedButton(
              onPressed: goToToday,
              child: Text("今天"),
            ),

          SizedBox(height: 10),

          Text(
            "今日完成：${getTodayDoneTasks()} / ${getTodayTotalTasks()}",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            color: getTodayDoneTasks() == getTodayTotalTasks()
              ? const Color.fromARGB(255, 234, 157, 4)
              : Colors.black,
            ),
          ),

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

                // 🔥 單次任務只顯示建立當天
                if (task["type"] == "one-time" &&
                    task["createdDate"] != null &&
                    !isSameDay(task["createdDate"], selectedDate)) {
                  return SizedBox();
                }

                bool isDone = task["doneDates"].contains(todayKey);

                return Dismissible(
                  key: Key(task["title"] + index.toString()),

                  onDismissed: (direction) {
                    setState(() {
                      if (task["type"] == "daily") {
                        // 👉 每日任務：只隱藏今天
                        task["hiddenDates"].add(todayKey);
                      } else {
                        // 👉 單次任務：真的刪掉
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
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // 🔥 類型標籤（每日 / 單次）
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(task["type"] == "daily" ? "每日" : "單次"),
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
                            children: [
                              Text("10pt"),
                              IconButton(
                                icon: Icon(Icons.check),
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
