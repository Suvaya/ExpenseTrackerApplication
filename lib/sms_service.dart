import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';

class SmsService {
  final SmsQuery _smsQuery = SmsQuery();
  final DateTime filterDate = DateTime(2024, 11, 07); // Set filter date to 01/05/2011

  Future<void> requestPermissions() async {
    var permission = await Permission.sms.status;
    if (!permission.isGranted) {
      await Permission.sms.request();
    }
  }

  Future<List<Map<String, dynamic>>> fetchBank1Messages() async {
    List<SmsMessage> messages = await _smsQuery.querySms(
      kinds: [SmsQueryKind.inbox],
    );

    RegExp amountPattern = RegExp(r'NPR\s([\d,]+\.\d{2})');
    List<Map<String, dynamic>> transactions = [];

    for (SmsMessage message in messages) {
      // Log message details for debugging
      print("Processing message: ${message.body}");
      print("Message date: ${message.date}");

      // Filter messages by date
      DateTime messageDate = message.date ?? DateTime.now();
      if (messageDate.isBefore(filterDate)) {
        print("Message skipped (before filter date): ${message.body}");
        continue;
      }

      if (message.body != null &&
          message.body!.contains("Bank1 AC") &&
          (message.body!.contains("credited") || message.body!.contains("debited"))) {
        var amountMatch = amountPattern.firstMatch(message.body!);
        if (amountMatch != null) {
          double amount = double.parse(amountMatch.group(1)!.replaceAll(',', ''));
          String date = message.date != null ? message.date.toString() : "Unknown date";

          if (message.body!.contains("debited")) {
            transactions.add({"type": "Debit", "amount": -amount, "date": date});
            print("Message processed as Debit: -$amount");
          } else if (message.body!.contains("credited")) {
            transactions.add({"type": "Credit", "amount": amount, "date": date});
            print("Message processed as Credit: +$amount");
          }
        } else {
          print("Amount pattern not matched: ${message.body}");
        }
      } else {
        print("Message skipped (does not meet Bank1 criteria): ${message.body}");
      }
    }
    return transactions;
  }

  Future<List<Map<String, dynamic>>> fetchBank2Messages() async {
    List<SmsMessage> messages = await _smsQuery.querySms(
      kinds: [SmsQueryKind.inbox],
    );

    RegExp amountPattern = RegExp(r'NPR\s([\d,]+\.\d{2})');
    List<Map<String, dynamic>> transactions = [];

    for (SmsMessage message in messages) {
      // Log message details for debugging
      print("Processing message: ${message.body}");
      print("Message date: ${message.date}");

      // Filter messages by date
      DateTime messageDate = message.date ?? DateTime.now();
      if (messageDate.isBefore(filterDate)) {
        print("Message skipped (before filter date): ${message.body}");
        continue;
      }

      if (message.body != null &&
          message.body!.contains("Bank2") &&
          (message.body!.contains("deposited") || message.body!.contains("withdrawn"))) {
        var amountMatch = amountPattern.firstMatch(message.body!);
        if (amountMatch != null) {
          double amount = double.parse(amountMatch.group(1)!.replaceAll(',', ''));
          String date = message.date != null ? message.date.toString() : "Unknown date";

          if (message.body!.contains("withdrawn")) {
            transactions.add({"type": "Withdrawal", "amount": -amount, "date": date});
            print("Message processed as Withdrawal: -$amount");
          } else if (message.body!.contains("deposited")) {
            transactions.add({"type": "Deposit", "amount": amount, "date": date});
            print("Message processed as Deposit: +$amount");
          }
        } else {
          print("Amount pattern not matched: ${message.body}");
        }
      } else {
        print("Message skipped (does not meet Bank2 criteria): ${message.body}");
      }
    }
    return transactions;
  }
}
