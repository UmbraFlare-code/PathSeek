import 'package:dio/dio.dart';
import 'package:pathseek/core/errors/error_mapper.dart';
import 'package:pathseek/core/services/pdf_saver.dart';
import 'package:pathseek/features/reports/data/datasources/reports_remote_datasource.dart';
import 'package:pathseek/features/reports/domain/entities/saved_report.dart';
import 'package:pathseek/features/reports/domain/repositories/reports_repository.dart';

class ReportsRepositoryImpl implements ReportsRepository {
  ReportsRepositoryImpl({required ReportsRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final ReportsRemoteDataSource _remoteDataSource;

  @override
  Future<SavedReport> downloadSustainabilityReport({
    String? desde,
    String? hasta,
  }) async {
    try {
      final bytes = await _remoteDataSource.downloadSustainabilityReport(
        desde: desde,
        hasta: hasta,
      );
      final fileName = 'reporte_sostenibilidad.pdf';
      final location = await savePdfFile(fileName, bytes);
      return SavedReport(fileName: fileName, location: location);
    } on DioException catch (e) {
      throw mapDioExceptionToFailure(e);
    }
  }
}
