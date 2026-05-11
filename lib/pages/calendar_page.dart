import 'package:flutter/material.dart';

class CalendarPage extends StatefulWidget {
@override
_CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
DateTime currentMonth = DateTime.now();

List<DateTime> getDaysInMonth() {
DateTime firstDay =
DateTime(currentMonth.year, currentMonth.month, 1);

int totalDays =
DateTime(currentMonth.year, currentMonth.month + 1, 0).day;

return List.generate(totalDays, (index) {
return firstDay.add(Duration(days: index));
 });
 }

@override
Widget build(BuildContext context) {
var days = getDaysInMonth();

return Scaffold(
appBar: AppBar(title: Text("月曆")),
body: Column(
children: [

// 👇 月份切換
Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
IconButton(
icon: Icon(Icons.arrow_left),
onPressed: () {
setState(() {
currentMonth = DateTime(
currentMonth.year, currentMonth.month - 1);
 });
 },
 ),
Text(
"${currentMonth.year} / ${currentMonth.month}",
style: TextStyle(fontSize: 18),
 ),
IconButton(
icon: Icon(Icons.arrow_right),
onPressed: () {
setState(() {
currentMonth = DateTime(
currentMonth.year, currentMonth.month + 1);
 });
 },
 ),
 ],
 ),

// 👇 月曆格子
Expanded(
child: GridView.builder(
padding: EdgeInsets.all(10),
gridDelegate:
SliverGridDelegateWithFixedCrossAxisCount(
crossAxisCount: 7,
 ),
itemCount: days.length,
itemBuilder: (context, index) {
DateTime day = days[index];

return Container(
margin: EdgeInsets.all(4),
decoration: BoxDecoration(
border: Border.all(color: Colors.black),
 ),
child: Center(
child: Text("${day.day}"),
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