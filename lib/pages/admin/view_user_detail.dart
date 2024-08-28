import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ViewUserDetail extends StatefulWidget {
  final int userID;

  const ViewUserDetail({super.key, required this.userID});

  @override
  _ViewUserDetailState createState() => _ViewUserDetailState();
}

class _ViewUserDetailState extends State<ViewUserDetail> {
  static final _logger = Logger('ViewUserDetail');

  final _formKey = GlobalKey<FormState>();

  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _currentGPController;
  late TextEditingController _roleController;

  Future<String?> _getAuthToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  Future<Map<String, dynamic>> fetchUserDetails() async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('No token found');
      }

      final url = Uri.parse('http://10.0.2.2:8081/api/admin/users/${widget.userID}');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _initializeControllers(data);
        return data;
      } else {
        _logger.severe('Failed to load user details: ${response.statusCode} ${response.body}');
        throw Exception('Failed to load user details');
      }
    } catch (e) {
      _logger.severe('Error fetching user details: $e');
      throw Exception('Failed to fetch user details');
    }
  }

  void _initializeControllers(Map<String, dynamic> user) {
    _usernameController = TextEditingController(text: user['username']);
    _emailController = TextEditingController(text: user['email']);
    _currentGPController = TextEditingController(text: user['currentGP']?.toString() ?? '0');
    _roleController = TextEditingController(text: user['role']);
  }

  Future<void> _updateUser() async {
    if (!_formKey.currentState!.validate()) return;

    final token = await _getAuthToken();
    if (token == null) {
      _showSnackBar('No token found');
      return;
    }

    final url = Uri.parse('http://10.0.2.2:8081/api/admin/users/${widget.userID}');
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "username": _usernameController.text,
        "email": _emailController.text,
        "role": _roleController.text, // Include the role in the update
        "currentGP": int.tryParse(_currentGPController.text) ?? 0, // Convert currentGP to int
      }),
    );

    if (response.statusCode == 200) {
      _showSnackBar('User updated successfully');
      Navigator.pop(context); // Go back after updating
    } else {
      _logger.severe('Failed to update user: ${response.statusCode} ${response.body}');
      _showSnackBar('Failed to update user');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Detail'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchUserDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            return _buildUserDetailForm(snapshot.data!);
          } else {
            return const Center(child: Text('No data available.'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _updateUser,
        backgroundColor: Colors.teal,
        child: const Icon(
          Icons.save,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildUserDetailForm(Map<String, dynamic> user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildDetailCard('Profile ID', user['userProfile']['profileID'].toString()),
            _buildEditableField('Username', _usernameController),
            _buildEditableField('Email', _emailController),
            _buildEditableField('Current GP', _currentGPController, isNumeric: true),
            _buildDetailCard('Role', user['role']),
            _buildDetailCard('Max Storage', '${user['maxStorage']} bytes'),
            _buildDetailCard('Registration Date', user['registrationDate'] ?? 'N/A'),
            _buildDetailCard('Phone Number', user['userProfile']['phoneNumber'] ?? 'N/A'),
            _buildDetailCard('Address', user['userProfile']['address'] ?? 'N/A'),
            _buildDetailCard('Last Login Date', user['lastLoginDate'] ?? 'N/A'),
            _buildDetailCard('Status', user['status'] ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller, {bool isNumeric = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          if (isNumeric && int.tryParse(value) == null) {
            return 'Please enter a valid number';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDetailCard(String title, String content) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(content),
      ),
    );
  }
}
