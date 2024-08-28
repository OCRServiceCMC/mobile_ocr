import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/layout/custom_app_bar.dart'; // Import CustomAppBar
import 'package:flutter_application_1/layout/custom_drawer.dart'; // Import CustomDrawer
import 'package:flutter_application_1/layout/custom_bottom_nav_bar.dart'; // Import CustomBottomNavBar
import 'package:flutter_application_1/pages/auth/login.dart';
import 'package:flutter_application_1/pages/update_service/upgrade_service.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  _UserHomePageState createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  bool _isLoggedIn = false;
  int _selectedIndex = 0;

  double usedStorage = 0;
  double availableStorage = 0;
  double upgradedStorage = 0;

  int totalRequests = 0;
  int remainingRequests = 0;
  int usedRequests = 0;
  int upgradedRequests = 0;

  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final token = await _getToken();
    if (token == null) {
      setState(() {
        errorMessage = "Authentication token not found.";
      });
      return;
    }

    try {
      // Fetch storage info
      final storageResponse = await http.get(
        Uri.parse('http://10.0.2.2:8081/api/transactions/storage-info'),
        headers: {'Authorization': 'Bearer $token'},
      );

      // Fetch request info
      final requestResponse = await http.get(
        Uri.parse('http://10.0.2.2:8081/api/transactions/request-info'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (storageResponse.statusCode == 200 && requestResponse.statusCode == 200) {
        final storageData = jsonDecode(storageResponse.body);
        final requestData = jsonDecode(requestResponse.body);

        setState(() {
          usedStorage = storageData['usedStorage'] / (1024 * 1024); // Convert to MB
          availableStorage = storageData['availableStorage'] / (1024 * 1024); // Convert to MB
          upgradedStorage = storageData['upgradedStorage'] / (1024 * 1024); // Convert to MB

          totalRequests = requestData['totalRequests'];
          remainingRequests = requestData['remainingRequests'];
          usedRequests = requestData['usedRequests'];
          upgradedRequests = requestData['upgradedRequests'];
        });
      } else {
        setState(() {
          errorMessage = "Failed to fetch service information.";
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "An error occurred while fetching service information.";
      });
    }
  }

  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

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
        title: 'Home Page',
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
      drawer: const CustomDrawer(), // Drawer giữ nguyên để điều hướng
      body: errorMessage != null
          ? Center(child: Text(errorMessage!, style: TextStyle(color: Colors.red)))
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Phần tiêu đề chính với hình nền
            Stack(
              children: [
                Container(
                  height: 250,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.blue, Colors.blueAccent],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                ),
                Positioned(
                  top: 60,
                  left: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome Back!',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Your Account Overview',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoCard(
                        title: 'Total Requests',
                        value: totalRequests.toString(),
                        icon: Icons.assignment,
                      ),
                      _buildInfoCard(
                        title: 'Used Storage',
                        value: '${usedStorage.toStringAsFixed(2)} MB',
                        icon: Icons.storage,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Phần thông tin chi tiết bên dưới
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  _buildDetailedInfoCard(
                    title: 'Requests Overview',
                    description: 'You have $remainingRequests requests remaining out of $totalRequests.',
                    progress: remainingRequests / totalRequests,
                  ),
                  const SizedBox(height: 20),
                  _buildDetailedInfoCard(
                    title: 'Storage Usage',
                    description: 'You have used ${usedStorage.toStringAsFixed(2)} MB out of ${availableStorage.toStringAsFixed(2)} MB available.',
                    progress: usedStorage / (usedStorage + availableStorage),
                  ),
                  const SizedBox(height: 20),
                  _buildUpgradeBanner(),
                ],
              ),
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

  // Hàm xây dựng thẻ thông tin nhỏ ở trên cùng
  Widget _buildInfoCard({required String title, required String value, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(15),
      width: 150,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, 3),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blue, size: 30),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  // Hàm xây dựng thẻ thông tin chi tiết ở dưới
  Widget _buildDetailedInfoCard({
    required String title,
    required String description,
    required double progress,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              description,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            const SizedBox(height: 15),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ],
        ),
      ),
    );
  }

  // Hàm xây dựng banner nâng cấp dịch vụ
  Widget _buildUpgradeBanner() {
    return GestureDetector( // Thay vì sử dụng onTap trực tiếp, bạn bọc nó trong GestureDetector
      onTap: () {
        // Điều hướng đến trang UpgradeServicePage
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => UpgradeServicePage()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.blueAccent,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              offset: Offset(0, 3),
              blurRadius: 6,
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.upgrade, size: 40, color: Colors.white),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Upgrade Your Plan',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Get more storage and requests by upgrading your plan.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.white),
          ],
        ),
      ),
    );
  }

}
