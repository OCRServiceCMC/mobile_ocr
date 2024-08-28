import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  String? _message;

  Future<void> _sendForgotPasswordRequest(String email) async {
    setState(() {
      _isLoading = true;
      _message = null;
    });

    final url = Uri.parse('http://10.0.2.2:8081/api/auth/forgot-password?email=$email');

    try {
      final response = await http.post(url);

      if (response.statusCode == 200) {
        setState(() {
          _message = 'Password reset link has been sent to your email.';
        });
      } else {
        setState(() {
          _message = 'Failed to send reset link. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _message = 'An error occurred. Please check your internet connection and try again.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Icon
            const Icon(
              Icons.lock_outline,
              size: 100,
              color: Colors.blue,
            ),
            const SizedBox(height: 20),
            // Text field for email input
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Enter your email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            // Send button
            ElevatedButton(
              onPressed: _isLoading ? null : () => _sendForgotPasswordRequest(_emailController.text),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )
                  : const Text(
                'Send Reset Link',
                style: TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 20),
            // Message
            if (_message != null)
              Text(
                _message!,
                style: TextStyle(
                  color: _message!.contains('sent') ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}
