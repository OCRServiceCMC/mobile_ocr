import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserAccountPage extends StatefulWidget {
  const UserAccountPage({super.key});

  @override
  _UserAccountPageState createState() => _UserAccountPageState();
}

class _UserAccountPageState extends State<UserAccountPage> {
  late TextEditingController emailController;
  late TextEditingController usernameController; // New controller for username
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController addressController;
  late TextEditingController phoneNumberController;
  late TextEditingController currentGPController;
  late TextEditingController maxStorageController;
  late TextEditingController registrationDateController;
  late TextEditingController roleController;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    usernameController =
        TextEditingController(); // Initialize the new controller
    firstNameController = TextEditingController();
    lastNameController = TextEditingController();
    addressController = TextEditingController();
    phoneNumberController = TextEditingController();
    currentGPController = TextEditingController();
    maxStorageController = TextEditingController();
    registrationDateController = TextEditingController();
    roleController = TextEditingController();

    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    try {
      setState(() {
        isLoading = true;
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('authToken');

      if (token == null) {
        throw Exception('No token found');
      }

      final url = Uri.parse('http://10.0.2.2:8081/api/auth/user-details');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          emailController.text = data['email'] ?? '';
          usernameController.text = data['username'] ?? ''; // Set the username
          firstNameController.text = data['userProfile']['firstName'] ?? '';
          lastNameController.text = data['userProfile']['lastName'] ?? '';
          addressController.text = data['userProfile']['address'] ?? '';
          phoneNumberController.text = data['userProfile']['phoneNumber'] ?? '';
          currentGPController.text = data['currentGP']?.toString() ?? '0';
          maxStorageController.text = (data['maxStorage'] != null
              ? (data['maxStorage'] / (1024 * 1024)).toStringAsFixed(2)
              : '0');
          registrationDateController.text = data['registrationDate'] ?? '';
          roleController.text = data['role'] ?? '';
        });
      } else {
        print('Failed to load profile: ${response.statusCode} ${response.body}');
        throw Exception('Failed to load profile');
      }
    } catch (e) {
      print('Error fetching profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching profile: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> updateUserProfile() async {
    try {
      setState(() {
        isLoading = true;
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('authToken');

      if (token == null) {
        throw Exception('No token found');
      }

      final url = Uri.parse('http://10.0.2.2:8081/api/user/profile');
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'firstName': firstNameController.text,
          'lastName': lastNameController.text,
          'address': addressController.text,
          'phoneNumber': phoneNumberController.text,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        // Fetch the updated profile
        fetchUserProfile();
      } else {
        print('Failed to update profile: ${response.statusCode} ${response.body}');
        throw Exception('Failed to update profile');
      }
    } catch (e) {
      print('Error updating profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Account'),
        backgroundColor: Colors.teal,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTextField('Email', emailController, enabled: false),
                        _buildTextField('Login Name', usernameController,
                            enabled: false), // Add username field
                        _buildTextField('Current GP', currentGPController, enabled: false),
                        _buildTextField(
                            'Max Storage (MB)', maxStorageController,
                            enabled: false),
                        _buildTextField('Registration Date', registrationDateController, enabled: false),
                        _buildTextField('Role', roleController, enabled: false),
                        const SizedBox(height: 16),
                        
                        _buildTextField('First Name', firstNameController),
                        _buildTextField('Last Name', lastNameController),
                        _buildTextField('Address', addressController),
                        _buildTextField('Phone Number', phoneNumberController),
                        const SizedBox(height: 20),
                        Center(
                          child: ElevatedButton(
                            onPressed: updateUserProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal, // Button background color
                              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                            ),
                            child: const Text(
                              'Save Changes',
                              style: TextStyle(color: Colors.white), // Set text color here
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        enabled: enabled,
        style: const TextStyle(
            color: Color.fromARGB(221, 26, 22, 22)), // Adjust color as needed
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    usernameController.dispose(); // Dispose the username controller
    firstNameController.dispose();
    lastNameController.dispose();
    addressController.dispose();
    phoneNumberController.dispose();
    currentGPController.dispose();
    maxStorageController.dispose();
    registrationDateController.dispose();
    roleController.dispose();
    super.dispose();
  }
}
