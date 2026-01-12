import '../../../utils/result.dart';
import '../../entities/voucher.dart';
import '../../repositories/voucher_repository.dart';

class GetAdminVouchers {
  final VoucherRepository repository;

  GetAdminVouchers(this.repository);

  Future<Result<List<Voucher>>> call() {
    return repository.getAdminVouchers();
  }
}
