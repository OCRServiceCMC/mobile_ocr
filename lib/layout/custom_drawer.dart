// lib/layout/custom_drawer.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/uploaded_files/upload_file_page.dart';
import 'package:flutter_application_1/pages/ocr_page/imagetobase64page.dart';

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
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.upload_file),
            title: const Text('Upload File'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UploadFilePage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.upload_file),
            title: const Text('OCR Image'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ImageToBase64Page()),
              );
            },
          ),
        ],
      ),
    );
  }
}
