import 'package:dio/dio.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../domain/entities/settings_entities.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_remote_datasource.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl({required SettingsRemoteDataSource remoteDataSource})
    : _remote = remoteDataSource;
  final SettingsRemoteDataSource _remote;

  Future<T> _request<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on DioException catch (error) {
      throw mapDioExceptionToFailure(error);
    }
  }

  @override
  Future<List<RoleDefinition>> getRoles() => _request(_remote.getRoles);
  @override
  Future<UserPage> getUsers(UserQuery query) =>
      _request(() => _remote.getUsers(query));
  @override
  Future<UserAccount> saveUser(UserChanges changes) =>
      _request(() => _remote.saveUser(changes));
}
