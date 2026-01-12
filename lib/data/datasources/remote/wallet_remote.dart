import 'package:dio/dio.dart';

class WalletRemote {
  final Dio dio;

  WalletRemote(this.dio);

  Future<double> getBalance(String userId) async {
    final res = await dio.get('/api/wallets/$userId');
    final data = res.data;
    if (data is Map && data['balance'] != null) {
      final bal = data['balance'];
      if (bal is num) return bal.toDouble();
      return double.tryParse(bal.toString()) ?? 0;
    }
    if (data is num) return data.toDouble();
    return 0;
  }

  Future<Map<String, dynamic>> topUp({
    required String userId,
    required double amount,
    required String currency,
    required String returnUrl,
  }) async {
    final res = await dio.post(
      '/api/sepay/topup/$userId',
      data: {
        'amount': amount,
      },
    );
    final data = res.data;
    if (data is Map<String, dynamic>) {
      return Map<String, dynamic>.from(data);
    }
    return <String, dynamic>{};
  }

  Future<List<Map<String, dynamic>>> getTransactions(String userId) async {
    final res = await dio.get('/api/wallets/$userId/transactions');
    final data = res.data;
    if (data is List) {
      return data.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    }
    if (data is Map && data['data'] is List) {
      return (data['data'] as List)
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    return const [];
  }

  Future<Map<String, dynamic>> withdraw({required String userId, required double amount, required String bankAccount, required String bankName}) async {
    final res = await dio.post(
      '/api/wallets/$userId/withdraw',
      data: {
        'amount': amount,
        'bankAccount': bankAccount,
        'description': bankName,
      },
    );
    final data = res.data;
    if (data is Map<String, dynamic>) {
      return Map<String, dynamic>.from(data);
    }
    return <String, dynamic>{'success': true};
  }
}