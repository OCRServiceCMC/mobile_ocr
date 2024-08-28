// lib/layout/custom_drawer.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_1/FAQ/user_faq_page.dart';
import 'package:flutter_application_1/pages/uploaded_files/upload_file_page.dart';
import 'package:flutter_application_1/pages/ocr_page/imagetobase64page.dart';
import 'package:flutter_application_1/pages/uploaded_files/folder_management_page.dart';
import 'package:flutter_application_1/pages/payment/qrpaymentpage.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

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
              'Dashboard',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.upload_file),
            title: const Text('Upload File'),
            onTap: () {
              Navigator.pushNamed(context, '/upload');
            },
          ),
          ListTile(
            leading: const Icon(Icons.folder),
            title: const Text('Manage Folders'),
            onTap: (){
              Navigator.pushNamed(context, '/upload-folder');
            }
          ),
          ListTile(
            leading: const Icon(Icons.upload_file),
            title: const Text('Image To Base64'),
            onTap: () {
              Navigator.pushNamed(context, '/image-toBase64');
            },
          ),
          ListTile(
            leading: const Icon(Icons.question_answer),
            title: const Text('FAQ'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FAQPage()),
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
        ],
      ),
    );
  }
}
