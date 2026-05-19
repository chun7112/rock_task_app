import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime currentMonth = DateTime.now();
  DateTime selectedDate = DateTime.now();

  List<Map<String, dynamic>> tasks = [];

  List<DateTime?> getDaysInMonth() {
    DateTime firstDay = DateTime(currentMonth.year, currentMonth.month, 1);

    int totalDays = DateTime(currentMonth.year, currentMonth.month + 1, 0).day;

    // 🔥 讓週日當第一天
    int startWeekday = firstDay.weekday % 7;

    List<DateTime?> days = [];

    // 🔥 前面補空格
    for (int i = 0; i < startWeekday; i++) {
      days.add(null);
    }

    // 🔥 加入真正日期
    for (int i = 0; i < totalDays; i++) {
      days.add(firstDay.add(Duration(days: i)));
    }

    return days;
  }

  Future<void> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString('tasks');

    if (data != null) {
      tasks = List<Map<String, dynamic>>.from(jsonDecode(data));

      for (var task in tasks) {
        task["doneDates"] ??= [];
        task["hiddenDates"] ??= [];

        // 🔥 防 customDays 型別炸掉
        task["customDays"] = (task["customDays"] ?? [])
            .map((e) => int.parse(e.toString()))
            .toList();
      }
    }

    setState(() {});
  }

  bool hasTaskOnDay(DateTime day) {
    String dayKey = "${day.year}-${day.month}-${day.day}";

    for (var task in tasks) {
      // 🔥 被隱藏就跳過
      if ((task["hiddenDates"] ?? []).contains(dayKey)) {
        continue;
      }

      // 🔥 單次任務
      if (task["type"] == "one-time") {
        if (task["date"] == null) continue;

        String dayKey = "${day.year}-${day.month}-${day.day}";

        if (task["date"] == dayKey) {
          return true;
        }
      }

      // 🔥 每日任務
      if (task["type"] == "daily") {
        return true;
      }

      // 🔥 自訂任務
      if (task["type"] == "custom") {
        List<int> days = List<int>.from(task["customDays"] ?? []);
        int weekday = day.weekday;

        if (days.contains(weekday)) {
          return true;
        }
      }
    }

    return false;
  }

  bool isAllDoneOnDay(DateTime day) {
    String dayKey = "${day.year}-${day.month}-${day.day}";

    var dayTasks = getTasksForDay(day);

    if (dayTasks.isEmpty) return false;

    int doneCount = 0;

    for (var task in dayTasks) {
      if ((task["doneDates"] ?? []).contains(dayKey)) {
        doneCount++;
      }
    }

    return doneCount == dayTasks.length;
  }

  List<Map<String, dynamic>> getTasksForDay(DateTime day) {
    String dayKey = "${day.year}-${day.month}-${day.day}";

    return tasks.where((task) {
      // 🔥 防呆
      task["doneDates"] ??= [];
      task["hiddenDates"] ??= [];

      // 🔥 被隱藏 → 不顯示
      if (task["hiddenDates"].contains(dayKey)) {
        return false;
      }

      // 🔥 單次任務（用選擇的 date）
      if (task["type"] == "one-time") {
        if (task["date"] == null) return false;

        String dayKey = "${day.year}-${day.month}-${day.day}";

        return task["date"] == dayKey;
      }

      // 🔥 每日任務
      if (task["type"] == "daily") {
        return true;
      }

      // 🔥 自訂任務
      if (task["type"] == "custom") {
        List<int> days = List<int>.from(task["customDays"] ?? []);
        int weekday = day.weekday;

        return days.contains(weekday);
      }

      return false;
    }).toList();
  }

  String formatCustomDays(List<int> days) {
    if (days.isEmpty) return "";

    const weekMap = {1: "一", 2: "二", 3: "三", 4: "四", 5: "五", 6: "六", 7: "日"};

    // 排序（避免亂序）
    days.sort();

    // 轉文字
    List<String> result = days.map((d) => weekMap[d]!).toList();

    return "每週" + result.join("、");
  }

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    var days = getDaysInMonth();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true, // 🔥 加這行
        title: Text("任務月曆"),
      ),

      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16), // 🔥 左右留白
          child: Column(
            children: [
              // 👇 月份切換
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16), // 🔥 這裡控制上下
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_left),
                      onPressed: () {
                        setState(() {
                          currentMonth = DateTime(
                            currentMonth.year,
                            currentMonth.month - 1,
                          );
                        });
                      },
                    ),

                    // 🔥 中間改成 Column（加今天按鈕）
                    Column(
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
                                // 🔥 跳到該月份
                                currentMonth = DateTime(
                                  picked.year,
                                  picked.month,
                                );

                                // 🔥 選取該日期
                                selectedDate = picked;
                              });
                            }
                          },

                          child: Row(
                            mainAxisSize: MainAxisSize.min, // 🔥 不要撐滿
                            children: [
                              Text(
                                "${currentMonth.year} 年 ${currentMonth.month} 月",
                                style: TextStyle(
                                  fontSize: 20,
                                  // fontWeight: FontWeight.bold,
                                ),
                              ),

                              SizedBox(width: 4),

                              Icon(Icons.keyboard_arrow_down, size: 22),
                            ],
                          ),
                        ),

                        SizedBox(height: 4),

                        TextButton(
                          onPressed: () {
                            setState(() {
                              DateTime now = DateTime.now();
                              currentMonth = DateTime(now.year, now.month);
                              selectedDate = now;
                            });
                          },
                          child: Text("今天"),
                        ),
                      ],
                    ),

                    IconButton(
                      icon: Icon(Icons.arrow_right),
                      onPressed: () {
                        setState(() {
                          currentMonth = DateTime(
                            currentMonth.year,
                            currentMonth.month + 1,
                          );
                        });
                      },
                    ),
                  ],
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: ["日", "一", "二", "三", "四", "五", "六"]
                    .map(
                      (d) => Expanded(
                        child: Center(
                          child: Text(
                            d,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),

              // 👇 月曆 + 任務列表（要撐滿剩餘空間）
              Expanded(
                child: Column(
                  children: [
                    // 👇 月曆（自動高度，不滑動）
                    GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.02,
                        vertical: 8,
                      ),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        childAspectRatio: 1,
                      ),
                      itemCount: days.length,
                      itemBuilder: (context, index) {
                        DateTime? day = days[index];

                        if (day == null) {
                          return SizedBox();
                        }

                        bool isToday =
                            day.year == DateTime.now().year &&
                            day.month == DateTime.now().month &&
                            day.day == DateTime.now().day;

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
                            margin: EdgeInsets.all(
                              MediaQuery.of(context).size.width *
                                  0.01, // 🔥 原本6 → 改比例
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color.fromRGBO(255, 203, 89, 1)
                                  : isToday
                                  ? const Color.fromARGB(255, 255, 244, 220)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // 日期
                                Center(
                                  child: Text(
                                    "${day.day}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: isSelected
                                          ? Colors.white
                                          : isToday
                                          ? Colors.orange
                                          : Colors.black87,
                                    ),
                                  ),
                                ),

                                // 🔥 點點
                                Positioned(
                                  bottom: 2,
                                  child: () {
                                    if (!hasTaskOnDay(day)) {
                                      return SizedBox();
                                    }

                                    // 🔥 全部完成 → 顯示 ✔
                                    if (isAllDoneOnDay(day)) {
                                      return Icon(
                                        Icons.check_rounded,
                                        size: 14,
                                        color: Colors.orange,
                                      );
                                    }

                                    // 🔥 未完成 → 顯示點點
                                    return Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: Colors.orange,
                                        shape: BoxShape.circle,
                                      ),
                                    );
                                  }(),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    // 👇 任務列表（吃剩下空間）
                    Expanded(
                      child: Builder(
                        builder: (context) {
                          var todayTasks = getTasksForDay(selectedDate);

                          if (todayTasks.isEmpty) {
                            return Center(
                              child: Text(
                                "今天沒有任務",
                                style: TextStyle(color: Colors.grey),
                              ),
                            );
                          }

                          return ListView.builder(
                            itemCount: todayTasks.length,
                            itemBuilder: (context, index) {
                              var task = todayTasks[index];

                              String dayKey =
                                  "${selectedDate.year}-${selectedDate.month}-${selectedDate.day}";

                              bool isDone = (task["doneDates"] ?? []).contains(
                                dayKey,
                              );

                              return Container(
                                margin: EdgeInsets.symmetric(
                                  horizontal:
                                      MediaQuery.of(context).size.width * 0.04,
                                  vertical: 6,
                                ),
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.black12),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // 類型標籤
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8,
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
                                                  task["customDays"] ?? [],
                                                ),
                                              ),
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ),

                                    SizedBox(width: 10),

                                    // 任務名稱
                                    Expanded(
                                      child: Text(
                                        task["title"],
                                        maxLines: 1, // 🔥 防止撐爆
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ),

                                    if (isDone)
                                      Icon(
                                        Icons.check_rounded,
                                        color: Colors.orange,
                                        size: 18,
                                      ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
