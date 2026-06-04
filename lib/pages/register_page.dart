import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../api_config.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> register() async {
    print("===== REGISTER CLICK =====");

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": usernameController.text,
          "password": passwordController.text,
        }),
      );

      print("REGISTER STATUS = ${response.statusCode}");
      print("REGISTER BODY = ${response.body}");

      final data = jsonDecode(response.body);

      if (data["success"] == true) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("註冊成功")));

        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(data["message"])));
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("註冊")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: "帳號"),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "密碼"),
            ),

            const SizedBox(height: 30),

            ElevatedButton(onPressed: register, child: const Text("建立帳號")),
          ],
        ),
      ),
    );
  }
}
