import 'package:flutter/material.dart';
import 'dart:convert'; 
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserAccountPage extends StatelessWidget {
  const UserAccountPage({super.key});

  Future<Map<String, dynamic>> fetchUserProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');

    if (token == null) {
      throw Exception('No token found');
    }

    final url = Uri.parse('http://10.0.2.2:8081/api/user/profile');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Account'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchUserProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final userProfile = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Card(
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          ListTile(
                            leading: const Icon(Icons.person, size: 40),
                            title: Text(
                              '${userProfile['firstName']} ${userProfile['lastName']}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              'Profile ID: ${userProfile['profileID']}',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                          const Divider(),
                          ListTile(
                            leading: const Icon(Icons.home),
                            title: const Text('Address'),
                            subtitle: Text(userProfile['address']),
                          ),
                          const Divider(),
                          ListTile(
                            leading: const Icon(Icons.phone),
                            title: const Text('Phone Number'),
                            subtitle: Text(userProfile['phoneNumber']),
                          ),
                          const Divider(),
                          ListTile(
                            leading: const Icon(Icons.calendar_today),
                            title: const Text('Create Date'),
                            subtitle: Text(userProfile['createDate']),
                          ),
                          if (userProfile['lastLoginDate'] != null) ...[
                            const Divider(),
                            ListTile(
                              leading: const Icon(Icons.login),
                              title: const Text('Last Login Date'),
                              subtitle: Text(userProfile['lastLoginDate']),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: Text('No data found'));
          }
        },
      ),
    );
  }
}
