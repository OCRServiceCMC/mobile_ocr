import 'package:flutter/material.dart';
import 'package:flutter_application_1/layout/admin_drawer.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/pages/admin/view_user_detail.dart'; // Import ViewUserDetail

class AdminUserListPage extends StatefulWidget {
  const AdminUserListPage({super.key});

  @override
  _AdminUserListPageState createState() => _AdminUserListPageState();
}

class _AdminUserListPageState extends State<AdminUserListPage> {
  static final _logger = Logger('AdminUserListPage');
  List<Map<String, dynamic>> _allUsers = [];
  List<Map<String, dynamic>> _filteredUsers = [];
  String _searchQuery = '';

  Future<String?> _getAuthToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  Future<void> fetchAllUsers() async {
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
          _allUsers = data.map((user) => {
            'userID': user['userID'],
            'username': user['username'],
            'email': user['email'],
            'status': user['status'],
          }).toList();
          _filteredUsers = _allUsers;
        });
      } else {
        _logger.severe('Failed to load users: ${response.statusCode} ${response.body}');
        throw Exception('Failed to load users');
      }
    } catch (e) {
      _logger.severe('Error fetching users: $e');
      throw Exception('Failed to fetch users');
    }
  }

  void _filterUsers(String query) {
    setState(() {
      _filteredUsers = _allUsers.where((user) {
        final usernameLower = user['username'].toLowerCase();
        final emailLower = user['email'].toLowerCase();
        final searchLower = query.toLowerCase();
        return usernameLower.contains(searchLower) || emailLower.contains(searchLower);
      }).toList();
      _searchQuery = query;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchAllUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin: User List'),
      ),
      drawer: const AdminDrawer(),
      body: _buildUserList(),
    );
  }

  Widget _buildUserList() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: const InputDecoration(
              labelText: 'Search by username or email',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: _filterUsers,
          ),
        ),
        Expanded(
          child: _filteredUsers.isNotEmpty
              ? ListView.builder(
            itemCount: _filteredUsers.length,
            itemBuilder: (context, index) {
              final user = _filteredUsers[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                elevation: 4,
                child: ListTile(
                  leading: Icon(
                    user['status'] == 'Active' ? Icons.check_circle : Icons.error,
                    color: user['status'] == 'Active' ? Colors.green : Colors.red,
                  ),
                  title: Text(
                    'ID: ${user['userID']} - ${user['username']}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Email: ${user['email']} | Status: ${user['status']}'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ViewUserDetail(userID: user['userID']),
                      ),
                    );
                  },
                ),
              );
            },
          )
              : const Center(child: Text('Loading...')),
        ),
      ],
    );
  }
}

class UserSearchDelegate extends SearchDelegate {
  final List<Map<String, dynamic>> users;
  final Function(String) onQueryChanged;

  UserSearchDelegate(this.users, this.onQueryChanged);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          onQueryChanged(query);
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildUserList();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    onQueryChanged(query);
    return _buildUserList();
  }

  Widget _buildUserList() {
    final filteredUsers = users
        .where((user) =>
    user['username'].toLowerCase().contains(query.toLowerCase()) ||
        user['email'].toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: filteredUsers.length,
      itemBuilder: (context, index) {
        final user = filteredUsers[index];
        return ListTile(
          title: Text('${user['username']} - ${user['email']}'),
          subtitle: Text('Status: ${user['status']}'),
          onTap: () {
            close(context, null);
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
  }
}
