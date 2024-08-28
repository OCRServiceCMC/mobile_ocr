import 'package:flutter/material.dart';
import 'package:flutter_application_1/layout/custom_drawer.dart';


class PDFOperationPage extends StatelessWidget {
  const PDFOperationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Operations'),
      ),
      drawer: const CustomDrawer(), // Assuming you have a custom drawer in your app
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildNavigationButton(context, 'Split PDF by Range', '/split-pdf'),
            _buildNavigationButton(context, 'Delete PDF by Range', '/delete-pdf'),
            _buildNavigationButton(context, 'Extract PDF', '/extract-pdf'),
            _buildNavigationButton(context, 'Merge PDF to New File', '/merge-pdf'),
            _buildNavigationButton(context, 'Update PDF Properties', '/update-pdf-properties'),
            _buildNavigationButton(context, 'Add Text to PDF', '/add-text-to-pdf'),
            _buildNavigationButton(context, 'Add Image to PDF', '/add-image-to-pdf'),
            _buildNavigationButton(context, 'Convert PDF to Image', '/convert-pdf-to-image'),
            _buildNavigationButton(context, 'Convert PDF to Docx', '/convert-pdf-to-docx'),
            _buildNavigationButton(context, 'Convert PDF to Xlsx', '/convert-pdf-to-xlsx'),
            _buildNavigationButton(context, 'Convert PDF to Pptx', '/convert-pdf-to-pptx'),
            _buildNavigationButton(context, 'Set PDF Page Size', '/set-pdf-page-size'),
            _buildNavigationButton(context, 'Set PDF Font Size', '/set-pdf-font-size'),
            _buildNavigationButton(context, 'Set Password PDF', '/set-password-pdf'),
          ],
        ),
      ),
    );
  }

  // Hàm tạo các nút điều hướng
  Widget _buildNavigationButton(BuildContext context, String title, String route) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, route);
        },
        child: Text(title),
      ),
    );
  }
}
