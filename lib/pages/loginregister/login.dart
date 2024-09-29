import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/pages/loginregister/register.dart';
import 'package:flutter_application_1/pages/home/user_home.dart';
import 'package:flutter_application_1/pages/home/admin_home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/pages/loginregister/forgotpassword.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isPasswordVisible = false; // Trạng thái hiển thị mật khẩu
  bool _isLoading = false; // Trạng thái loading

  // Hiển thị hộp thoại loading
  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text("Loading..."),
            ],
          ),
        );
      },
    );
  }

  // Ẩn hộp thoại loading
  void _hideLoadingDialog() {
    Navigator.pop(context); // Đóng dialog hiện tại
  }

  Future<void> login(String username, String password) async {
    setState(() {
      _isLoading = true;
    });

    _showLoadingDialog(); // Hiển thị hộp thoại loading

    // final url = Uri.parse('http://10.0.2.2:8081/api/auth/login');
    final url = Uri.parse('http://103.145.63.232:8081/api/auth/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'passwordHash': password,
      }),
    );

    _hideLoadingDialog(); // Ẩn hộp thoại loading

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 200) {
      String token = response.body;

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('authToken', token);

      final userDetailsResponse = await http.get(
        // Uri.parse('http://10.0.2.2:8081/api/auth/user-details'),
        Uri.parse('http://103.145.63.232:8081/api/auth/user-details'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (userDetailsResponse.statusCode == 200) {
        final userDetails = jsonDecode(userDetailsResponse.body);
        String role = userDetails['role'];

        // Đăng nhập thành công, hiển thị thông báo
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login successful!')),
        );

        if (role == 'ADMIN') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AdminHomePage()),
          );
        } else if (role == 'User') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const UserHomePage()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Unauthorized role!')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to fetch user details!')),
        );
      }
    } else {
      // Đăng nhập thất bại, hiển thị thông báo
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login failed! Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 200),
              const Text(
                'Đăng nhập',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5800D7),
                ),
              ),
              const SizedBox(height: 20),
              // Ô nhập Username với biểu tượng logo
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 20),
              // Ô nhập Password với biểu tượng và nút giữ để hiển thị mật khẩu
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
                obscureText: !_isPasswordVisible,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () {
                  login(usernameController.text, passwordController.text);
                },
                child: _isLoading
                    ? const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                )
                    : const Text('Login'),
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
                        MaterialPageRoute(builder: (context) => const RegisterPage()),
                      );
                    },
                    child: const Text('Register'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Nút điều hướng đến trang Forgot Password
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ForgotPasswordPage()),
                  );
                },
                child: const Text('Forgot Password?'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
