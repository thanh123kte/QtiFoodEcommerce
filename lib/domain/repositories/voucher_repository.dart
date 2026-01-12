import '../../utils/result.dart';
import '../entities/create_voucher_input.dart';
import '../entities/voucher.dart';

abstract class VoucherRepository {
  Future<Result<List<Voucher>>> getStoreVouchers(int storeId);
  Future<Result<List<Voucher>>> getAdminVouchers();
  Future<Result<Voucher>> getVoucher(int id);
  Future<Result<Voucher>> createVoucher(CreateVoucherInput input);
  Future<Result<Voucher>> updateVoucher(int id, UpdateVoucherInput input);
  Future<Result<void>> deleteVoucher(int id);
  Future<Result<void>> incrementUsage(int voucherId);

}
