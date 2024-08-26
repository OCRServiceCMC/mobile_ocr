import 'package:flutter/material.dart';
import 'dart:convert'; 
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/util/constants.dart'; // Import the constants file

class UserAccountPage extends StatelessWidget {
  const UserAccountPage({super.key});

  Future<Map<String, dynamic>> fetchUserProfile() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('authToken');

      if (token == null) {
        throw Exception('No token found');
      }

      final url =
          Uri.parse('$baseUrl/auth/user-details'); // Use the baseUrl constant
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
        // Log the exact response for debugging
        print(
            'Failed to load profile: ${response.statusCode} ${response.body}');
        throw Exception('Failed to load profile');
      }
    } catch (e) {
      // Handle the exception
      print('Error: $e');
      throw Exception('Failed to fetch user profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Account'),
      ),
      body: const Center(
        child: Text('User Account Page'),
      ),
    );
  }
}
