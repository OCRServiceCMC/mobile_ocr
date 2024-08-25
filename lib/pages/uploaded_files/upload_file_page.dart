import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'dart:io';

class UploadFilePage extends StatefulWidget {
  const UploadFilePage({super.key});

  @override
  _UploadFilePageState createState() => _UploadFilePageState();
}

class _UploadFilePageState extends State<UploadFilePage> {
  String? _selectedFileName;
  PlatformFile? _selectedFile;
  bool _isUploading = false;
  List<String> _userFiles = [];

  // Hàm lấy danh sách file từ API
  Future<void> _fetchUserFiles() async {
    // Thay thế bằng token thực tế của bạn
    String token = 'your_bearer_token_here';
    String url = 'http://10.0.2.2:8081/api/auth/user/files/list';

    try {
      var response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        List<dynamic> files = jsonDecode(response.body);
        if (files.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No files found for this user.')),
          );
        } else {
          setState(() {
            _userFiles = files.map((file) => file['fileName'] as String).toList();
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to fetch files.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred while fetching files.')),
      );
    }
  }

// Hàm chọn file từ storage của thiết bị
  Future<void> _selectFileFromStorage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _selectedFile = result.files.first;
        _selectedFileName = _selectedFile?.name;
      });
    } else {
      setState(() {
        _selectedFileName = 'No file selected';
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No file selected.')),
        );
      });
    }
  }

  // Hàm upload file lên API
  Future<void> _uploadFile() async {
    if (_selectedFile == null) return;

    setState(() {
      _isUploading = true;
    });

    // Thay thế bằng token thực tế của bạn
    String token = 'your_bearer_token_here';
    String url = 'http://10.0.2.2:8081/api/auth/user/files/upload';

    var request = http.MultipartRequest('POST', Uri.parse(url))
      ..headers['Authorization'] = 'Bearer $token'
      ..files.add(
        http.MultipartFile.fromBytes(
          'file',
          File(_selectedFile!.path!).readAsBytesSync(),
          filename: _selectedFileName,
        ),
      );

    try {
      var response = await request.send();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File uploaded successfully!')),
        );
        // Refresh file list after upload
        _fetchUserFiles();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to upload file.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred during upload.')),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUserFiles(); // Fetch files when the page loads
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload File'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_userFiles.isNotEmpty)
              Column(
                children: _userFiles.map((file) => Text(file)).toList(),
              )
            else
              const Text('No file selected.', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _selectFileFromStorage,
              child: const Text('Select File from Storage'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isUploading ? null : _uploadFile,
              child: _isUploading
                  ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )
                  : const Text('Upload File'),
            ),
          ],
        ),
      ),
    );
  }
}
