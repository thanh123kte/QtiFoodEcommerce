import 'package:dio/dio.dart';

import '../../domain/entities/wallet_topup_result.dart';
import '../../domain/entities/wallet_transaction.dart';
import '../../domain/entities/wallet_withdraw_request.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../../utils/result.dart';
import '../datasources/remote/wallet_remote.dart';
import '../models/wallet_transaction_model.dart';

class WalletRepositoryImpl implements WalletRepository {
  final WalletRemote remote;

  WalletRepositoryImpl(this.remote);

  // TODO: Điền thông tin sepay của bạn ở đây
  static const String _sepayAccount = '0606914301919';
  static const String _sepayBank = 'MBBANK';

  @override
  Future<Result<double>> getBalance(String userId) async {
    try {
      final balance = await remote.getBalance(userId);
      return Ok(balance);
    } on DioException catch (e) {
      final errorMsg = _parseErrorMessage(e);
      return Err(errorMsg);
    } catch (e) {
      return Err(e.toString());
    }
  }

  @override
  Future<Result<WalletTopUpResult>> topUp({
    required String userId,
    required double amount,
    required String currency,
    required String returnUrl,
  }) async {
    try {
      final response = await remote.topUp(
        userId: userId,
        amount: amount,
        currency: currency,
        returnUrl: returnUrl,
      );
      final amountStr = amount.toStringAsFixed(0);
      final providerTx = response['providerTransactionId']?.toString() ?? '';
      final desc = Uri.encodeComponent('nap tien vao qtifood $providerTx');
      final sepayUrl =
          'https://qr.sepay.vn/img?acc=$_sepayAccount&bank=$_sepayBank&amount=$amountStr&des=$desc';
      final apiPaymentUrl = response['paymentUrl']?.toString();
      final paymentUrl = (apiPaymentUrl != null && apiPaymentUrl.startsWith('http'))
          ? apiPaymentUrl
          : sepayUrl;
      return Ok(WalletTopUpResult(paymentUrl: paymentUrl, providerTransactionId: providerTx));
    } on DioException catch (e) {
      final errorMsg = _parseErrorMessage(e);
      return Err(errorMsg);
    } catch (e) {
      return Err(e.toString());
    }
  }

  @override
  Future<Result<List<WalletTransaction>>> getTransactions(String userId) async {
    try {
      final json = await remote.getTransactions(userId);
      final models = json.map(WalletTransactionModel.fromJson).toList();
      return Ok(models.map((e) => e.toEntity()).toList());
    } on DioException catch (e) {
      final errorMsg = _parseErrorMessage(e);
      return Err(errorMsg);
    } catch (e) {
      return Err(e.toString());
    }
  }

  @override
  Future<Result<bool>> withdraw(WalletWithdrawRequest request) async {
    try {
      await remote.withdraw(
        userId: request.userId,
        amount: request.amount,
        bankAccount: request.bankAccount,
        bankName: request.bankName,
      );
      return Ok(true);
    } on DioException catch (e) {
      final errorMsg = _parseErrorMessage(e);
      return Err(errorMsg);
    } catch (e) {
      return Err(e.toString());
    }
  }

  String _parseErrorMessage(DioException e) {
    try {
      final data = e.response?.data;
      if (data is Map) {
        // Kiểm tra field "messages" (array)
        if (data['messages'] is List && (data['messages'] as List).isNotEmpty) {
          final messages = data['messages'] as List;
          return messages.join(', ');
        }
        // Kiểm tra field "message" (string)
        if (data['message'] != null && data['message'].toString().isNotEmpty) {
          return data['message'].toString();
        }
        // Kiểm tra field "error"
        if (data['error'] != null && data['error'].toString().isNotEmpty) {
          return data['error'].toString();
        }
      }
      // Fallback to status message
      if (e.response?.statusMessage != null) {
        return e.response!.statusMessage!;
      }
    } catch (_) {
      // Ignore parsing errors
    }
    return e.message ?? 'Có lỗi xảy ra';
  }
}
