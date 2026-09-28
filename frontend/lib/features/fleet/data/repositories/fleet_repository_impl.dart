import 'package:dio/dio.dart';
import 'package:pathseek/core/errors/error_mapper.dart';
import 'package:pathseek/features/fleet/data/datasources/fleet_remote_datasource.dart';
import 'package:pathseek/features/fleet/data/models/vehicle_model.dart';
import 'package:pathseek/features/fleet/domain/entities/vehicle.dart';
import 'package:pathseek/features/fleet/domain/repositories/fleet_repository.dart';

class FleetRepositoryImpl implements FleetRepository {
  FleetRepositoryImpl({required FleetRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final FleetRemoteDataSource _remoteDataSource;

  @override
  Future<List<Vehicle>> getVehicles() async {
    try {
      final models = await _remoteDataSource.getVehicles();
      return models.map((model) => model.toEntity()).toList();
    } on DioException catch (e) {
      throw mapDioExceptionToFailure(e);
    }
  }

  @override
  Future<Vehicle> getVehicleById(String id) async {
    try {
      final model = await _remoteDataSource.getVehicleById(id);
      return model.toEntity();
    } on DioException catch (e) {
      throw mapDioExceptionToFailure(e);
    }
  }

  @override
  Future<Vehicle> createVehicle(Vehicle vehicle) async {
    try {
      final model = await _remoteDataSource.createVehicle(
        VehicleModel.fromEntity(vehicle),
      );
      return model.toEntity();
    } on DioException catch (e) {
      throw mapDioExceptionToFailure(e);
    }
  }

  @override
  Future<Vehicle> updateVehicle(Vehicle vehicle) async {
    try {
      final model = await _remoteDataSource.updateVehicle(
        VehicleModel.fromEntity(vehicle),
      );
      return model.toEntity();
    } on DioException catch (e) {
      throw mapDioExceptionToFailure(e);
    }
  }

  @override
  Future<void> deleteVehicle(String id) async {
    try {
      await _remoteDataSource.deleteVehicle(id);
    } on DioException catch (e) {
      throw mapDioExceptionToFailure(e);
    }
  }
}
