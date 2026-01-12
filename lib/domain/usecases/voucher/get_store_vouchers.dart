import '../../../utils/result.dart';
import '../../entities/voucher.dart';
import '../../repositories/voucher_repository.dart';

class GetStoreVouchers {
  final VoucherRepository repository;

  GetStoreVouchers(this.repository);

  Future<Result<List<Voucher>>> call(int storeId) {
    return repository.getStoreVouchers(storeId);
  }
}


