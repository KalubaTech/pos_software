import 'dart:math';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/currency_formatter.dart';

class WalletService {
  // Calculate charge based on payment method and amount
  static double calculateCharge({
    required double amount,
    required String paymentMethod,
  }) {
    // Default charge rates (can be configured per business)
    Map<String, Map<String, dynamic>> chargeRates = {
      'MTN': {'percentage': 1.5, 'min': 0.10, 'max': 10.00},
      'Airtel': {'percentage': 1.5, 'min': 0.10, 'max': 10.00},
      'Vodafone': {'percentage': 1.75, 'min': 0.15, 'max': 12.00},
      'All': {'percentage': 1.5, 'min': 0.10, 'max': 10.00},
    };

    final rate = chargeRates[paymentMethod] ?? chargeRates['All']!;
    double charge = amount * (rate['percentage'] / 100);

    // Apply min and max limits
    if (charge < rate['min']) charge = rate['min'];
    if (charge > rate['max']) charge = rate['max'];

    return double.parse(charge.toStringAsFixed(2));
  }

  // Calculate net amount after charges
  static double calculateNetAmount({
    required double amount,
    required double chargeAmount,
  }) {
    return double.parse((amount - chargeAmount).toStringAsFixed(2));
  }

  // Generate unique transaction ID
  static String generateTransactionId({String prefix = 'TXN'}) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(9999);
    return '$prefix${timestamp}${random.toString().padLeft(4, '0')}';
  }

  // Generate unique request ID
  static String generateRequestId({String prefix = 'WDR'}) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(9999);
    return '$prefix${timestamp}${random.toString().padLeft(4, '0')}';
  }

  // Validate mobile money number format
  static bool isValidMobileNumber(String phone) {
    // Remove spaces and special characters
    final cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');

    // Check if it's a valid length (typically 10-15 digits)
    if (cleaned.length < 10 || cleaned.length > 15) return false;

    return true;
  }

  // Format currency using system settings
  static String formatCurrency(double amount) {
    return CurrencyFormatter.format(amount);
  }

  // Get transaction type display name
  static String getTransactionTypeDisplay(String type) {
    switch (type) {
      case 'deposit':
        return 'Deposit';
      case 'withdrawal':
        return 'Withdrawal';
      case 'charge':
        return 'Transaction Charge';
      case 'refund':
        return 'Refund';
      case 'settlement':
        return 'Settlement';
      default:
        return type;
    }
  }

  // Get transaction status display name
  static String getTransactionStatusDisplay(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'completed':
        return 'Completed';
      case 'failed':
        return 'Failed';
      case 'reversed':
        return 'Reversed';
      default:
        return status;
    }
  }

  // Get payment method display name
  static String getPaymentMethodDisplay(String? method) {
    if (method == null) return 'Unknown';
    switch (method) {
      case 'MTN':
        return 'MTN Mobile Money';
      case 'Airtel':
        return 'Airtel Money';
      case 'Vodafone':
        return 'Vodafone Cash';
      default:
        return method;
    }
  }

  // Validate withdrawal amount
  static String? validateWithdrawalAmount({
    required double amount,
    required double walletBalance,
    double minWithdrawal = 10.0,
    double maxWithdrawal = 10000.0,
  }) {
    if (amount <= 0) {
      return 'Amount must be greater than zero';
    }
    if (amount < minWithdrawal) {
      return 'Minimum withdrawal amount is ${formatCurrency(minWithdrawal)}';
    }
    if (amount > maxWithdrawal) {
      return 'Maximum withdrawal amount is ${formatCurrency(maxWithdrawal)}';
    }
    if (amount > walletBalance) {
      return 'Insufficient wallet balance';
    }
    return null;
  }

  // Get withdrawal method display name
  static String getWithdrawalMethodDisplay(String method) {
    switch (method) {
      case 'bank_transfer':
        return 'Bank Transfer';
      case 'mobile_money':
        return 'Mobile Money';
      case 'cash':
        return 'Cash Pickup';
      default:
        return method;
    }
  }

  // Calculate percentage change
  static double calculatePercentageChange({
    required double oldValue,
    required double newValue,
  }) {
    if (oldValue == 0) return 0;
    return ((newValue - oldValue) / oldValue) * 100;
  }

  // Get time ago string
  static String getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years year${years > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  // Process mobile money payment through Lenco API
  static Future<Map<String, dynamic>?> processMobileMoneyPayment({
    required double amount,
    required String phoneNumber,
    required String operator, // 'airtel', 'mtn', 'zamtel'
    required String reference,
  }) async {
    try {
      // Prepare request
      var headers = {'Content-Type': 'application/json'};

      var request = http.Request(
        'POST',
        Uri.parse(
          'https://kalootech.com/pay/lenco/mobile-money/collection.php',
        ),
      );

      request.body = json.encode({
        "amount": amount.toString(),
        "reference": reference,
        "phone": phoneNumber,
        "operator": operator.toLowerCase(), // airtel, mtn, zamtel
        "country": "zm",
        "bearer": "merchant",
      });

      request.headers.addAll(headers);

      print('Sending wallet payment request: $reference');
      print('Amount: $amount, Phone: $phoneNumber, Operator: $operator');

      // Send request
      http.StreamedResponse response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print('Response status: ${response.statusCode}');
      print('Response body: $responseBody');

      if (response.statusCode == 200) {
        final responseData = json.decode(responseBody);

        // Check if payment was successful based on Lenco API response
        if (responseData['status'] == true) {
          final data = responseData['data'];
          final status = data['status'];

          print('Payment initiated with status: $status');

          // Payment initiated successfully
          return {
            'success': true,
            'status': status,
            'transactionId': reference,
            'lencoReference': data['lenco_reference'] ?? data['lencoReference'],
            'amount': amount,
            'phone': phoneNumber,
            'operator': operator,
            'message': responseData['message'] ?? 'Payment initiated',
            'paymentId': data['id'],
            'initiatedAt': data['initiated_at'] ?? data['initiatedAt'],
            'rawResponse': responseData,
          };
        } else {
          // Payment failed
          return {
            'success': false,
            'error': responseData['message'] ?? 'Payment failed',
            'statusCode': response.statusCode,
          };
        }
      } else {
        // Other errors
        return {
          'success': false,
          'error': response.reasonPhrase ?? 'Payment failed',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      print('Payment error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  // Check transaction status through Lenco API
  static Future<Map<String, dynamic>?> checkTransactionStatus(
    String reference, {
    String? lencoReference,
  }) async {
    try {
      // Use lenco_reference if provided, otherwise use reference
      final queryParam = lencoReference != null
          ? 'lenco_reference=$lencoReference'
          : 'reference=$reference';

      final url = Uri.parse(
        'https://kalootech.com/pay/lenco/transaction.php?$queryParam',
      );

      print('Checking transaction status: $queryParam');

      final response = await http.get(url);

      print('Status check response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('Status response: ${response.body}');

        if (responseData['status'] == true) {
          final data = responseData['data'];

          return {
            'success': true,
            'found': true,
            'status': data['status'], // completed, failed, pay-offline
            'event': data['event'],
            'transactionId': data['reference'],
            'lencoReference': data['lenco_reference'],
            'amount': double.tryParse(data['amount'].toString()) ?? 0.0,
            'completedAt': data['completed_at'],
            'reasonForFailure': data['reason_for_failure'],
            'mmAccountName': data['mm_account_name'],
            'mmOperatorTxnId': data['mm_operator_txn_id'],
            'rawResponse': responseData,
          };
        } else {
          // Transaction not found yet
          return {
            'success': true,
            'found': false,
            'message': responseData['message'] ?? 'Transaction not found',
          };
        }
      } else {
        return {
          'success': false,
          'found': false,
          'error': response.reasonPhrase ?? 'Failed to check status',
        };
      }
    } catch (e) {
      print('Status check error: $e');
      return {'success': false, 'found': false, 'error': e.toString()};
    }
  }
}
