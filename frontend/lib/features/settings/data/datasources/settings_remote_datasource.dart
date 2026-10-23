import '../../../../core/constants/api_paths.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/settings_entities.dart';
import '../models/settings_models.dart';

abstract class SettingsRemoteDataSource {
  Future<List<RoleDefinition>> getRoles();
  Future<UserPage> getUsers(UserQuery query);
  Future<UserAccount> saveUser(UserChanges changes);
}

class SettingsRemoteDataSourceImpl implements SettingsRemoteDataSource {
  SettingsRemoteDataSourceImpl(this._client);
  final ApiClient _client;
  static const _users = '${ApiPaths.base}/usuarios';
  static const _roles = '${ApiPaths.base}/configuracion/roles';

  @override
  Future<List<RoleDefinition>> getRoles() async {
    final response = await _client.dio.get(_roles);
    return (response.data as List)
        .map((item) => SettingsModels.role(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<UserPage> getUsers(UserQuery query) async {
    final response = await _client.dio.get(
      _users,
      queryParameters: {
        'pagina': query.page,
        'tamano': 20,
        if (query.search.trim().isNotEmpty) 'buscar': query.search.trim(),
        if (query.role != null) 'rol': query.role,
        if (query.active != null) 'activo': query.active,
      },
    );
    return SettingsModels.page(response.data as Map<String, dynamic>);
  }

  @override
  Future<UserAccount> saveUser(UserChanges changes) async {
    final response = changes.id == null
        ? await _client.dio.post(_users, data: SettingsModels.payload(changes))
        : await _client.dio.put(
            '$_users/${Uri.encodeComponent(changes.id!)}',
            data: SettingsModels.payload(changes),
          );
    return SettingsModels.user(response.data as Map<String, dynamic>);
  }
}
