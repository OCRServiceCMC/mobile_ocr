import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';

class FolderManagementPage extends StatefulWidget {
  const FolderManagementPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _FolderManagementPageState createState() => _FolderManagementPageState();
}

class _FolderManagementPageState extends State<FolderManagementPage> {
  String? _selectedFolderName;
  List<PlatformFile>? _selectedFiles;
  bool _isUploading = false;
  bool _isLoading = true;
  List<Map<String, dynamic>> _userFolders = [];

  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  Future<void> _fetchUserFolders() async {
    setState(() {
      _isLoading = true;
    });

    String? token = await _getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No authentication token found.')),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    String url = 'http://10.0.2.2:8081/api/user/folders/all';

    try {
      var response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        List<dynamic> folders = jsonDecode(response.body);

        if (folders.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No folders found for this user.')),
          );
        } else {
          setState(() {
            _userFolders =
                folders.map((folder) => folder as Map<String, dynamic>).toList();
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to fetch folders.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred while fetching folders.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectFolderFromStorage() async {
    PermissionStatus status = await Permission.storage.request();

    if (status.isGranted) {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: true, // Cho phép chọn nhiều files
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedFiles = result.files;
          _selectedFolderName = 'Folder1'; // Example, cần thay thế bằng logic phù hợp
        });

        print('Selected folder: $_selectedFolderName');
        for (var file in _selectedFiles!) {
          print('Selected file: ${file.name}');
        }
      } else {
        setState(() {
          _selectedFolderName = 'No folder selected';
        });
        print('No folder selected');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permission denied to access storage.')),
      );
      print('Permission denied');
    }
  }

  Future<void> _uploadFolder() async {
    if (_selectedFiles == null || _selectedFiles!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No files selected to upload.')),
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
      return;
    }

    String url = 'http://10.0.2.2:8081/api/user/folders/upload';

    var request = http.MultipartRequest('POST', Uri.parse(url))
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['folderName'] = _selectedFolderName ?? 'New Folder';

    for (var file in _selectedFiles!) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'files',
          file.path!,
          contentType: MediaType.parse('application/octet-stream'),
        ),
      );
    }

    try {
      var response = await request.send();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Folder uploaded successfully!')),
        );
        _fetchUserFolders();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to upload folder.')),
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

  Future<void> _deleteFolder(int folderId) async {
    String? token = await _getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No authentication token found.')),
      );
      return;
    }

    String url = 'http://10.0.2.2:8081/api/user/folders/$folderId';

    try {
      var response = await http.delete(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Folder deleted successfully!')),
        );
        _fetchUserFolders();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete folder.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred during deletion.')),
      );
    }
  }

  Future<void> _viewFolderFiles(int folderId) async {
    String? token = await _getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No authentication token found.')),
      );
      return;
    }

    String url = 'http://10.0.2.2:8081/api/user/folders/$folderId/files';

    try {
      var response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        var files = jsonDecode(response.body) as List<dynamic>;
        print('Folder files: $files');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to fetch folder files.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred while fetching folder files.')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUserFolders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Folder Management'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _userFolders.isNotEmpty
                  ? ListView.builder(
                itemCount: _userFolders.length,
                itemBuilder: (context, index) {
                  var folder = _userFolders[index];
                  String folderName = folder['folderName'] ?? 'Unknown Folder'; // Đảm bảo giá trị không phải là null
                  int? folderId = folder['folderId']; // Có thể null, cần kiểm tra trước khi sử dụng

                  // Kiểm tra nếu folderId là null
                  if (folderId == null) {
                    return ListTile(
                      title: Text('Invalid Folder'),
                      subtitle: Text('Folder ID is null'),
                    );
                  }

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: Icon(Icons.folder, size: 40),
                      title: Text(
                        folderName,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.visibility, color: Colors.green),
                            onPressed: () => _viewFolderFiles(folderId),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteFolder(folderId),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              )
                  : const Center(
                child: Text(
                  'No folders found for this user.',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _selectFolderFromStorage,
              icon: Icon(Icons.folder_open),
              label: const Text('Select Folder from Storage'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                textStyle: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _isUploading ? null : _uploadFolder,
              icon: _isUploading
                  ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )
                  : Icon(Icons.cloud_upload),
              label: const Text('Upload Folder'),
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
