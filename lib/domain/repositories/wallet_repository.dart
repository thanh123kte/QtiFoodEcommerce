import 'package:datn_foodecommerce_flutter_app/domain/entities/wallet_transaction.dart';

import '../../utils/result.dart';
import '../entities/wallet_topup_result.dart';
import '../entities/wallet_withdraw_request.dart';

abstract class WalletRepository {
  Future<Result<double>> getBalance(String userId);
  Future<Result<WalletTopUpResult>> topUp({
    required String userId,
    required double amount,
    required String currency,
    required String returnUrl,
  });
  Future<Result<List<WalletTransaction>>> getTransactions(String userId);
  Future<Result<bool>> withdraw(WalletWithdrawRequest request);
}
