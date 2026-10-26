import '../../../../core/constants/api_paths.dart';
import '../../../../core/network/api_client.dart';
import '../models/carbon_plan_model.dart';

abstract class CarbonRemoteDataSource {
  Future<CarbonPlanModel> getPlan();
}

class CarbonRemoteDataSourceImpl implements CarbonRemoteDataSource {
  CarbonRemoteDataSourceImpl(this._client);

  final ApiClient _client;

  @override
  Future<CarbonPlanModel> getPlan() async {
    final response = await _client.dio.get(ApiPaths.compensacionPlan);
    return CarbonPlanModel.fromJson(response.data as Map<String, dynamic>);
  }
}
