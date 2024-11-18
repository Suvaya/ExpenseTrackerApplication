import 'package:flutter/material.dart';
import 'database_helper.dart';

class TransactionHistoryScreen extends StatefulWidget {
  final String alertType;
  final double balance;
  final List<Map<String, dynamic>> transactions;

  TransactionHistoryScreen({
    required this.alertType,
    required this.balance,
    required this.transactions,
  });

  @override
  _TransactionHistoryScreenState createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final Map<int, TextEditingController> _descriptionControllers = {};
  late Future<void> _initialization;

  @override
  void initState() {
    super.initState();
    _initialization = _initializeControllers();
  }

  Future<void> _initializeControllers() async {
    for (var i = 0; i < widget.transactions.length; i++) {
      final controller = TextEditingController();
      _descriptionControllers[i] = controller;

      // Load the description from the database, if it exists
      final description = await _databaseHelper.getDescription(i);
      controller.text = description ?? '';
    }
  }

  @override
  void dispose() {
    _descriptionControllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  double getIncome() {
    return widget.transactions
        .where((transaction) =>
    // check what message to check in the sms like if sms to check is ram. place ram in alert type
    (widget.alertType == "ALERT1" && transaction['type'] == "Credit") ||
        // for ALert1 for money income credit is the keyword whereas for
        (widget.alertType == "ALERT2" && transaction['type'] == "Deposit"))
        .fold(0.0, (sum, transaction) => sum + (transaction['amount'] as double? ?? 0.0));
  }

  double getExpense() {
    return widget.transactions
        .where((transaction) =>
    (widget.alertType == "ALERT1" && transaction['type'] == "Debit") ||
        (widget.alertType == "ALERT2" && transaction['type'] == "Withdrawal"))
        .fold(0.0, (sum, transaction) => sum + (transaction['amount'] as double? ?? 0.0));
  }

  Future<void> saveDescription(int index) async {
    final description = _descriptionControllers[index]?.text ?? '';
    await _databaseHelper.saveDescription(index, description);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Description saved!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final income = getIncome();
    final expense = getExpense();
    final openingBalance = widget.balance - income - expense;

    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.alertType} Transaction History"),
      ),
      body: FutureBuilder<void>(
        future: _initialization,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error loading data"));
          } else {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildInfoBox("Opening Balance", "NPR ${openingBalance.toStringAsFixed(2)}"),
                      _buildInfoBox("Balance", "NPR ${widget.balance.toStringAsFixed(2)}"),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildInfoBox("Income", "NPR ${income.toStringAsFixed(2)}"),
                      _buildInfoBox("Expense", "NPR ${expense.toStringAsFixed(2)}"),
                    ],
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: widget.transactions.length,
                      itemBuilder: (context, index) {
                        final transaction = widget.transactions[index];
                        final controller = _descriptionControllers[index]!;

                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 4.0),
                          elevation: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ListTile(
                                  leading: Icon(
                                    transaction['type'] == "Credit" || transaction['type'] == "Deposit"
                                        ? Icons.arrow_downward
                                        : Icons.arrow_upward,
                                    color: transaction['type'] == "Credit" || transaction['type'] == "Deposit"
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                  title: Text(
                                    "${transaction['date']} - ${transaction['type']}",
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  trailing: Text(
                                    "NPR ${transaction['amount'].toStringAsFixed(2)}",
                                    style: TextStyle(
                                      color: transaction['type'] == "Credit" || transaction['type'] == "Deposit"
                                          ? Colors.green
                                          : Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: controller,
                                        decoration: InputDecoration(
                                          labelText: 'Description',
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.save, color: Colors.blue),
                                      onPressed: () => saveDescription(index),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildInfoBox(String title, String value) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16),
        margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 6,
              offset: Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.blueAccent, width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
