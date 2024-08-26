// lib/pages/home/user_home.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_1/layout/custom_app_bar.dart'; // Import CustomAppBar
import 'package:flutter_application_1/layout/custom_drawer.dart'; // Import CustomDrawer
import 'package:flutter_application_1/layout/custom_bottom_nav_bar.dart'; // Import CustomBottomNavBar
import 'package:flutter_application_1/pages/loginregister/login.dart';
import 'package:flutter_application_1/pages/uploaded_files/upload_file_page.dart';


//! Add custom_drawer to user_home.dart
class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  _AdminHomePageState createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  bool _isLoggedIn = false;
  int _selectedIndex = 0;

  void _toggleLoginState() {
    setState(() {
      _isLoggedIn = !_isLoggedIn;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Admin Home Page',
        actions: [
          TextButton(
            onPressed: () {
              if (_isLoggedIn) {
                _toggleLoginState();
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                ).then((_) {
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
      drawer: const CustomDrawer(), // Sử dụng CustomDrawer ở đây
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
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped, // Điều chỉnh trạng thái khi chọn tab
      ),
    );
  }
}
