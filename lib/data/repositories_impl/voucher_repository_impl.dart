import 'package:dio/dio.dart';

import '../../domain/entities/create_voucher_input.dart';
import '../../domain/entities/voucher.dart';
import '../../domain/repositories/voucher_repository.dart';
import '../../utils/result.dart';
import '../datasources/local/voucher_local.dart';
import '../datasources/remote/voucher_remote.dart';
import '../models/voucher_model.dart';

class VoucherRepositoryImpl implements VoucherRepository {
  final VoucherRemote remote;
  final VoucherLocal local;

  VoucherRepositoryImpl(this.remote, this.local);

  @override
  Future<Result<List<Voucher>>> getStoreVouchers(int storeId) async {
    final cached = await local.getVouchers(storeId);
    
    try {
      final jsonList = await remote.getByStore(storeId);
      final models = jsonList.map(VoucherModel.fromJson).toList();
      await local.saveVouchers(storeId, models);
      return Ok(models.map((e) => e.toEntity()).toList());
    } on DioException catch (e) {
      if (cached.isNotEmpty) {
        return Ok(cached.map((e) => e.toEntity()).toList());
      }
      return Err(_readMessage(e));
    } catch (e) {
      if (cached.isNotEmpty) {
        return Ok(cached.map((e) => e.toEntity()).toList());
      }
      return Err(e.toString());
    }
  }

  @override
  Future<Result<List<Voucher>>> getAdminVouchers() async {
    const cacheKey = 'admin';
    final cached = await local.getVouchers(cacheKey);
    try {
      final jsonList = await remote.getAdminVouchers();
      final models = jsonList.map(VoucherModel.fromJson).toList();
      await local.saveVouchers(cacheKey, models);
      return Ok(models.map((e) => e.toEntity()).toList());
    } on DioException catch (e) {
      if (cached.isNotEmpty) {
        return Ok(cached.map((e) => e.toEntity()).toList());
      }
      return Err(_readMessage(e));
    } catch (e) {
      if (cached.isNotEmpty) {
        return Ok(cached.map((e) => e.toEntity()).toList());
      }
      return Err(e.toString());
    }
  }

  @override
  Future<Result<Voucher>> createVoucher(CreateVoucherInput input) async {
    try {
      final json = await remote.create(input.toJson());
      final model = VoucherModel.fromJson(json);
      await local.upsertVoucher(model.storeId, model);
      return Ok(model.toEntity());
    } on DioException catch (e) {
      return Err(_readMessage(e));
    } catch (e) {
      return Err(e.toString());
    }
  }

  @override
  Future<Result<Voucher>> updateVoucher(int id, UpdateVoucherInput input) async {
    try {
      final json = await remote.update(id, input.toJson());
      final model = VoucherModel.fromJson(json);
      await local.upsertVoucher(model.storeId, model);
      return Ok(model.toEntity());
    } on DioException catch (e) {
      return Err(_readMessage(e));
    } catch (e) {
      return Err(e.toString());
    }
  }

  @override
  Future<Result<void>> deleteVoucher(int id) async {
    try {
      await remote.delete(id);
      await local.removeVoucher(id);
      return const Ok(null);
    } on DioException catch (e) {
      return Err(_readMessage(e));
    } catch (e) {
      return Err(e.toString());
    }
  }

  @override
  Future<Result<Voucher>> getVoucher(int id) async {
    try {
      final json = await remote.getVoucher(id);
      final model = VoucherModel.fromJson(json);
      return Ok(model.toEntity());
    } on DioException catch (e) {
      return Err(_readMessage(e));
    } catch (e) {
      return Err(e.toString());
    }
  }

  @override
  Future<Result<void>> incrementUsage(int voucherId) async {
    try {
      await remote.updateUsage(voucherId);
      return const Ok(null);
    } on DioException catch (e) {
      return Err(_readMessage(e));
    } catch (e) {
      return Err(e.toString());
    }
  }

  String _readMessage(DioException exception) {
    return exception.response?.data?.toString() ?? exception.message ?? 'API error';
  }
}
