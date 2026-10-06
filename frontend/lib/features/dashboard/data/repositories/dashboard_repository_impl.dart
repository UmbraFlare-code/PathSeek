import 'package:dio/dio.dart';
import 'package:pathseek/core/errors/error_mapper.dart';
import 'package:pathseek/features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'package:pathseek/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:pathseek/features/dashboard/domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  DashboardRepositoryImpl({required DashboardRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final DashboardRemoteDataSource _remoteDataSource;

  @override
  Future<DashboardSummary> getSummary() async {
    try {
      final model = await _remoteDataSource.getSummary();
      return model.toEntity();
    } on DioException catch (e) {
      throw mapDioExceptionToFailure(e);
    }
  }
}
