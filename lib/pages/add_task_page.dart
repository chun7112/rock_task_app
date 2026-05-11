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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("新增任務"),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () {
              Navigator.pop(context); // 👈 手動離開
            },
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // 輸入框
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: "輸入任務",
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 20),

            // 🔥👇 這就是你消失的「每日 / 單次選單」
            DropdownButton<String>(
              value: selectedType,
              items: [
                DropdownMenuItem(
                  value: "daily",
                  child: Text("每日"),
                ),
                DropdownMenuItem(
                  value: "one-time",
                  child: Text("單次"),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  selectedType = value!;
                });
              },
            ),

            SizedBox(height: 20),

            // 新增按鈕
            ElevatedButton(
              onPressed: () {

                // 🔥 空白防呆
                if (controller.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("請輸入任務名稱",style: TextStyle(color: Colors.white)),
                      duration: Duration(seconds: 1),
                      backgroundColor: const Color.fromARGB(255, 239, 74, 20),
                      shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    ),
                  );
                  return;
                }

                final newTask = {
                  "title": controller.text,
                  "type": selectedType,
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
                    content: Text("新增成功",style: TextStyle(color: Colors.white)),
                    duration: Duration(milliseconds: 800),
                    backgroundColor: const Color.fromARGB(255, 246, 179, 36),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              },
              child: Text("新增"),
            ),
          ],
        ),
      ),
    );
  }
}
