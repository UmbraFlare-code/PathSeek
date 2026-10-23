import '../entities/settings_entities.dart';

abstract class SettingsRepository {
  Future<List<RoleDefinition>> getRoles();
  Future<UserPage> getUsers(UserQuery query);
  Future<UserAccount> saveUser(UserChanges changes);
}
