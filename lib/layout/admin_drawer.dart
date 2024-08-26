// lib/layout/custom_drawer.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/admin/admin_view_user.dart';
import 'package:flutter_application_1/pages/home/admin_home.dart';

class AdminDrawer extends StatelessWidget {
  const AdminDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'Drawer Header',
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AdminHomePage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.remove_red_eye),
            title: const Text('View Users'),
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AdminUserListPage()),
              );
            },
          ),
        
        ],
      ),
    );
  }
}

