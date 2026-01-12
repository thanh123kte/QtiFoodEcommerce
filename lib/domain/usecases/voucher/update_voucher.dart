import '../../../utils/result.dart';
import '../../entities/create_voucher_input.dart';
import '../../entities/voucher.dart';
import '../../repositories/voucher_repository.dart';

class UpdateVoucher {
  final VoucherRepository repository;

  UpdateVoucher(this.repository);

  Future<Result<Voucher>> call(int id, UpdateVoucherInput input) {
    return repository.updateVoucher(id, input);
  }
}
