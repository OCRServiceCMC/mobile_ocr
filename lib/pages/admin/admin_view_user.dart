import 'package:flutter/material.dart';
import 'package:flutter_application_1/layout/admin_drawer.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/pages/admin/view_user_detail.dart'; // Import ViewUserDetail

class AdminUserListPage extends StatelessWidget {
  const AdminUserListPage({super.key});
  
  static final _logger = Logger('AdminUserListPage');

  Future<String?> _getAuthToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  Future<List<Map<String, dynamic>>> fetchAllUsers() async {
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
        return data.map((user) => {
          'userID': user['userID'],
          'username': user['username'],
          'status': user['status'],
        }).toList();
      } else {
        _logger.severe('Failed to load users: ${response.statusCode} ${response.body}');
        throw Exception('Failed to load users');
      }
    } catch (e) {
      _logger.severe('Error fetching users: $e');
      throw Exception('Failed to fetch users');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin: User List'),
      ),
      drawer: const AdminDrawer(), // Add the custom drawer
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchAllUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            final users = snapshot.data!;
            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return ListTile(
                  leading: Text('${index + 1}'),
                  title: Text('ID: ${user['userID']} - ${user['username']}'),
                  subtitle: Text('Status: ${user['status']}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ViewUserDetail(userID: user['userID']),
                      ),
                    );
                  },
                );
              },
            );
          } else {
            return const Center(child: Text('No users available.'));
          }
        },
      ),
    );
  }
}
