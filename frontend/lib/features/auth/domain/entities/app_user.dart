import 'package:equatable/equatable.dart';

class AppUser extends Equatable {
  const AppUser({
    required this.id,
    required this.nombre,
    required this.email,
    required this.rol,
  });

  final String id;
  final String nombre;
  final String email;
  final String rol;

  bool get isAdmin => rol == 'ADMIN';
  bool get isOperador => rol == 'OPERADOR';
  bool get isConductor => rol == 'CONDUCTOR';
  bool get isCliente => rol == 'CLIENTE';
  bool get isAuditor => rol == 'AUDITOR';

  bool hasAnyRole(List<String> roles) => roles.contains(rol);

  @override
  List<Object?> get props => [id, nombre, email, rol];
}
