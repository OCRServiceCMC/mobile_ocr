import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';

class FolderManagementPage extends StatefulWidget {
  const FolderManagementPage({super.key});

  @override
  _FolderManagementPageState createState() => _FolderManagementPageState();
}

class _FolderManagementPageState extends State<FolderManagementPage> {
  String? _selectedFolderName;
  List<PlatformFile>? _selectedFiles;
  bool _isUploading = false;
  bool _isLoading = true;
  List<Map<String, dynamic>> _userFolders = [];
  List<Map<String, dynamic>> _folderFiles = []; // Danh sách tệp của thư mục hiện tại
  int? _currentFolderId; // ID của thư mục hiện tại

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
            _userFolders = folders.map((folder) => folder as Map<String, dynamic>).toList();
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

  Future<void> _fetchFolderFiles(int folderId) async {
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

    String url = 'http://10.0.2.2:8081/api/user/folders/$folderId/files';

    try {
      var response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        List<dynamic> files = jsonDecode(response.body);

        setState(() {
          _currentFolderId = folderId;
          _folderFiles = files.map((file) => file as Map<String, dynamic>).toList();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to fetch folder files.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred while fetching folder files.')),
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

  Future<void> _deleteFile(int folderId, int fileId) async {
    String? token = await _getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No authentication token found.')),
      );
      return;
    }

    String url = 'http://10.0.2.2:8081/api/user/folders/$folderId/files/$fileId';

    try {
      var response = await http.delete(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File deleted successfully!')),
        );
        _fetchFolderFiles(folderId); // Refresh the folder files
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete file.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred during file deletion.')),
      );
    }
  }

  Future<void> _updateFile(int folderId, int fileId, String filePath) async {
    String? token = await _getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No authentication token found.')),
      );
      return;
    }

    String url = 'http://10.0.2.2:8081/api/user/folders/$folderId/files/$fileId';

    var request = http.MultipartRequest('PUT', Uri.parse(url))
      ..headers['Authorization'] = 'Bearer $token'
      ..files.add(
        await http.MultipartFile.fromPath(
          'file',
          filePath,
          contentType: MediaType.parse('application/octet-stream'),
        ),
      );

    try {
      var response = await request.send();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File updated successfully!')),
        );
        _fetchFolderFiles(folderId); // Refresh folder files after update
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update file.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred during file update.')),
      );
    }
  }


  Future<void> _updateFolder(int folderId, String newFolderName) async {
    String? token = await _getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No authentication token found.')),
      );
      return;
    }

    String url = 'http://10.0.2.2:8081/api/user/folders/$folderId';

    var request = http.MultipartRequest('PUT', Uri.parse(url))
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['folderName'] = newFolderName;

    try {
      var response = await request.send();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Folder updated successfully!')),
        );
        _fetchUserFolders(); // Cập nhật danh sách thư mục sau khi cập nhật tên thư mục
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update folder.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred during update.')),
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
        leading: _currentFolderId != null
            ? IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              _currentFolderId = null;
              _folderFiles.clear();
            });
          },
        )
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _currentFolderId == null
            ? ListView.builder(
          itemCount: _userFolders.length,
          itemBuilder: (context, index) {
            var folder = _userFolders[index];
            String folderName = folder['folderName'] ?? 'Unknown Folder';
            int? folderId = folder['folderID'];

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
                      onPressed: () => _fetchFolderFiles(folderId),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteFolder(folderId),
                    ),
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _updateFolder(folderId, "UpdatedFolderName"),
                    ),
                  ],
                ),
              ),
            );
          },
        )
            : ListView.builder(
          itemCount: _folderFiles.length,
          itemBuilder: (context, index) {
            var file = _folderFiles[index];
            String fileName = file['fileName'] ?? 'Unknown File';
            int? fileId = file['fileID'];

            if (fileId == null) {
              return ListTile(
                title: Text('Invalid File'),
                subtitle: Text('File ID is null'),
              );
            }

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: Icon(Icons.insert_drive_file, size: 40),
                title: Text(
                  fileName,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _updateFile(_currentFolderId!, fileId, 'path/to/updated/file'),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteFile(_currentFolderId!, fileId),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
