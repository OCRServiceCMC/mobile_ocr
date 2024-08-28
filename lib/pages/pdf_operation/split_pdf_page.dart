// import 'package:flutter/material.dart';
// import 'package:file_picker/file_picker.dart';
// import 'dart:io';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:path_provider/path_provider.dart';

// class SplitPDFPage extends StatefulWidget {
//   const SplitPDFPage({Key? key}) : super(key: key);

//   @override
//   _SplitPDFPageState createState() => _SplitPDFPageState();
// }

// class _SplitPDFPageState extends State<SplitPDFPage> {
//   List<File> _selectedFiles = [];
//   final _startPageController = TextEditingController();
//   final _endPageController = TextEditingController();

//   Future<void> _pickFiles() async {
//     final result = await FilePicker.platform.pickFiles(
//       type: FileType.custom,
//       allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
//       allowMultiple: true,
//     );

//     if (result != null && result.files.isNotEmpty) {
//       setState(() {
//         _selectedFiles = result.files.map((file) => File(file.path!)).toList();
//       });
//     }
//   }

//   Future<void> _convertImagesToPDF() async {
//     final pdf = pw.Document();
//     for (var file in _selectedFiles) {
//       if (file.path.endsWith('.jpg') || file.path.endsWith('.jpeg') || file.path.endsWith('.png')) {
//         final image = pw.MemoryImage(file.readAsBytesSync());
//         pdf.addPage(pw.Page(
//           build: (pw.Context context) => pw.Center(
//             child: pw.Image(image),
//           ),
//         ));
//       }
//     }

//     final outputDir = await getApplicationDocumentsDirectory();
//     final outputFilePath = "${outputDir.path}/converted_images.pdf";
//     final outputFile = File(outputFilePath);
//     await outputFile.writeAsBytes(await pdf.save());

//     setState(() {
//       _selectedFiles = [outputFile];
//     });

//     print('Images converted to PDF: $outputFilePath');
//   }

//   void _splitPDF() {
//     final fileName = _selectedFiles.isNotEmpty ? _selectedFiles.first.path.split('/').last : '';
//     print("Splitting entire PDF: $fileName");
//     // TODO: Implement the API call to split the entire PDF
//   }

//   void _splitPDFByRange() {
//     final startPage = int.tryParse(_startPageController.text) ?? 1;
//     final endPage = int.tryParse(_endPageController.text) ?? 1;
//     final fileName = _selectedFiles.isNotEmpty ? _selectedFiles.first.path.split('/').last : '';

//     print("Splitting PDF: $fileName from page $startPage to $endPage");
//     // TODO: Implement the API call to split the PDF by range
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Split PDF by Range'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             GestureDetector(
//               onTap: _pickFiles,
//               child: Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.blue),
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: _selectedFiles.isEmpty
//                     ? const Text('Upload PDF or Image files', style: TextStyle(fontSize: 16))
//                     : Text(_selectedFiles.map((file) => file.path.split('/').last).join(', '), style: const TextStyle(fontSize: 16)),
//               ),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _convertImagesToPDF,
//               child: const Text('Convert Images to PDF'),
//             ),
//             const SizedBox(height: 20),
//             TextField(
//               controller: _startPageController,
//               keyboardType: TextInputType.number,
//               decoration: const InputDecoration(
//                 labelText: 'Start Page',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 20),
//             TextField(
//               controller: _endPageController,
//               keyboardType: TextInputType.number,
//               decoration: const InputDecoration(
//                 labelText: 'End Page',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _splitPDF,
//               child: const Text('Split Entire PDF'),
//             ),
//             const SizedBox(height: 10),
//             ElevatedButton(
//               onPressed: _splitPDFByRange,
//               child: const Text('Split PDF by Range'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
