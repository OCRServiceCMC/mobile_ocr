import 'package:flutter/material.dart';
import 'pages/loginregister/login.dart';
import 'pages/uploaded_files/upload_file_page.dart';
import 'pages/uploaded_files/folder_management_page.dart';
import 'pages/ocr_page/imagetobase64page.dart';

import 'pages/pdf_operation/pdf_operation_page.dart'; // Import PDFOperationPage
// Import other pages
import 'pages/pdf_operation/split_pdf_page.dart'; // Split PDF by Range page
import 'pages/pdf_operation/delete_pdf_page.dart'; // Delete PDF by Range page
import 'pages/pdf_operation/extract_pdf_page.dart'; // Extract PDF page
import 'pages/pdf_operation/merge_pdf_page.dart'; // Merge PDF page
import 'pages/pdf_operation/update_pdf_properties_page.dart'; // Update PDF Properties page
import 'pages/pdf_operation/add_text_to_pdf_page.dart'; // Add Text to PDF page
import 'pages/pdf_operation/add_image_to_pdf_page.dart'; // Add Image to PDF page
import 'pages/pdf_operation/convert_pdf_to_image_page.dart'; // Convert PDF to Image page
import 'pages/pdf_operation/convert_pdf_to_docx_page.dart'; // Convert PDF to Docx page
import 'pages/pdf_operation/convert_pdf_to_xlsx_page.dart'; // Convert PDF to Xlsx page
import 'pages/pdf_operation/convert_pdf_to_pptx_page.dart'; // Convert PDF to Pptx page
import 'pages/pdf_operation/set_pdf_page_size_page.dart'; // Set PDF Page Size page
import 'pages/pdf_operation/set_pdf_font_size_page.dart'; // Set PDF Font Size page
import 'pages/pdf_operation/set_password_pdf_page.dart'; // Set Password PDF page

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

        '/pdf-operations': (context) => const PDFOperationPage(),
        '/split-pdf': (context) => const SplitPDFPage(),
        '/delete-pdf': (context) => const DeletePDFPage(),
        '/extract-pdf': (context) => const ExtractPDFPage(),
        '/merge-pdf': (context) => const MergePDFPage(),
        '/update-pdf-properties': (context) => const UpdatePDFPropertiesPage(),
        '/add-text-to-pdf': (context) => const AddTextToPDFPage(),
        '/add-image-to-pdf': (context) => const AddImageToPDFPage(),
        '/convert-pdf-to-image': (context) => const ConvertPDFToImagePage(),
        '/convert-pdf-to-docx': (context) => const ConvertPDFToDocxPage(),
        '/convert-pdf-to-xlsx': (context) => const ConvertPDFToXlsxPage(),
        '/convert-pdf-to-pptx': (context) => const ConvertPDFToPptxPage(),
        '/set-pdf-page-size': (context) => const SetPDFPageSizePage(),
        '/set-pdf-font-size': (context) => const SetPDFFontSizePage(),
        '/set-password-pdf': (context) => const SetPasswordPDFPage(),
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