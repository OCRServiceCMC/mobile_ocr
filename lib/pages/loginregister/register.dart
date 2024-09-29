import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // Để sử dụng jsonEncode và jsonDecode

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
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

  // Hàm gọi API đăng ký
  Future<void> register(String username, String email, String password, String confirmPassword) async {
    // Kiểm tra xem tất cả các trường đã được nhập đầy đủ chưa
    if (username.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields!')),
      );
      return;
    }

    // Kiểm tra mật khẩu và mật khẩu xác nhận có khớp nhau không
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match!')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    _showLoadingDialog(); // Hiển thị hộp thoại loading

    // final url = Uri.parse('http://10.0.2.2:8081/api/auth/register');
    final url = Uri.parse('http://103.145.63.232:8081/api/auth/register');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'passwordHash': password, // Sử dụng 'passwordHash' cho trường mật khẩu
        'email': email,
      }),
    );

    _hideLoadingDialog(); // Ẩn hộp thoại loading

    setState(() {
      _isLoading = false;
    });

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Thêm tiêu đề thương hiệu
              const Text(
                'Đăng ký',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5800D7),
                ),
              ),
              const SizedBox(height: 20),

              // Ô nhập Username với icon
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  prefixIcon: Icon(Icons.person), // Thêm biểu tượng người dùng
                ),
              ),
              const SizedBox(height: 20),

              // Ô nhập Email với icon
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email), // Thêm biểu tượng email
                ),
              ),
              const SizedBox(height: 20),

              // Ô nhập Password với icon
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock), // Thêm biểu tượng khóa
                ),
                obscureText: true,
              ),
              const SizedBox(height: 20),

              // Ô nhập Confirm Password với icon
              TextField(
                controller: confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                  prefixIcon: Icon(Icons.lock), // Thêm biểu tượng khóa cho xác nhận mật khẩu
                ),
                obscureText: true,
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () {
                  // Gọi hàm đăng ký với dữ liệu từ người dùng
                  register(
                    usernameController.text,
                    emailController.text,
                    passwordController.text,
                    confirmPasswordController.text,
                  );
                },
                child: _isLoading
                    ? const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                )
                    : const Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
