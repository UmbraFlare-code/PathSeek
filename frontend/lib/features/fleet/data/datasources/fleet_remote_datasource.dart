import '../../../../core/constants/api_paths.dart';
import '../../../../core/network/api_client.dart';
import '../models/vehicle_model.dart';

abstract class FleetRemoteDataSource {
  Future<List<VehicleModel>> getVehicles();

  Future<VehicleModel> createVehicle(VehicleModel vehicle);

  Future<VehicleModel> updateVehicle(VehicleModel vehicle);

  Future<void> deleteVehicle(String id);
}

class FleetRemoteDataSourceImpl implements FleetRemoteDataSource {
  FleetRemoteDataSourceImpl(this._client);

  final ApiClient _client;

  @override
  Future<List<VehicleModel>> getVehicles() async {
    final response = await _client.dio.get(ApiPaths.vehiculos);
    final data = response.data;
    final list = data is List ? data : (data['data'] as List? ?? []);
    return list
        .map((item) => VehicleModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<VehicleModel> createVehicle(VehicleModel vehicle) async {
    final response =
        await _client.dio.post(ApiPaths.vehiculos, data: vehicle.toJson());
    return VehicleModel.fromJson(_unwrap(response.data));
  }

  @override
  Future<VehicleModel> updateVehicle(VehicleModel vehicle) async {
    final response = await _client.dio.put(
      '${ApiPaths.vehiculos}/${vehicle.id}',
      data: vehicle.toJson(),
    );
    return VehicleModel.fromJson(_unwrap(response.data));
  }

  @override
  Future<void> deleteVehicle(String id) async {
    await _client.dio.delete('${ApiPaths.vehiculos}/$id');
  }

  Map<String, dynamic> _unwrap(dynamic data) {
    if (data is Map<String, dynamic> && data.containsKey('data')) {
      return data['data'] as Map<String, dynamic>;
    }
    return data as Map<String, dynamic>;
  }
}
