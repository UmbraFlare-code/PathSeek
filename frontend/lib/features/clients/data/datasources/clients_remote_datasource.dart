import '../../../../core/constants/api_paths.dart';
import '../../../../core/network/api_client.dart';
import '../models/client_profile_model.dart';

abstract class ClientsRemoteDataSource {
  Future<List<ClientProfileModel>> getClients();

  Future<ClientProfileModel> getClient(String id);

  Future<ClientProfileModel> createClient(Map<String, dynamic> payload);

  Future<ClientProfileModel> updateClient(
    String id,
    Map<String, dynamic> payload,
  );

  Future<void> deleteClient(String id);
}

class ClientsRemoteDataSourceImpl implements ClientsRemoteDataSource {
  ClientsRemoteDataSourceImpl(this._client);

  final ApiClient _client;

  @override
  Future<List<ClientProfileModel>> getClients() async {
    final response = await _client.dio.get(ApiPaths.clientes);
    final data = response.data;
    final list = data is List ? data : (data['data'] as List? ?? []);
    return list
        .map((item) => ClientProfileModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<ClientProfileModel> getClient(String id) async {
    final response = await _client.dio.get('${ApiPaths.clientes}/$id');
    return ClientProfileModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<ClientProfileModel> createClient(Map<String, dynamic> payload) async {
    final response = await _client.dio.post(ApiPaths.clientes, data: payload);
    return ClientProfileModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<ClientProfileModel> updateClient(
    String id,
    Map<String, dynamic> payload,
  ) async {
    final response = await _client.dio.put(
      '${ApiPaths.clientes}/$id',
      data: payload,
    );
    return ClientProfileModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> deleteClient(String id) async {
    await _client.dio.delete('${ApiPaths.clientes}/$id');
  }
}
