import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/layout/admin_drawer.dart';
import 'package:flutter_application_1/layout/custom_app_bar.dart';
import 'package:flutter_application_1/layout/custom_bottom_nav_bar.dart';
import 'package:flutter_application_1/pages/loginregister/login.dart';
import 'package:flutter_application_1/pages/admin/admin_view_user.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  _AdminHomePageState createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  bool _isLoggedIn = false;
  int _selectedIndex = 0;
  static final _logger = Logger('AdminHomePage');

  // Variables to store statistics
  int totalUsers = 0;
  int totalFilesUploaded = 0;
  int totalGP = 0;
  int totalUserStorage = 0;

  @override
  void initState() {
    super.initState();
    fetchStatistics();
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

    if (index == 2) {
      // Navigate to AdminUserListPage when the Eye icon is tapped
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AdminUserListPage()),
      );
    }
  }

  Future<String?> _getAuthToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  Future<void> fetchStatistics() async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('No token found');
      }

      final url = Uri.parse('http://103.145.63.232:8081/api/admin/users');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);

        setState(() {
          totalUsers = data.length;
          totalFilesUploaded = data.fold<int>(0, (sum, user) => sum + (user['documents']?.length as int ?? 0));
          totalGP = data.fold<int>(0, (sum, user) => sum + ((user['currentGP'] ?? 0) as int));
          totalUserStorage = data.fold<int>(0, (sum, user) => sum + ((user['maxStorage'] ?? 0) as int));
        });

        _logger.info('Statistics loaded successfully.');
      } else {
        _logger.severe('Failed to load statistics: ${response.statusCode} ${response.body}');
        throw Exception('Failed to load statistics');
      }
    } catch (e) {
      _logger.severe('Error fetching statistics: $e');
      throw Exception('Failed to fetch statistics');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Admin Dashboard',
        actions: [
          IconButton(
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
        ],
      ),
      drawer: const AdminDrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Text(
                'Admin Statistics',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              _buildStatisticCard(Icons.people, 'Total Users', totalUsers.toString()),
              _buildStatisticCard(Icons.file_upload, 'Total Files Uploaded', totalFilesUploaded.toString()),
              _buildStatisticCard(Icons.monetization_on, 'Total Users GP', totalGP.toString()),
              _buildStatisticCard(Icons.storage, 'Total User Storage', '${(totalUserStorage / (1024 * 1024)).toStringAsFixed(2)} MB'),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildStatisticCard(IconData icon, String title, String value) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 40, color: Colors.blueAccent),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
