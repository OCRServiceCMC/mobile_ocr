import 'package:flutter/material.dart';
import 'package:flutter_application_1/component/custom_app_bar.dart'; // Import CustomAppBar
import 'package:flutter_application_1/pages/loginregister/login.dart';
import 'package:flutter_application_1/pages/uploaded_files/upload_file_page.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  _UserHomePageState createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  bool _isLoggedIn = false;

  void _toggleLoginState() {
    setState(() {
      _isLoggedIn = !_isLoggedIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Home Page',
        actions: [
          TextButton(
            onPressed: () {
              if (_isLoggedIn) {
                // Xử lý Logout
                _toggleLoginState();
                // Điều hướng hoặc thực hiện các hành động khác nếu cần
              } else {
                // Điều hướng đến trang Login
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                ).then((_) {
                  // Giả sử người dùng đã đăng nhập thành công, chúng ta thay đổi trạng thái
                  _toggleLoginState();
                });
              }
            },
            child: Text(
              _isLoggedIn ? 'Login' : 'Logout',
              style: const TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Drawer Header',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.upload_file),
              title: const Text('Upload File'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UploadFilePage()),
                );
              },
            ),
          ],
        ),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Welcome to the Home Page!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'This is a simple welcome layout. You can navigate through the app using the buttons below.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(
                Icons.person), // Changed icon to person to reflect user account
            label: 'Account', // Changed label to Account
          ),
        ],
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const UserAccountPage()),
            );
          }
        },
      ),
    );
  }
}
