import 'package:flutter/material.dart';
import 'dart:convert'; // Thêm dòng này để sử dụng jsonEncode và jsonDecode
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/pages/loginregister/register.dart';
import 'package:flutter_application_1/pages/home/user_home.dart';
import 'package:flutter_application_1/pages/home/admin_home.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController usernameController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    // Hàm gọi API đăng nhập
    Future<void> login(String username, String password) async {
      final url = Uri.parse('http://10.0.2.2:8081/api/auth/login');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'passwordHash': password,
        }),
      );

      if (response.statusCode == 200) {
        // API trả về Bearer Token dưới dạng văn bản
        String token = response.body;

        // Bạn có thể lưu token vào bộ nhớ cục bộ hoặc biến toàn cục nếu cần thiết
        print('Received token: $token');

        // Tạm thời giả định rằng bạn sẽ dựa vào username để điều hướng
        if (username == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AdminHomePage()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const UserHomePage()),
          );
        }
      } else {
        // Xử lý lỗi đăng nhập
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login failed!')),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Gọi hàm đăng nhập với dữ liệu từ người dùng
                login(usernameController.text, passwordController.text);
              },
              child: const Text('Login'),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text("Don't have an account? "),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const RegisterPage()),
                    );
                  },
                  child: const Text('Register'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
