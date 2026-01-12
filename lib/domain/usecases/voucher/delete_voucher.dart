import '../../../utils/result.dart';
import '../../repositories/voucher_repository.dart';

class DeleteVoucher {
  final VoucherRepository repository;

  DeleteVoucher(this.repository);

  Future<Result<void>> call(int id) {
    return repository.deleteVoucher(id);
  }
}
