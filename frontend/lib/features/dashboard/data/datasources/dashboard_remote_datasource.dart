import '../../../../core/constants/api_paths.dart';
import '../../../../core/network/api_client.dart';
import '../models/dashboard_summary_model.dart';

abstract class DashboardRemoteDataSource {
  Future<DashboardSummaryModel> getSummary();
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  DashboardRemoteDataSourceImpl(this._client);

  final ApiClient _client;

  @override
  Future<DashboardSummaryModel> getSummary() async {
    final response = await _client.dio.get(ApiPaths.dashboardResumen);
    return DashboardSummaryModel.fromJson(
      _unwrap(response.data),
    );
  }

  Map<String, dynamic> _unwrap(dynamic data) {
    if (data is Map<String, dynamic> && data.containsKey('data')) {
      return data['data'] as Map<String, dynamic>;
    }
    return data as Map<String, dynamic>;
  }
}
