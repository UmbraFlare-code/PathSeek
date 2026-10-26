import 'package:pathseek/features/reports/domain/entities/saved_report.dart';

abstract class ReportsRepository {
  Future<SavedReport> downloadSustainabilityReport({
    String? desde,
    String? hasta,
  });
}
