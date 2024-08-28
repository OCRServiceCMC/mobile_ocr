import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logging/logging.dart';
import '../models/question.dart';

class AdminFAQPage extends StatefulWidget {
  const AdminFAQPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AdminFAQPageState createState() => _AdminFAQPageState();
}

class _AdminFAQPageState extends State<AdminFAQPage> {
  static final _logger = Logger('AdminFAQPage');

  List<Question> questions = [];
  final String apiUrl = 'http://10.0.2.2:8081/api';

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
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

  Future<void> _addAnswer(Question question, TextEditingController answerController) async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('No token found');
      }

      if (answerController.text.isNotEmpty) {
        final response = await http.post(
          Uri.parse('$apiUrl/answers/question/${question.messageID}'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'answer': answerController.text,
          }),
        );

        if (response.statusCode == 200) {
          _fetchQuestions(); // Refresh the questions list
          answerController.clear();
        } else {
          _logger.severe('Failed to add answer: ${response.statusCode} ${response.body}');
          throw Exception('Failed to add answer');
        }
      }
    } catch (e) {
      _logger.severe('Error adding answer: $e');
      throw Exception('Failed to add answer');
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
        title: const Text('Admin FAQ Page'),
      ),
      body: ListView.builder(
        itemCount: questions.length,
        itemBuilder: (context, index) {
          final question = questions[index];
          return AdminQuestionTile(
            question: question,
            onAddAnswer: _addAnswer,
            onDelete: _deleteQuestion,
          );
        },
      ),
    );
  }
}

class AdminQuestionTile extends StatelessWidget {
  final Question question;
  final Function(Question, TextEditingController) onAddAnswer;
  final Function(Question) onDelete;

  const AdminQuestionTile({
    super.key,
    required this.question,
    required this.onAddAnswer,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController answerController = TextEditingController();

    return Card(
      child: ExpansionTile(
        title: Text(question.message),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () {
            _confirmDelete(context);
          },
        ),
        children: [
          ...question.answers.map((answer) => ListTile(
                title: Text(answer.answer),
                subtitle: Text('Answered on: ${answer.answerTime}'),
              )),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: answerController,
              decoration: const InputDecoration(
                labelText: 'Write an answer',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              onAddAnswer(question, answerController);
            },
            child: const Text('Add Answer'),
          ),
        ],
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
