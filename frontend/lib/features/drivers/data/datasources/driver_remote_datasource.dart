import '../../../../core/constants/api_paths.dart';
import '../../../../core/network/api_client.dart';
import '../models/driver_model.dart';

abstract class DriverRemoteDataSource {
  Future<List<DriverModel>> getDrivers();

  Future<DriverModel> createDriver(DriverModel driver);

  Future<DriverModel> updateDriver(DriverModel driver);

  Future<void> deleteDriver(String id);
}

class DriverRemoteDataSourceImpl implements DriverRemoteDataSource {
  DriverRemoteDataSourceImpl(this._client);

  final ApiClient _client;

  @override
  Future<List<DriverModel>> getDrivers() async {
    final response = await _client.dio.get(ApiPaths.conductores);
    final data = response.data;
    final list = data is List ? data : (data['data'] as List? ?? []);
    return list
        .map((item) => DriverModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<DriverModel> createDriver(DriverModel driver) async {
    final response =
        await _client.dio.post(ApiPaths.conductores, data: driver.toJson());
    return DriverModel.fromJson(_unwrap(response.data));
  }

  @override
  Future<DriverModel> updateDriver(DriverModel driver) async {
    final response = await _client.dio.put(
      '${ApiPaths.conductores}/${driver.id}',
      data: driver.toJson(),
    );
    return DriverModel.fromJson(_unwrap(response.data));
  }

  @override
  Future<void> deleteDriver(String id) async {
    await _client.dio.delete('${ApiPaths.conductores}/$id');
  }

  Map<String, dynamic> _unwrap(dynamic data) {
    if (data is Map<String, dynamic> && data.containsKey('data')) {
      return data['data'] as Map<String, dynamic>;
    }
    return data as Map<String, dynamic>;
  }
}
