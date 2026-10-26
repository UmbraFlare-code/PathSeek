import 'package:dio/dio.dart';
import 'package:pathseek/core/errors/error_mapper.dart';
import 'package:pathseek/features/carbon/data/datasources/carbon_remote_datasource.dart';
import 'package:pathseek/features/carbon/domain/entities/carbon_plan.dart';
import 'package:pathseek/features/carbon/domain/repositories/carbon_repository.dart';

class CarbonRepositoryImpl implements CarbonRepository {
  CarbonRepositoryImpl({required CarbonRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final CarbonRemoteDataSource _remoteDataSource;

  @override
  Future<CarbonPlan> getPlan() async {
    try {
      final model = await _remoteDataSource.getPlan();
      return model.toEntity();
    } on DioException catch (e) {
      throw mapDioExceptionToFailure(e);
    }
  }
}
