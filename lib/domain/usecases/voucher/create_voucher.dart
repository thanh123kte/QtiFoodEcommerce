import '../../../utils/result.dart';
import '../../entities/create_voucher_input.dart';
import '../../entities/voucher.dart';
import '../../repositories/voucher_repository.dart';

class CreateVoucher {
  final VoucherRepository repository;

  CreateVoucher(this.repository);

  Future<Result<Voucher>> call(CreateVoucherInput input) {
    return repository.createVoucher(input);
  }
}
