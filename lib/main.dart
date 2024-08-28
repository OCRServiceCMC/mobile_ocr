import 'package:flutter/material.dart';
import 'pages/loginregister/login.dart';
import 'pages/uploaded_files/upload_file_page.dart';
import 'pages/uploaded_files/folder_management_page.dart';
import 'pages/ocr_page/imagetobase64page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp( 
      debugShowCheckedModeBanner: false,  // Turn off the debug banner
      title: 'OCR Service App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginPage(),
      routes: {
        '/upload': (context) => const UploadFilePage(),
        '/upload-folder': (context) => const FolderManagementPage(),
        '/image-toBase64': (context) => const ImageToBase64Page(),

        
      },
    );
  }
}



//TODO: Front End Mobile. '?' là chưa làm.
// Login, Register (Thành)
// View User Account
// View File Storage
// Home Page
// Page Đăng Ảnh
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

//! Fix bug, duplicated name when user change name in profile page. Because user loggin by user names