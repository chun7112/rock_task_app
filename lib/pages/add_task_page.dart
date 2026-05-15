import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true, //
        title: Text("新增任務"),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.check_rounded),
            onPressed: () {
              Navigator.pop(context); // 👈 手動離開
            },
          ),
        ],
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
                    onPressed: () {
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
