import '../../../utils/result.dart';
import '../../repositories/voucher_repository.dart';

class IncrementVoucherUsage {
  final VoucherRepository repository;

  IncrementVoucherUsage(this.repository);

  Future<Result<void>> call(int voucherId) {
    return repository.incrementUsage(voucherId);
  }
}
