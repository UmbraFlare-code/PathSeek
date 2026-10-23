import 'package:pathseek/features/settings/domain/entities/settings_entities.dart';
import 'package:pathseek/features/settings/domain/repositories/settings_repository.dart';

const testRoles = [
  RoleDefinition(
    code: 'ADMIN',
    name: 'Administrador',
    description: 'Administración del sistema.',
    permissions: [
      'Gestionar usuarios y asignar roles',
      'Consultar configuración',
    ],
  ),
  RoleDefinition(
    code: 'OPERADOR',
    name: 'Operador logístico',
    description: 'Gestión de la operación.',
    permissions: ['Consultar configuración', 'Gestionar pedidos y rutas'],
  ),
  RoleDefinition(
    code: 'AUDITOR',
    name: 'Auditor',
    description: 'Consulta de información.',
    permissions: ['Consultar configuración'],
  ),
  RoleDefinition(
    code: 'CONDUCTOR',
    name: 'Conductor',
    description: 'Entregas asignadas.',
    permissions: ['Consultar rutas propias'],
  ),
  RoleDefinition(
    code: 'CLIENTE',
    name: 'Cliente',
    description: 'Pedidos propios.',
    permissions: ['Crear pedidos propios'],
  ),
];
const ownAccount = UserAccount(
  id: 'self',
  name: 'Administradora de pruebas',
  email: 'admin@example.test',
  role: 'ADMIN',
  active: true,
);
const otherAccount = UserAccount(
  id: 'other',
  name: 'Operador de pruebas',
  email: 'operador@example.test',
  role: 'OPERADOR',
  active: true,
);

class FakeSettingsRepository implements SettingsRepository {
  int userRequests = 0;
  final queries = <UserQuery>[];
  final changes = <UserChanges>[];
  List<UserAccount> users = [ownAccount, otherAccount];
  Object? saveFailure;
  Object? usersFailure;
  Future<UserPage> Function(UserQuery)? loadUsers;
  @override
  Future<List<RoleDefinition>> getRoles() async => testRoles;
  @override
  Future<UserPage> getUsers(UserQuery query) async {
    userRequests++;
    queries.add(query);
    if (usersFailure != null) throw usersFailure!;
    return loadUsers == null
        ? UserPage(
            users: users,
            page: query.page,
            totalPages: 2,
            totalElements: 21,
          )
        : loadUsers!(query);
  }

  @override
  Future<UserAccount> saveUser(UserChanges change) async {
    changes.add(change);
    if (saveFailure != null) throw saveFailure!;
    return UserAccount(
      id: change.id ?? 'new',
      name: change.name,
      email: change.email,
      role: change.role,
      active: change.active,
    );
  }
}
