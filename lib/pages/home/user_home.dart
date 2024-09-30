import 'package:flutter/material.dart';
import 'package:flutter_application_1/layout/custom_app_bar.dart';
import 'package:flutter_application_1/layout/custom_drawer.dart';
import 'package:flutter_application_1/layout/custom_bottom_nav_bar.dart';
import 'package:flutter_application_1/pages/loginregister/login.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  _UserHomePageState createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
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
        title: 'Trang chủ',
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
            child: IconButton(
              icon: Icon(_isLoggedIn ? Icons.login : Icons.logout, color: Colors.black),
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
            ),
          ),
        ],
      ),
      drawer: const CustomDrawer(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Section: Header Image
            Container(
              width: double.infinity,
              height: 200,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('lib/assets/OCR-Software.jpg'),// Hình minh họa
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                color: Colors.black.withOpacity(0.4),
                child: const Center(
                  child: Text(
                    'Dịch vụ OCR',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Section: Introduction Text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const <Widget>[
                  Text(
                    'Bắt đầu',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Khám phá các tính năng tuyệt vời của ứng dụng của chúng tôi. Cho dù bạn muốn tải tệp lên, quản lý cài đặt hay khám phá nội dung độc quyền, chúng tôi sẽ đáp ứng được mọi nhu cầu.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
            // Section: Feature Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  _buildFeatureCard(
                    icon: Icons.upload_file,
                    title: 'Tải ảnh tài liệu',
                    description: 'Quản lý File.',
                    onTap: () {
                      // Navigate to upload files page
                    },
                  ),
                  _buildFeatureCard(
                    icon: Icons.document_scanner,
                    title: 'OCR',
                    description: 'Chuyển đổi văn bản số.',
                    onTap: () {
                      // Navigate to settings page
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Section: Illustration Image with Call to Action
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.0),
                  image: const DecorationImage(
                    image: AssetImage('lib/assets/QuickScan.png'), // Hình minh họa
                    fit: BoxFit.cover,
                  ),
                ),
                width: double.infinity,
                height: 180,
                child: Container(
                  color: Colors.black.withOpacity(0.6),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const <Widget>[
                      Text(
                        'Khám phá các tính năng cao cấp',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Nâng cấp lên cao cấp để có nhiều lợi ích hơn!',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Section: Testimonials or Extra Info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const <Widget>[
                  Text(
                    'Người dùng của chúng tôi nói gì',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '"Ứng dụng này đã cách mạng hóa cách tôi quản lý công việc của mình. Nó đơn giản, trực quan và cực kỳ mạnh mẽ!"',
                    style: TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: Colors.black54,
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          width: 140,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(icon, size: 50, color: Colors.blue),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                description,
                style: const TextStyle(fontSize: 14, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
