import 'package:equatable/equatable.dart';

class RoleDefinition extends Equatable {
  const RoleDefinition({
    required this.code,
    required this.name,
    required this.description,
    required this.permissions,
  });
  final String code, name, description;
  final List<String> permissions;
  @override
  List<Object?> get props => [code, name, description, permissions];
}

class UserAccount extends Equatable {
  const UserAccount({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.active,
    this.blockedUntil,
    this.dni,
    this.lastLogin,
  });
  final String id, name, email, role;
  final String? dni;
  final bool active;
  final DateTime? blockedUntil, lastLogin;
  bool get isBlocked => blockedUntil?.isAfter(DateTime.now()) ?? false;
  @override
  List<Object?> get props => [
    id,
    name,
    email,
    role,
    active,
    dni,
    blockedUntil,
    lastLogin,
  ];
}

class UserPage extends Equatable {
  const UserPage({
    required this.users,
    required this.page,
    required this.totalPages,
    required this.totalElements,
  });
  final List<UserAccount> users;
  final int page, totalPages, totalElements;
  @override
  List<Object?> get props => [users, page, totalPages, totalElements];
}

class UserQuery extends Equatable {
  const UserQuery({this.page = 0, this.search = '', this.role, this.active});
  final int page;
  final String search;
  final String? role;
  final bool? active;
  UserQuery atPage(int page) =>
      UserQuery(page: page, search: search, role: role, active: active);
  @override
  List<Object?> get props => [page, search, role, active];
}

/// Password exists only in the create command; it is never part of account data.
class UserChanges {
  const UserChanges({
    required this.name,
    required this.email,
    required this.role,
    this.active = true,
    this.password,
    this.dni,
    this.id,
  });
  final String? id, password, dni;
  final String name, email, role;
  final bool active;
}
