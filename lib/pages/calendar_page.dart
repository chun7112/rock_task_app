import 'package:flutter/material.dart';

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime currentMonth = DateTime.now();
  DateTime selectedDate = DateTime.now();

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

  @override
  Widget build(BuildContext context) {
    var days = getDaysInMonth();

    return Scaffold(
      appBar: AppBar(title: Text("${currentMonth.year}年")),
      body: Padding(
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
                      Text(
                        "${currentMonth.month} 月",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: 4),

                      TextButton(
                        onPressed: () {
                          setState(() {
                            DateTime now = DateTime.now();

                            // 🔥 回到今天
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

            // 👇 月曆格子
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  childAspectRatio: 1,
                ),
                itemCount: days.length,
                itemBuilder: (context, index) {
                  DateTime? day = days[index];

                  if (day == null) {
                    return SizedBox(); // 🔥 空白格
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
                      margin: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color.fromRGBO(255, 149, 0, 1) // 選中：橘色
                            : Colors.white,

                        borderRadius: BorderRadius.circular(12),

                        border: Border.all(
                          color: isToday
                              ? const Color.fromRGBO(255, 149, 0, 1) // 今天：橘框
                              : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          "${day.day}",

                          style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
