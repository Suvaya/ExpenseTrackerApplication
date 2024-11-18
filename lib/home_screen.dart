import 'package:flutter/material.dart';
import 'sms_service.dart';
import 'transaction_history_screen.dart';
import 'settings_screen.dart';
import 'db_helper.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedAlert = "ALERT1";
  final SmsService smsService = SmsService();
  final DBHelper dbHelper = DBHelper();

  @override
  void initState() {
    super.initState();
    smsService.requestPermissions();
  }

  Future<void> _openSettings() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SettingsScreen()),
    );
  }

  Future<void> fetchAndNavigateToHistory() async {
    List<Map<String, dynamic>> transactions = [];
    double initialBalance = 0.0;

    if (selectedAlert == "ALERT1") {
      transactions = await smsService.fetchBank1Messages();
      initialBalance = await dbHelper.getBalance("Bank1");
    } else {
      transactions = await smsService.fetchBank2Messages();
      initialBalance = await dbHelper.getBalance("Bank2");
    }

    double adjustedBalance = initialBalance + transactions.fold(0.0, (sum, item) => sum + item['amount']);
    await dbHelper.updateBalance(selectedAlert, adjustedBalance);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionHistoryScreen(
          alertType: selectedAlert,
          balance: adjustedBalance,
          transactions: transactions,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("SMS Transaction Monitor"),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: _openSettings,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButton<String>(
              value: selectedAlert,
              onChanged: (String? newValue) {
                setState(() {
                  selectedAlert = newValue!;
                });
              },
              items: <String>['ALERT1', 'ALERT2']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: fetchAndNavigateToHistory,
              child: Text("View Transaction History"),
            ),
          ],
        ),
      ),
    );
  }
}
