import '../../domain/entities/settings_entities.dart';

class SettingsModels {
  SettingsModels._();

  static RoleDefinition role(Map<String, dynamic> json) => RoleDefinition(
    code: json['rol'] as String,
    name: json['nombre'] as String,
    description: json['descripcion'] as String,
    permissions: (json['permisos'] as List).cast<String>(),
  );

  static UserAccount user(Map<String, dynamic> json) => UserAccount(
    id: json['usuario_id'] as String,
    dni: json['dni'] as String?,
    name: json['nombre'] as String,
    email: json['email'] as String,
    role: json['rol'] as String,
    active: json['activo'] as bool,
    blockedUntil: _date(json['bloqueado_hasta']),
    lastLogin: _date(json['ultimo_login']),
  );

  static DateTime? _date(dynamic value) =>
      value == null ? null : DateTime.parse(value as String);

  static UserPage page(Map<String, dynamic> json) => UserPage(
    users: (json['contenido'] as List)
        .map((item) => user(item as Map<String, dynamic>))
        .toList(),
    page: (json['pagina'] as num).toInt(),
    totalPages: (json['total_paginas'] as num).toInt(),
    totalElements: (json['total_elementos'] as num).toInt(),
  );

  static Map<String, dynamic> payload(UserChanges changes) => {
    'nombre': changes.name,
    if (changes.dni != null) 'dni': changes.dni,
    'email': changes.email,
    'rol': changes.role,
    if (changes.id == null) 'password': changes.password,
    if (changes.id != null) 'activo': changes.active,
  };
}
