import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart'; // Import để sử dụng Clipboard

class ImageToBase64Page extends StatefulWidget {
  const ImageToBase64Page({super.key});

  @override
  _ImageToBase64PageState createState() => _ImageToBase64PageState();
}

class _ImageToBase64PageState extends State<ImageToBase64Page> {
  String? _base64String;

  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  Future<void> _convertImageToBase64() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File file = File(result.files.single.path!);
      final token = await _getToken();
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No auth token found!')),
        );
        return;
      }

      final url = Uri.parse('http://10.0.2.2:8081/api/converter/image-to-base64');

      final request = http.MultipartRequest('POST', url)
        ..headers['Authorization'] = 'Bearer $token'
        ..files.add(await http.MultipartFile.fromPath('file', file.path));

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await http.Response.fromStream(response);
        setState(() {
          _base64String = responseData.body;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to convert image: ${response.statusCode}')),
        );
      }
    }
  }

  void _copyBase64ToClipboard() {
    if (_base64String != null) {
      Clipboard.setData(ClipboardData(text: _base64String!)); // Sử dụng toán tử `!`
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Base64 string copied to clipboard')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Convert Image to Base64'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ElevatedButton(
              onPressed: _convertImageToBase64,
              child: const Text('Select and Convert Image'),
            ),
            const SizedBox(height: 20),
            _base64String != null
                ? Expanded(
              child: Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: SelectableText(
                          _base64String!,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _copyBase64ToClipboard,
                      child: const Text('Copy Base64'),
                    ),
                  ],
                ),
              ),
            )
                : const Expanded(
              child: Center(
                child: Text('No image selected'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
