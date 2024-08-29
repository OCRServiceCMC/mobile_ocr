import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data'; // Import thêm cho Uint8List
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
  List<Map<String, dynamic>> _folderFiles = [];
  int? _currentFolderId;
  String? _newFolderName;

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

  Future<void> _selectFilesFromStorage() async {
    PermissionStatus status = await Permission.storage.request();

    if (status.isGranted) {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true, // Cho phép chọn nhiều tệp
        type: FileType.any,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedFiles = result.files;
        });

        print('Selected files: ${_selectedFiles!.map((f) => f.name).join(", ")}');
      } else {
        print('No files selected');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permission denied to access storage.')),
      );
      print('Permission denied');
    }
  }

  // Hàm để chuyển đổi base64 thành Uint8List
  Uint8List _base64ToImage(String base64String) {
    try {
      return base64Decode(base64String);
    } catch (e) {
      print("Error decoding base64: $e");
      return Uint8List(0); // Trả về một mảng trống để tránh crash ứng dụng
    }
  }

  // Hàm upload thư mục với nhiều file (Tạo folder mới)
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
      // Xác định loại MIME dựa trên phần mở rộng của tệp
      String mimeType = _getMimeType(file.extension);

      request.files.add(
        await http.MultipartFile.fromPath(
          'files',
          file.path!,
          contentType: MediaType.parse(mimeType),
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

  // Hàm upload các file mới vào folder đã có (Cập nhật file cho folder)
  Future<void> _uploadFilesToFolder() async {
    if (_selectedFiles == null || _selectedFiles!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No files selected to upload.')),
      );
      return;
    }

    if (_currentFolderId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No folder selected.')),
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

    String url = 'http://10.0.2.2:8081/api/user/folders/$_currentFolderId/upload';

    var request = http.MultipartRequest('POST', Uri.parse(url))
      ..headers['Authorization'] = 'Bearer $token';

    for (var file in _selectedFiles!) {
      // Xác định loại MIME dựa trên phần mở rộng của tệp
      String mimeType = _getMimeType(file.extension);

      request.files.add(
        await http.MultipartFile.fromPath(
          'files',
          file.path!,
          contentType: MediaType.parse(mimeType),
        ),
      );
    }

    try {
      var response = await request.send();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Files uploaded successfully!')),
        );
        _fetchFolderFiles(_currentFolderId!);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to upload files.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred during file upload.')),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  String _getMimeType(String? extension) {
    switch (extension) {
      case 'pdf':
        return 'application/pdf';
      case 'png':
        return 'image/png';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      default:
        return 'application/octet-stream';
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
        _fetchFolderFiles(folderId);
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

  Future<void> _updateFile(int folderId, int fileId) async {
    if (_selectedFiles == null || _selectedFiles!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No file selected for update.')),
      );
      return;
    }

    String? token = await _getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No authentication token found.')),
      );
      return;
    }

    String url = 'http://10.0.2.2:8081/api/user/folders/$folderId/files/$fileId';

    String mimeType = _getMimeType(_selectedFiles!.first.extension);

    var request = http.MultipartRequest('PUT', Uri.parse(url))
      ..headers['Authorization'] = 'Bearer $token'
      ..files.add(
        await http.MultipartFile.fromPath(
          'file',
          _selectedFiles!.first.path!,
          contentType: MediaType.parse(mimeType),
        ),
      );

    try {
      var response = await request.send();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File updated successfully!')),
        );
        _fetchFolderFiles(folderId);
      } else {
        String responseBody = await response.stream.bytesToString();
        print("Update failed: $responseBody");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update file: $responseBody')),
        );
      }
    } catch (e) {
      print("Error during update: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred during file update.')),
      );
    }
  }

  Future<void> _updateFolder(int folderId) async {
    String? token = await _getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No authentication token found.')),
      );
      return;
    }

    if (_newFolderName == null || _newFolderName!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New folder name cannot be empty.')),
      );
      return;
    }

    String url = 'http://10.0.2.2:8081/api/user/folders/$folderId';

    var request = http.MultipartRequest('PUT', Uri.parse(url))
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['folderName'] = _newFolderName!;

    try {
      var response = await request.send();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Folder updated successfully!')),
        );
        _fetchUserFolders();
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

  Future<void> _showUpdateFolderDialog(int folderId) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Update Folder Name"),
          content: TextField(
            onChanged: (value) {
              _newFolderName = value;
            },
            decoration: const InputDecoration(
              hintText: "Enter new folder name",
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Update"),
              onPressed: () {
                Navigator.of(context).pop();
                _updateFolder(folderId);
              },
            ),
          ],
        );
      },
    );
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
          icon: const Icon(Icons.arrow_back),
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
            ? const Center(child: CircularProgressIndicator())
            : _currentFolderId == null
            ? Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _userFolders.length,
                itemBuilder: (context, index) {
                  var folder = _userFolders[index];
                  String folderName = folder['folderName'] ?? 'Unknown Folder';
                  int? folderId = folder['folderID'];

                  if (folderId == null) {
                    return const ListTile(
                      title: Text('Invalid Folder'),
                      subtitle: Text('Folder ID is null'),
                    );
                  }

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: const Icon(Icons.folder, size: 40),
                      title: Text(
                        folderName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.visibility, color: Colors.green),
                            onPressed: () => _fetchFolderFiles(folderId),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteFolder(folderId),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _showUpdateFolderDialog(folderId),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _selectFilesFromStorage,
              icon: const Icon(Icons.upload_file),
              label: const Text('Select Files from Storage'),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _isUploading ? null : _uploadFolder,
              icon: _isUploading
                  ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )
                  : const Icon(Icons.cloud_upload),
              label: const Text('Upload Folder'),
            ),
          ],
        )
            : Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _folderFiles.length,
                itemBuilder: (context, index) {
                  var file = _folderFiles[index];
                  String fileName = file['fileName'] ?? 'Unknown File';
                  int? fileId = file['fileID'];
                  String? base64Thumbnail = file['thumbnail']; // Thêm thumbnail
                  String fileType = file['fileType'];

                  if (fileId == null) {
                    return const ListTile(
                      title: Text('Invalid File'),
                      subtitle: Text('File ID is null'),
                    );
                  }

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: fileType == 'PDF'
                          ? const Icon(Icons.picture_as_pdf, color: Colors.red, size: 40)
                          : base64Thumbnail != null && base64Thumbnail.isNotEmpty
                          ? Image.memory(
                        _base64ToImage(base64Thumbnail), // Sử dụng hình ảnh thu nhỏ
                        width: 50,
                        height: 50,
                      )
                          : const Icon(Icons.insert_drive_file, size: 40),
                      title: Text(
                        fileName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _updateFile(_currentFolderId!, fileId),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteFile(_currentFolderId!, fileId),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _selectFilesFromStorage,
              icon: const Icon(Icons.upload_file),
              label: const Text('Upload Files to Folder'),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _isUploading ? null : _uploadFilesToFolder,
              icon: _isUploading
                  ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )
                  : const Icon(Icons.cloud_upload),
              label: const Text('Upload Files'),
            ),
          ],
        ),
      ),
    );
  }
}
