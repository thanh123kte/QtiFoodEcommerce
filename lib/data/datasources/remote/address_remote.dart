import 'package:dio/dio.dart';

class AddressRemote {
  final Dio dio;

  AddressRemote(this.dio);

  Future<List<Map<String, dynamic>>> getAddressesByUser(String userId) async {
    final response = await dio.get('/api/addresses/user/$userId/isnot_deleted');
    final data = response.data;
    if (data is List) {
      return data
          .whereType<Map>()
          .map((map) => Map<String, dynamic>.from(map))
          .toList();
    }
    return const [];
  }

  Future<Map<String, dynamic>> createAddress(
    Map<String, dynamic> payload,
  ) async {
    final response = await dio.post('/api/addresses', data: payload);
    return _parseAddressResponse(response);
  }

  Future<Map<String, dynamic>> getAddressById(String addressId) async {
    final response = await dio.get('/api/addresses/$addressId');
    return _parseAddressResponse(response);
  }

  Future<Map<String, dynamic>> updateAddress(
    String addressId,
    Map<String, dynamic> payload,
  ) async {
    final response = await dio.put('/api/addresses/$addressId', data: payload);
    return _parseAddressResponse(response);
  }

  Future<void> deleteAddress(String addressId) async {
    await dio.put('/api/addresses/$addressId/soft-delete');
  }

  Map<String, dynamic> _parseAddressResponse(Response<dynamic> response) {
    final data = response.data;
    if (data is Map<String, dynamic>) {
      if (data.containsKey('data') && data['data'] is Map<String, dynamic>) {
        return Map<String, dynamic>.from(data['data'] as Map<String, dynamic>);
      }
      return Map<String, dynamic>.from(data);
    }
    throw DioException(
      requestOptions: response.requestOptions,
      message: 'Invalid address response format',
    );
  }
}
