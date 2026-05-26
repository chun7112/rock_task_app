import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:rock_task_app/api_config.dart';

class AddTaskPage extends StatefulWidget {
  final Function(Map<String, dynamic>) onAddTask;

  const AddTaskPage({super.key, required this.onAddTask});

  @override
  _AddTaskPageState createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  TextEditingController controller = TextEditingController();

  String selectedType = "daily"; // 👈 新增這行（控制選單）

  List<int> selectedDays = []; // 🔥 自訂星期（1~7）
  String? selectedDate;

  List<String> recommendTasks = [];

  Future<void> fetchRecommend(String keyword) async {
    try {
      // 🔥 把關鍵字轉成你 Flask 用的
      String goal = "other";

      if (keyword.contains("睡") || keyword.contains("晚")) {
        goal = "sleep";
      } else if (keyword.contains("運動") ||
          keyword.contains("健身") ||
          keyword.contains("減肥")) {
        goal = "exercise";
      } else if (keyword.contains("讀") ||
          keyword.contains("書") ||
          keyword.contains("學") ||
          keyword.contains("學習") ||
          keyword.contains("唸")) {
        goal = "study";
      }

      final response = await http.get(
        Uri.parse("$baseUrl/recommend/${Uri.encodeComponent(keyword)}"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          recommendTasks = List<String>.from(data["tasks"]);
        });
      }
    } catch (e) {
      print("API error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true, //
        title: Text("新增任務"),
        automaticallyImplyLeading: true,
        // actions: [
        //   IconButton(
        //     icon: Icon(Icons.arrow_back_rounded),
        //     onPressed: () {
        //       Navigator.pop(context); // 👈 手動離開
        //     },
        //   ),
        // ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          // 🔥 加這個
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.08, // 🔥 自適應
              vertical: 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch, // 🔥 撐滿寬度
              children: [
                // 輸入框
                TextField(
                  controller: controller,
                  onChanged: (text) {
                    if (text.isNotEmpty) {
                      fetchRecommend(text);
                    }
                    // 🔥 情況2：刪掉或太短 → 清空推薦
                    else {
                      setState(() {
                        recommendTasks.clear();
                      });
                    }
                  },
                  decoration: InputDecoration(
                    hintText: "輸入任務",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8), // 🔥 圓一點更好看
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16, // 🔥 左右空間（重點）
                      vertical: 12,
                    ),
                  ),
                ),

                SizedBox(height: 20),

                // 🔥 推薦任務列表（橫排 + 自動換行）
                if (recommendTasks.isNotEmpty) ...[
                  SizedBox(height: 10),

                  Wrap(
                    spacing: 10, // 👉 左右間距
                    runSpacing: 10, // 👉 上下間距
                    children: recommendTasks.map((task) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            controller.text = task;
                            recommendTasks.clear();
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(
                              20,
                            ), // 👉 圓角（重點🔥）
                          ),
                          child: Text(task, style: TextStyle(fontSize: 13)),
                        ),
                      );
                    }).toList(),
                  ),
                ],
                SizedBox(height: 12),

                // 🔥👇 這就是你消失的「每日 / 單次選單」
                Center(
                  child: SizedBox(
                    width: 60, // 🔥 控制整體大小（可調 140~200）
                    child: DropdownButton<String>(
                      value: selectedType,
                      isExpanded: true, // 保留讓內容不擠
                      underline: Container(),
                      items: [
                        DropdownMenuItem(value: "daily", child: Text("每日")),
                        DropdownMenuItem(value: "one-time", child: Text("單次")),
                        DropdownMenuItem(value: "custom", child: Text("自訂重複")),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedType = value!;
                        });
                      },
                    ),
                  ),
                ),

                // ✅ 單次任務 → 顯示日期選擇器
                if (selectedType == "one-time") ...[
                  SizedBox(height: 20),

                  CalendarDatePicker(
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                    onDateChanged: (date) {
                      setState(() {
                        selectedDate = date.toString().substring(0, 10);
                      });
                    },
                  ),
                ],
                SizedBox(height: 20),

                // 🔥 自訂星期選擇（只有 custom 才顯示）
                if (selectedType == "custom") ...[
                  Text(" 每週", style: TextStyle(fontSize: 16)),

                  SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: List.generate(7, (index) {
                      int day = index + 1;

                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 2),
                        child: ChoiceChip(
                          label: Text(
                            ["一", "二", "三", "四", "五", "六", "日"][index],
                            style: TextStyle(fontSize: 13),
                          ),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap, // 🔥 不要膨脹
                          visualDensity: VisualDensity.compact,
                          selected: selectedDays.contains(day),
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                selectedDays.add(day);
                              } else {
                                selectedDays.remove(day);
                              }
                            });
                          },
                        ),
                      );
                    }),
                  ),
                ],

                SizedBox(height: 30),

                // 新增按鈕
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 25, // 🔥 控制寬
                        vertical: 10, // 🔥 控制高
                      ),
                      minimumSize: Size(0, 0), // 🔥 不強制放大
                      tapTargetSize:
                          MaterialTapTargetSize.shrinkWrap, // 🔥 去多餘空間
                    ),
                    onPressed: () async {
                      // 🔥 空白防呆
                      if (controller.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "請輸入任務名稱",
                              style: TextStyle(color: Colors.white),
                            ),
                            duration: Duration(seconds: 1),
                            backgroundColor: const Color.fromARGB(
                              255,
                              239,
                              74,
                              20,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                        return;
                      }

                      // ✅ 👉🔥 新增這段（單次任務選日期）
                      if (selectedType == "one-time" && selectedDate == null) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text("請選擇日期")));
                        return;
                      }

                      // 🔥🔥 加在這裡（限制至少選一天）
                      if (selectedType == "custom" && selectedDays.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "請至少選擇一天",
                              style: TextStyle(color: Colors.white),
                            ),
                            duration: Duration(seconds: 1),
                            backgroundColor: Color.fromARGB(255, 239, 74, 20),
                          ),
                        );
                        return;
                      }

                      if (selectedType == "custom" &&
                          selectedDays.length == 7) {
                        selectedType = "daily";
                        selectedDays.clear(); // 可選：清掉，避免殘留資料
                      }

                      final newTask = {
                        "title": controller.text,
                        "type": selectedType,
                        "customDays": List<int>.from(selectedDays),
                        "doneDates": [],
                        "hiddenDates": [],
                        "createdDate": DateTime.now().toString(),
                        "date": selectedDate,
                      };

                      // 👉 新增任務
                      widget.onAddTask(newTask);

                      // 👉 清空輸入
                      controller.clear();

                      // 👉 成功提示
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "新增成功",
                            style: TextStyle(color: Colors.white),
                          ),
                          duration: Duration(milliseconds: 800),
                          backgroundColor: const Color.fromARGB(
                            255,
                            246,
                            179,
                            36,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    },
                    child: Text("新增", style: TextStyle(fontSize: 14)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
