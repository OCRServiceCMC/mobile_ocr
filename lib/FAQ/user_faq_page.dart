import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/question.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logging/logging.dart';

class FAQPage extends StatefulWidget {
  const FAQPage({super.key});

  @override
  _FAQPageState createState() => _FAQPageState();
}

class _FAQPageState extends State<FAQPage> {
  static final _logger = Logger('FAQPage');
  List<Question> questions = [];
  final String apiUrl = 'http://10.0.2.2:8081/api';
  final TextEditingController _questionController = TextEditingController();
  late String _currentUserID;

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
    _getCurrentUserID();
  }

  Future<void> _getCurrentUserID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUserID = prefs.getString('userID') ?? '';
    });
  }

  Future<String?> _getAuthToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  Future<void> _fetchQuestions() async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('No token found');
      }

      final response = await http.get(
        Uri.parse('$apiUrl/questions/all-with-answers'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        setState(() {
          questions = data.map((item) => Question.fromJson(item)).toList();
        });
      } else {
        _logger.severe('Failed to load questions: ${response.statusCode} ${response.body}');
        throw Exception('Failed to load questions');
      }
    } catch (e) {
      _logger.severe('Error fetching questions: $e');
      throw Exception('Failed to fetch questions');
    }
  }

  Future<void> _addQuestion() async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('No token found');
      }

      if (_questionController.text.isNotEmpty) {
        final response = await http.post(
          Uri.parse('$apiUrl/questions'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'message': _questionController.text,
          }),
        );

        if (response.statusCode == 200) {
          _fetchQuestions(); // Refresh the questions list
          _questionController.clear();
        } else {
          _logger.severe('Failed to add question: ${response.statusCode} ${response.body}');
          throw Exception('Failed to add question');
        }
      }
    } catch (e) {
      _logger.severe('Error adding question: $e');
      throw Exception('Failed to add question');
    }
  }

  Future<void> _editQuestion(Question question) async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('No token found');
      }

      final TextEditingController editController = TextEditingController(text: question.message);

      final response = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Edit Question'),
          content: TextField(
            controller: editController,
            decoration: const InputDecoration(
              labelText: 'Update your question',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final response = await http.put(
                  Uri.parse('$apiUrl/questions/${question.messageID}'),
                  headers: {
                    'Content-Type': 'application/json',
                    'Authorization': 'Bearer $token',
                  },
                  body: jsonEncode({
                    'message': editController.text,
                  }),
                );

                if (response.statusCode == 200) {
                  _fetchQuestions();
                  Navigator.pop(context, true);
                } else {
                  _logger.severe('Failed to update question: ${response.statusCode} ${response.body}');
                  throw Exception('Failed to update question');
                }
              },
              child: const Text('Update'),
            ),
          ],
        ),
      );

      if (response == true) {
        setState(() {
          question.message = editController.text;
        });
      }
    } catch(e) {
      _logger.severe('Error editing question: $e');
      throw Exception('Failed to edit question');
    }
  }

  Future<void> _deleteQuestion(Question question) async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('No token found');
      }

      final response = await http.delete(
        Uri.parse('$apiUrl/questions/${question.messageID}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        setState(() {
          questions.remove(question); // Remove the question from the list
        });
        _logger.info('Question deleted successfully');
      } else {
        _logger.severe('Failed to delete question: ${response.statusCode} ${response.body}');
        throw Exception('Failed to delete question');
      }
    } catch (e) {
      _logger.severe('Error deleting question: $e');
      throw Exception('Failed to delete question');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FAQ Page'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _questionController,
              decoration: const InputDecoration(
                labelText: 'Ask a new question',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _addQuestion,
            child: const Text('Add Question'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: questions.length,
              itemBuilder: (context, index) {
                final question = questions[index];
                return QuestionTile(
                  question: question,
                  isOwner: question.userID.toString() == _currentUserID,
                  onEdit: _editQuestion,
                  onDelete: _deleteQuestion,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class QuestionTile extends StatelessWidget {
  final Question question;
  final bool isOwner;
  final Function(Question) onEdit;
  final Function(Question) onDelete;

  const QuestionTile({
    super.key,
    required this.question,
    required this.isOwner,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        title: Text(question.message),
        trailing: isOwner
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () {
                      onEdit(question);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      _confirmDelete(context);
                    },
                  ),
                ],
              )
            : null,
        children: question.answers.isNotEmpty
            ? question.answers
                .map((answer) => ListTile(
                      title: Text(answer.answer),
                      subtitle: Text('Answered on: ${answer.answerTime}'),
                    ))
                .toList()
            : [const ListTile(title: Text('No answers yet'))],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Question'),
          content: const Text('Are you sure you want to delete this question?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onDelete(question);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
