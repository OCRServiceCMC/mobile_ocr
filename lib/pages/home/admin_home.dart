import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/layout/admin_drawer.dart';
import 'package:flutter_application_1/layout/custom_app_bar.dart'; // Import CustomAppBar
import 'package:flutter_application_1/layout/custom_bottom_nav_bar.dart'; // Import CustomBottomNavBar
import 'package:flutter_application_1/pages/loginregister/login.dart';
import 'package:flutter_application_1/pages/admin/admin_view_user.dart'; // Import AdminUserListPage

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
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

      final url = Uri.parse('http://10.0.2.2:8081/api/admin/users');
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
      drawer: const AdminDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildStatisticCard('Total Users', totalUsers.toString()),
            _buildStatisticCard('Total Files Uploaded', totalFilesUploaded.toString()),
            _buildStatisticCard('Total Users GP', totalGP.toString()),
            _buildStatisticCard('Total User Storage', '${(totalUserStorage / (1024 * 1024)).toStringAsFixed(2)} MB'),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildStatisticCard(String title, String value) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        trailing: Text(
          value,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
