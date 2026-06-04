import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'register_page.dart';
import '../api_config.dart';
import '../main.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> login() async {
    print("===== LOGIN CLICK =====");

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": usernameController.text,
          "password": passwordController.text,
        }),
      );

      print("LOGIN STATUS = ${response.statusCode}");
      print("LOGIN BODY = ${response.body}");

      final data = jsonDecode(response.body);

      if (data["success"] == true) {
        // 🔥 儲存登入帳號
        final prefs = await SharedPreferences.getInstance();

        await prefs.setString("username", usernameController.text);

        // 🔥 跳轉主頁
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainPage()),
        );
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
      appBar: AppBar(title: const Text("登入")),
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

            ElevatedButton(onPressed: login, child: const Text("登入")),

            const SizedBox(height: 20),

            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterPage()),
                );
              },
              child: const Text("還沒有帳號？立即註冊"),
            ),
          ],
        ),
      ),
    );
  }
}
