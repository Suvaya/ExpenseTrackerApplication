import 'package:flutter/material.dart';
import 'db_helper.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _Bank1Controller = TextEditingController();
  final TextEditingController _Bank2Controller = TextEditingController();
  final DBHelper dbHelper = DBHelper();

  @override
  void initState() {
    super.initState();
    _loadBalances();
  }

  Future<void> _loadBalances() async {
    double Bank1Balance = await dbHelper.getBalance('Bank1');
    double Bank2Balance = await dbHelper.getBalance('Bank2');
    setState(() {
      _Bank1Controller.text = Bank1Balance.toString();
      _Bank2Controller.text = Bank2Balance.toString();
    });
  }

  Future<void> _saveBalances() async {
    double Bank1Balance = double.tryParse(_Bank1Controller.text) ?? 0.0;
    double Bank2Balance = double.tryParse(_Bank2Controller.text) ?? 0.0;
    await dbHelper.updateBalance('Bank1', Bank1Balance);
    await dbHelper.updateBalance('Bank2', Bank2Balance);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Set Opening Balances")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _Bank1Controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Opening Balance for Bank1",
              ),
            ),
            TextField(
              controller: _Bank2Controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Opening Balance for Bank2",
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveBalances,
              child: Text("Save Balances"),
            ),
          ],
        ),
      ),
    );
  }
}
