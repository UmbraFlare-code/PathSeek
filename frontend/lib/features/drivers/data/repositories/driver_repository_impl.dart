import 'package:dio/dio.dart';
import 'package:pathseek/core/errors/error_mapper.dart';
import 'package:pathseek/features/drivers/data/datasources/driver_remote_datasource.dart';
import 'package:pathseek/features/drivers/data/models/driver_model.dart';
import 'package:pathseek/features/drivers/domain/entities/driver.dart';
import 'package:pathseek/features/drivers/domain/repositories/driver_repository.dart';

class DriverRepositoryImpl implements DriverRepository {
  DriverRepositoryImpl({required DriverRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final DriverRemoteDataSource _remoteDataSource;

  @override
  Future<List<Driver>> getDrivers() async {
    try {
      final models = await _remoteDataSource.getDrivers();
      return models.map((model) => model.toEntity()).toList();
    } on DioException catch (e) {
      throw mapDioExceptionToFailure(e);
    }
  }

  @override
  Future<Driver> createDriver(Driver driver) async {
    try {
      final model = await _remoteDataSource.createDriver(
        DriverModel.fromEntity(driver),
      );
      return model.toEntity();
    } on DioException catch (e) {
      throw mapDioExceptionToFailure(e);
    }
  }

  @override
  Future<Driver> updateDriver(Driver driver) async {
    try {
      final model = await _remoteDataSource.updateDriver(
        DriverModel.fromEntity(driver),
      );
      return model.toEntity();
    } on DioException catch (e) {
      throw mapDioExceptionToFailure(e);
    }
  }

  @override
  Future<void> deleteDriver(String id) async {
    try {
      await _remoteDataSource.deleteDriver(id);
    } on DioException catch (e) {
      throw mapDioExceptionToFailure(e);
    }
  }
}
