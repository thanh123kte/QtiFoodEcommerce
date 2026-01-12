import '../../../utils/result.dart';
import '../../entities/voucher.dart';
import '../../repositories/voucher_repository.dart';

class GetVoucher {
  final VoucherRepository repository;

  GetVoucher(this.repository);

  Future<Result<Voucher>> call(int voucherId) {
    return repository.getVoucher(voucherId);
  }
}
