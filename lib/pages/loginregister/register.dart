import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // Để sử dụng jsonEncode và jsonDecode

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController usernameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    // Hàm gọi API đăng ký
    Future<void> register(String username, String email, String password) async {
      final url = Uri.parse('http://10.0.2.2:8081/api/auth/register');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'passwordHash': password, // Sử dụng 'passwordHash' cho trường mật khẩu
          'email': email,
        }),
      );

      if (response.statusCode == 200) {
        // Xử lý phản hồi API
        final responseBody = jsonDecode(response.body);

        // Hiển thị thông báo thành công
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration successful! Welcome, ${responseBody['username']}')),
        );

        // Điều hướng về trang đăng nhập hoặc trang chính
        Navigator.pop(context); // Quay lại trang trước đó (có thể là trang đăng nhập)
      } else {
        // Hiển thị thông báo lỗi nếu đăng ký thất bại
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration failed!')),
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
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Gọi hàm đăng ký với dữ liệu từ người dùng
                register(
                  usernameController.text,
                  emailController.text,
                  passwordController.text,
                );
              },
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
