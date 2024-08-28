import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UpgradeServicePage extends StatefulWidget {
  @override
  _UpgradeServicePageState createState() => _UpgradeServicePageState();
}

class _UpgradeServicePageState extends State<UpgradeServicePage> {
  int amountGP = 0;
  String? errorMessage;
  bool loading = false;
  Map<String, dynamic>? requestInfo;
  Map<String, dynamic>? storageInfo;
  int currentGP = 0;

  @override
  void initState() {
    super.initState();
    _fetchServiceInfo();
    _fetchCurrentGP();
  }

  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  Future<void> _fetchCurrentGP() async {
    final token = await _getToken();
    if (token == null) {
      setState(() {
        errorMessage = "Authentication token not found.";
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8081/api/transactions/gpUser'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        setState(() {
          currentGP = jsonDecode(response.body)['currentGP'];
        });
      } else {
        setState(() {
          errorMessage = "Failed to fetch current GP.";
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "An error occurred while fetching current GP.";
      });
    }
  }

  Future<void> _fetchServiceInfo() async {
    final token = await _getToken();
    if (token == null) {
      setState(() {
        errorMessage = "Authentication token not found.";
      });
      return;
    }

    try {
      final requestResponse = await http.get(
        Uri.parse('http://10.0.2.2:8081/api/transactions/request-info'),
        headers: {'Authorization': 'Bearer $token'},
      );

      final storageResponse = await http.get(
        Uri.parse('http://10.0.2.2:8081/api/transactions/storage-info'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (requestResponse.statusCode == 200 && storageResponse.statusCode == 200) {
        setState(() {
          requestInfo = jsonDecode(requestResponse.body);
          storageInfo = jsonDecode(storageResponse.body);
        });
      } else {
        setState(() {
          errorMessage = "Failed to fetch service information.";
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "An error occurred while fetching service information.";
      });
    }
  }

  Future<void> _upgradeStorage(int amountGP) async {
    final token = await _getToken();
    if (token == null) {
      setState(() {
        errorMessage = "Authentication token not found.";
      });
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8081/api/transactions/upgrade-storage/$amountGP'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        setState(() {
          errorMessage = null;
          _fetchServiceInfo();
          _fetchCurrentGP();
          _showSuccessMessage("Storage upgraded successfully!");
        });
      } else {
        setState(() {
          errorMessage = "Failed to upgrade storage.";
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "An error occurred while upgrading storage.";
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> _upgradeRequests(int amountGP) async {
    final token = await _getToken();
    if (token == null) {
      setState(() {
        errorMessage = "Authentication token not found.";
      });
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8081/api/transactions/upgrade-requests/$amountGP'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        setState(() {
          errorMessage = null;
          _fetchServiceInfo();
          _fetchCurrentGP();
          _showSuccessMessage("Requests upgraded successfully!");
        });
      } else {
        setState(() {
          errorMessage = "Failed to upgrade requests.";
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "An error occurred while upgrading requests.";
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Hàm chuyển đổi từ byte sang MB
  String _formatStorage(int bytes) {
    return (bytes / (1024 * 1024)).toStringAsFixed(2) + ' MB';
  }

  Widget _buildServiceInfo() {
    if (requestInfo == null || storageInfo == null) {
      return Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: Icon(Icons.monetization_on, color: Colors.blue),
          title: Text('Current GP', style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text('$currentGP'),
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.assignment_turned_in, color: Colors.green),
          title: Text('Request Info', style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Total Requests: ${requestInfo!["totalRequests"]}'),
              Text('Remaining Requests: ${requestInfo!["remainingRequests"]}'),
              Text('Used Requests: ${requestInfo!["usedRequests"]}'),
              Text('Upgraded Requests: ${requestInfo!["upgradedRequests"]}'),
            ],
          ),
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.storage, color: Colors.orange),
          title: Text('Storage Info', style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Used Storage: ${_formatStorage(storageInfo!["usedStorage"])}'),
              Text('Available Storage: ${_formatStorage(storageInfo!["availableStorage"])}'),
              Text('Upgraded Storage: ${_formatStorage(storageInfo!["upgradedStorage"])}'),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upgrade Service'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (errorMessage != null)
              Text(
                errorMessage!,
                style: TextStyle(color: Colors.red),
              ),
            if (requestInfo != null && storageInfo != null) _buildServiceInfo(),
            SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                labelText: 'Enter GP Amount',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.input),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                amountGP = int.tryParse(value) ?? 0;
              },
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    _upgradeStorage(amountGP);
                  },
                  icon: Icon(Icons.storage),
                  label: Text('Upgrade Storage'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    _upgradeRequests(amountGP);
                  },
                  icon: Icon(Icons.assignment),
                  label: Text('Upgrade Requests'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                ),
              ],
            ),
            if (loading) ...[
              SizedBox(height: 20),
              Center(child: CircularProgressIndicator()),
            ],
          ],
        ),
      ),
    );
  }
}
