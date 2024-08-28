import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

class ImageToBase64Page extends StatefulWidget {
  const ImageToBase64Page({super.key});

  @override
  _ImageToBase64PageState createState() => _ImageToBase64PageState();
}

class _ImageToBase64PageState extends State<ImageToBase64Page> {
  String? _base64String;
  String? _ocrResult;

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
          _ocrResult = null; // Reset OCR result when a new image is converted
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to convert image: ${response.statusCode}')),
        );
      }
    }
  }

  Future<void> _convertBase64ToText() async {
    if (_base64String == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No Base64 string available to convert.')),
      );
      return;
    }

    final token = await _getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No auth token found!')),
      );
      return;
    }

    final url = Uri.parse('http://10.0.2.2:8081/api/ocr/convertBase64ToText');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'contentBase64': _base64String,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      if (responseData['statusCode'] == 200) {
        try {
          String rawJson = responseData['data']['json_ocr_out'];

          // Bước 1: Loại bỏ các ký tự escape không cần thiết trước các dấu "
          rawJson = rawJson.replaceAll(r'\"', '"');

          // Bước 2: Xử lý những dấu " không mong đợi trong chuỗi
          rawJson = rawJson.replaceAllMapped(RegExp(r'(?<!\\)"(?![:,\]}])'), (match) {
            return r'\"'; // Thay thế dấu " không mong đợi bằng \" để thoát đúng cách
          });

          // Bước 3: Thay thế các dấu ' bằng dấu "
          rawJson = rawJson.replaceAll("'", '"');

          // Bước 4: Giải mã các escape sequences
          rawJson = rawJson.replaceAll(r'\\n', '\n');
          rawJson = rawJson.replaceAll(r'\\t', '\t');

          // Parse JSON thành Map
          final Map<String, dynamic> jsonMap = jsonDecode(rawJson);

          // Trích xuất dữ liệu từ key "doc"
          String docContent = jsonMap['doc'] ?? '';

          // Bước 5: Làm sạch và loại bỏ các ký tự không mong muốn trong "doc"
          docContent = docContent.replaceAll('\\n', '\n'); // Thay thế escape sequence \\n thành xuống dòng
          docContent = docContent.replaceAll('\\t', ' ');  // Thay thế escape sequence \\t thành khoảng trắng
          docContent = docContent.replaceAllMapped(RegExp(r'\s+'), (match) => ' '); // Loại bỏ khoảng trắng dư thừa

          setState(() {
            _ocrResult = docContent;
          });
        } catch (e) {
          setState(() {
            _ocrResult = 'Failed to parse OCR result: $e';
          });
          print('Error parsing JSON: $e');
        }

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('OCR conversion failed: ${responseData['statusValue']}')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to convert Base64 to text: ${response.statusCode}')),
      );
    }
  }

  void _copyBase64ToClipboard() {
    if (_base64String != null) {
      Clipboard.setData(ClipboardData(text: _base64String!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Base64 string copied to clipboard')),
      );
    }
  }

  void _copyOcrResultToClipboard() {
    if (_ocrResult != null) {
      Clipboard.setData(ClipboardData(text: _ocrResult!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OCR result copied to clipboard')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Convert Image to Base64 & OCR'),
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
            if (_base64String != null)
              Expanded(
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
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _convertBase64ToText,
                        child: const Text('Convert Base64 to Text'),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 20),
            if (_ocrResult != null)
              Expanded(
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
                            _ocrResult!,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _copyOcrResultToClipboard,
                        child: const Text('Copy OCR Result'),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
