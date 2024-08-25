import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/loginregister/login.dart';
import 'package:flutter_application_1/pages/uploaded_files/upload_file_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginPage(),
      routes: {
        '/upload': (context) => const UploadFilePage(),
      },
    );
  }
}


//TODO: Front End Mobile. '?' là chưa làm. 
// Login, Register (Thành)
//? View User Account
//? View File Storage
// Home Page
//? Page Đăng Ảnh
//? Page Nạp Tiền
//? Page PDF


//? Admin 
//? Admin Dash board 
    //? View All User
    //? Delete User
    //? View User Profile
//? Page OCR
//? Page Convert File
//? Page Upload File
//? Page Edit File  (nếu có)