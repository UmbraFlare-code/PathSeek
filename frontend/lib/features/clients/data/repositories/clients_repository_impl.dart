import 'package:dio/dio.dart';
import 'package:pathseek/core/errors/error_mapper.dart';
import 'package:pathseek/features/clients/data/datasources/clients_remote_datasource.dart';
import 'package:pathseek/features/clients/domain/entities/client_profile.dart';
import 'package:pathseek/features/clients/domain/repositories/clients_repository.dart';

class ClientsRepositoryImpl implements ClientsRepository {
  ClientsRepositoryImpl({required ClientsRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final ClientsRemoteDataSource _remoteDataSource;

  @override
  Future<List<ClientProfile>> getClients() async {
    try {
      final models = await _remoteDataSource.getClients();
      return models.map((model) => model.toEntity()).toList();
    } on DioException catch (e) {
      throw mapDioExceptionToFailure(e);
    }
  }

  @override
  Future<ClientProfile> getClient(String id) async {
    try {
      final model = await _remoteDataSource.getClient(id);
      return model.toEntity();
    } on DioException catch (e) {
      throw mapDioExceptionToFailure(e);
    }
  }

  @override
  Future<ClientProfile> createClient(Map<String, dynamic> payload) async {
    try {
      final model = await _remoteDataSource.createClient(payload);
      return model.toEntity();
    } on DioException catch (e) {
      throw mapDioExceptionToFailure(e);
    }
  }

  @override
  Future<ClientProfile> updateClient(
    String id,
    Map<String, dynamic> payload,
  ) async {
    try {
      final model = await _remoteDataSource.updateClient(id, payload);
      return model.toEntity();
    } on DioException catch (e) {
      throw mapDioExceptionToFailure(e);
    }
  }

  @override
  Future<void> deleteClient(String id) async {
    try {
      await _remoteDataSource.deleteClient(id);
    } on DioException catch (e) {
      throw mapDioExceptionToFailure(e);
    }
  }
}
