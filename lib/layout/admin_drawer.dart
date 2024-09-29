// lib/layout/custom_drawer.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/admin/admin_view_user.dart';
import 'package:flutter_application_1/FAQ/admin_faq_page.dart';
import 'package:flutter_application_1/pages/home/admin_home.dart';
import 'package:flutter_application_1/pages/payment/qrpaymentpage.dart';
import 'package:flutter_application_1/pages/update_service/upgrade_service.dart';

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
              'Manager',
              style: TextStyle(
                color: Colors.white,
                fontSize: 36
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
          ListTile(
            leading: const Icon(Icons.question_answer),
            title: const Text('Q&A'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AdminFAQPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.qr_code),
            title: const Text('QR Payment'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => QRPaymentPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.upgrade),
            title: const Text('Upgrade Services'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UpgradeServicePage()),
              );
            },
          ),
        ],
      ),
    );
  }
}

