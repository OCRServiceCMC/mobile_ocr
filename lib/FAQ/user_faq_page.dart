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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FAQ Page'),
      ),
      body: ListView.builder(
        itemCount: questions.length,
        itemBuilder: (context, index) {
          final question = questions[index];
          return QuestionTile(question: question);
        },
      ),
    );
  }
}

class QuestionTile extends StatelessWidget {
  final Question question;

  const QuestionTile({super.key, required this.question});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        title: Text(question.message),
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
}
