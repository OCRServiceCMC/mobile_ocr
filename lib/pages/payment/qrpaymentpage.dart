import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class QRPaymentPage extends StatefulWidget {
  @override
  _QRPaymentPageState createState() => _QRPaymentPageState();
}

class _QRPaymentPageState extends State<QRPaymentPage> {
  int amount = 0;
  String qrUrl = "";
  bool transactionSuccess = false;
  String error = "";
  bool loading = false;
  int countdown = 120; // 120 seconds (2 minutes)
  Timer? _timer;

  final String bankId = "MBBank";
  final String accountNo = "0346567085";
  final String template = "7brqL9G";
  final String accountName = "TO QUANG DUC";
  final String description = "DEPOSITOCR"; // Mô tả giao dịch

  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  @override
  void dispose() {
    _timer?.cancel(); // Hủy Timer khi State bị dispose
    super.dispose();
  }

  void _startCountdown() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (countdown > 0) {
        if (mounted) {
          setState(() {
            countdown--;
          });
        }
      } else {
        timer.cancel();
        _handleTimeout();
      }
    });
  }

  void _generateQrCode() {
    if (amount > 0) {
      setState(() {
        qrUrl =
        "https://img.vietqr.io/image/$bankId-$accountNo-$template.png?amount=$amount&addInfo=$description&accountName=$accountName";
        countdown = 120; // Đặt lại thời gian đếm ngược thành 2 phút
      });
      _startCountdown();
    } else {
      setState(() {
        qrUrl = "";
      });
    }
  }

  Future<void> _checkTransactionStatus() async {
    setState(() {
      loading = true;
    });

    final token = await _getToken();
    if (token == null) {
      setState(() {
        error = "Authentication token not found.";
        loading = false;
      });
      return;
    }

    try {
      final response = await http.get(Uri.parse(
          "https://script.googleusercontent.com/macros/echo?user_content_key=aWx-8gwYrg-aD_X51n36flT8mPU87B20GPg9ckFuCytMlWa_X7rkC6rdt26AFR_TxjhuqGi_DzwH-dP7orOrhVmLyJ76PcRrm5_BxDlH2jW0nuo2oDemN9CCS2h10ox_1xSncGQajx_ryfhECjZEnDfawM_bMNmlzNBBGKUk77Caw_y3EDiIqIYccBzM6IKypNfZ7dC0QCsuee0eUIkJepQ2dUz5PjeUPfLZ3VgZKw-N0E_1dFcejNz9Jw9Md8uu&lib=MiJ6PZlEM574xunmtReGn1uN-aGJIc-mt"));

      if (response.statusCode == 200) {
        final List<dynamic> transactions = jsonDecode(response.body)['data'];
        final matchedTransaction = transactions.firstWhere(
                (transaction) =>
            transaction["Giá trị"] == amount &&
                transaction["Mô tả"].contains(description),
            orElse: () => null);

        if (matchedTransaction != null) {
          if (mounted) {
            setState(() {
              transactionSuccess = true;
            });
          }
          await _processDeposit(amount, token);
          Timer(Duration(seconds: 5), () {
            if (mounted) {
              setState(() {
                transactionSuccess = false;
              });
            }
          });
        } else {
          Timer(Duration(seconds: 5), _checkTransactionStatus);
        }
      } else {
        if (mounted) {
          setState(() {
            error = "Failed to check transaction status.";
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          error = "Failed to check transaction status.";
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  Future<void> _processDeposit(int depositAmount, String token) async {
    try {
      final response = await http.post(
        // Uri.parse("http://10.0.2.2:8081/api/transactions/deposit/$depositAmount"),
        Uri.parse("http://103.145.63.232:8081/api/transactions/deposit/$depositAmount"),
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode != 200) {
        throw Exception("Failed to process deposit.");
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          error = e.toString();
        });
      }
    }
  }

  void _handlePaymentClick() {
    if (amount > 0) {
      setState(() {
        transactionSuccess = false;
        loading = true;
      });
      _checkTransactionStatus();
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Please select an amount.")));
    }
  }

  void _handleTimeout() {
    if (mounted) {
      setState(() {
        error = "Quá hạn! Giao dịch đã hết hạn. Vui lòng tạo mã QR mới.";
        qrUrl = "";
        loading = false;
      });
    }
  }

  String _formatTime(int seconds) {
    final minutes = (seconds / 60).floor();
    final remainingSeconds = seconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("QR Payment"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButton<int>(
              value: amount,
              items: [
                DropdownMenuItem(value: 0, child: Text("Select Amount")),
                DropdownMenuItem(value: 2000, child: Text("2000 VNĐ")),
                DropdownMenuItem(value: 5000, child: Text("5000 VNĐ")),
                DropdownMenuItem(value: 10000, child: Text("10000 VNĐ")),
              ],
              onChanged: (value) {
                setState(() {
                  amount = value!;
                  _generateQrCode();
                });
              },
            ),
            if (qrUrl.isNotEmpty) ...[
              Image.network(qrUrl), // Hiển thị ảnh QR bằng URL
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Time left to complete payment: ${_formatTime(countdown)}",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: loading || countdown == 0 ? null : _handlePaymentClick,
              child: loading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text("Confirm Payment"),
            ),
            if (transactionSuccess)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Payment successful!",
                  style: TextStyle(color: Colors.green),
                  textAlign: TextAlign.center,
                ),
              ),
            if (error.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  error,
                  style: TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
