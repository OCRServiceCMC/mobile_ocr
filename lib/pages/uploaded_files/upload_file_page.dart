import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';

class UploadFilePage extends StatefulWidget {
  const UploadFilePage({super.key});

  @override
  _UploadFilePageState createState() => _UploadFilePageState();
}

class _UploadFilePageState extends State<UploadFilePage> {
  String? _selectedFileName;
  PlatformFile? _selectedFile;
  bool _isUploading = false;
  bool _isLoading = true; // Thêm biến để kiểm tra trạng thái tải
  List<Map<String, dynamic>> _userFiles = [];

  // Hàm lấy token từ SharedPreferences
  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  // Hàm lấy danh sách file từ API
  Future<void> _fetchUserFiles() async {
    setState(() {
      _isLoading = true;
    });

    String? token = await _getToken(); // Lấy token từ session
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No authentication token found.')),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

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
            _userFiles = files.map((file) => file as Map<String, dynamic>).toList();
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
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Hàm kiểm tra loại file hợp lệ
  bool _isValidFileType(String fileName) {
    String ext = fileName.split('.').last.toLowerCase();
    return ext == 'jpg' || ext == 'jpeg' || ext == 'png' || ext == 'pdf';
  }

  // Hàm chọn file từ storage của thiết bị
  Future<void> _selectFileFromStorage() async {
    PermissionStatus status = await Permission.storage.request();

    if (status.isGranted) {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedFile = result.files.first;
          _selectedFileName = _selectedFile?.name;
        });

        // Kiểm tra loại file
        if (!_isValidFileType(_selectedFileName!)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Only JPG, PNG, and PDF files are allowed.')),
          );
          setState(() {
            _selectedFile = null;
            _selectedFileName = null;
          });
          return;
        }

        print('File selected: $_selectedFileName');
        print('File path: ${_selectedFile?.path}');
      } else {
        setState(() {
          _selectedFileName = 'No file selected';
        });
        print('No file selected');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permission denied to access storage.')),
      );
      print('Permission denied');
    }
  }

  // Hàm upload file lên API
  Future<void> _uploadFile() async {
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No file selected to upload.')),
      );
      return;
    }

    if (!File(_selectedFile!.path!).existsSync()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selected file does not exist.')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    String? token = await _getToken(); // Lấy token từ session
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No authentication token found.')),
      );
      return;
    }

    String url = 'http://10.0.2.2:8081/api/auth/user/files/upload';

    // Xác định loại MIME dựa trên phần mở rộng của tệp
    String mimeType = _selectedFile!.extension == 'pdf'
        ? 'application/pdf'
        : _selectedFile!.extension == 'png'
        ? 'image/png'
        : _selectedFile!.extension == 'jpg' || _selectedFile!.extension == 'jpeg'
        ? 'image/jpeg'
        : 'application/octet-stream';

    var request = http.MultipartRequest('POST', Uri.parse(url))
      ..headers['Authorization'] = 'Bearer $token'
      ..files.add(
        await http.MultipartFile.fromPath(
          'file',
          _selectedFile!.path!,
          contentType: MediaType.parse(mimeType), // Sử dụng MIME type chính xác
        ),
      );

    try {
      var response = await request.send();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File uploaded successfully!')),
        );
        _fetchUserFiles(); // Refresh file list after upload
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

  Future<void> _deleteFile(int fileId) async {
    String? token = await _getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No authentication token found.')),
      );
      return;
    }

    String url = 'http://10.0.2.2:8081/api/auth/user/files/$fileId';

    try {
      var response = await http.delete(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File deleted successfully!')),
        );
        _fetchUserFiles();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete file.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred during deletion.')),
      );
    }
  }

  Future<void> _editFile(int fileId) async {
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No file selected to upload.')),
      );
      return;
    }

    if (!File(_selectedFile!.path!).existsSync()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selected file does not exist.')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    String? token = await _getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No authentication token found.')),
      );
      setState(() {
        _isUploading = false;
      });
      return;
    }

    String url = 'http://10.0.2.2:8081/api/auth/user/files/$fileId';

    // Xác định loại MIME dựa trên phần mở rộng của tệp
    String mimeType = _selectedFile!.extension == 'pdf'
        ? 'application/pdf'
        : _selectedFile!.extension == 'png'
        ? 'image/png'
        : _selectedFile!.extension == 'jpg' || _selectedFile!.extension == 'jpeg'
        ? 'image/jpeg'
        : 'application/octet-stream';

    var request = http.MultipartRequest('PUT', Uri.parse(url))
      ..headers['Authorization'] = 'Bearer $token'
      ..files.add(
        await http.MultipartFile.fromPath(
          'file',
          _selectedFile!.path!,
          contentType: MediaType.parse(mimeType), // Sử dụng MIME type chính xác
        ),
      );

    try {
      var response = await request.send();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File updated successfully!')),
        );
        _fetchUserFiles();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update file.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred during update.')),
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
          children: [
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator()) // Thêm loading indicator
                  : _userFiles.isNotEmpty
                  ? ListView.builder(
                itemCount: _userFiles.length,
                itemBuilder: (context, index) {
                  var file = _userFiles[index];
                  String documentName = file['document']['documentName'];
                  String fileType = file['fileType'];
                  String base64Thumbnail = file['thumbnail'];

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: fileType == 'PDF'
                          ? Icon(Icons.picture_as_pdf, color: Colors.red, size: 40)
                          : base64Thumbnail != null
                          ? Image.memory(
                        base64Decode(base64Thumbnail),
                        width: 50,
                        height: 50,
                      )
                          : Icon(Icons.insert_drive_file, size: 40),
                      title: Text(documentName, style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text("Type: $fileType | Size: ${file['fileSize']} bytes"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _editFile(file['fileID']),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteFile(file['fileID']),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              )
                  : const Center(
                child: Text(
                  'No files found for this user.',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_selectedFile != null)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue, width: 2),
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.blue.withOpacity(0.1),
                ),
                child: Column(
                  children: [
                    const Text('Selected File:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(_selectedFileName ?? 'No file selected', style: TextStyle(fontSize: 14)),
                  ],
                ),
              ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _selectFileFromStorage,
              icon: Icon(Icons.upload_file),
              label: const Text('Select File from Storage'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                textStyle: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _isUploading ? null : _uploadFile,
              icon: _isUploading
                  ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )
                  : Icon(Icons.cloud_upload),
              label: const Text('Upload File'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                textStyle: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
