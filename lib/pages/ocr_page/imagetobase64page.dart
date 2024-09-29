import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart'; // Thêm import để sử dụng Clipboard

class ImageToBase64Page extends StatefulWidget {
  const ImageToBase64Page({super.key});

  @override
  _ImageToBase64PageState createState() => _ImageToBase64PageState();
}

class _ImageToBase64PageState extends State<ImageToBase64Page> {
  File? _selectedImage;
  String? _ocrResult;
  bool _isLoading = false; // Thêm biến trạng thái để kiểm soát hiệu ứng loading

  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  Future<void> _convertImageToBase64() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File file = File(result.files.single.path!);
      setState(() {
        _selectedImage = file; // Hiển thị ảnh preview
      });

      final token = await _getToken();
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No auth token found!')),
        );
        return;
      }

      final url = Uri.parse('http://103.145.63.232:8081/api/converter/image-to-base64');

      final request = http.MultipartRequest('POST', url)
        ..headers['Authorization'] = 'Bearer $token'
        ..files.add(await http.MultipartFile.fromPath('file', file.path));

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await http.Response.fromStream(response);
        String base64String = responseData.body;

        _convertBase64ToText(base64String); // Tự động gọi API OCR
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to convert image: ${response.statusCode}')),
        );
      }
    }
  }

  Future<void> _convertBase64ToText(String base64String) async {
    final token = await _getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No auth token found!')),
      );
      return;
    }

    setState(() {
      _isLoading = true; // Bắt đầu loading
    });

    final url = Uri.parse('http://103.145.63.232:8081/api/ocr/convertBase64ToText');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'contentBase64': base64String,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      if (responseData['statusCode'] == 200) {
        try {
          String rawJson = responseData['data']['json_ocr_out'];
          rawJson = rawJson.replaceAll(r'\"', '"');
          rawJson = rawJson.replaceAllMapped(RegExp(r'(?<!\\)"(?![:,\]}])'), (match) => r'\"');
          rawJson = rawJson.replaceAll("'", '"');
          rawJson = rawJson.replaceAll(r'\\n', '\n');
          rawJson = rawJson.replaceAll(r'\\t', '\t');
          final Map<String, dynamic> jsonMap = jsonDecode(rawJson);
          String docContent = jsonMap['doc'] ?? '';
          docContent = docContent.replaceAll('\\n', '\n').replaceAll('\\t', ' ').replaceAllMapped(RegExp(r'\s+'), (match) => ' ');

          setState(() {
            _ocrResult = docContent;
          });
        } catch (e) {
          setState(() {
            _ocrResult = 'Failed to parse OCR result: $e';
          });
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

    setState(() {
      _isLoading = false; // Kết thúc loading
    });
  }

  // Hàm copy OCR result
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
        title: const Text('Chuyển đổi văn bản số'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ElevatedButton(
              onPressed: _convertImageToBase64,
              child: const Text('Chọn ảnh văn bản'),
            ),
            const SizedBox(height: 20),
            if (_selectedImage != null)
              Expanded(
                child: Image.file(_selectedImage!),
              ),
            const SizedBox(height: 20),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(), // Hiển thị loading khi đang chờ API
              ),
            if (!_isLoading && _ocrResult != null)
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

