import 'package:equatable/equatable.dart';

class AuthResponseModel extends Equatable {
  const AuthResponseModel({
    required this.token,
    required this.refreshToken,
    required this.usuario,
  });

  final String token;
  final String refreshToken;
  final AuthUserModel usuario;

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      token: json['token'] as String,
      refreshToken: json['refreshToken'] as String,
      usuario: AuthUserModel.fromJson(
        json['usuario'] as Map<String, dynamic>,
      ),
    );
  }

  @override
  List<Object?> get props => [token, refreshToken, usuario];
}

class AuthUserModel extends Equatable {
  const AuthUserModel({
    required this.id,
    required this.nombre,
    required this.email,
    required this.rol,
  });

  final String id;
  final String nombre;
  final String email;
  final String rol;

  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    return AuthUserModel(
      id: (json['usuario_id'] ?? json['id']).toString(),
      nombre: (json['nombre'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      rol: (json['rol'] ?? 'OPERADOR').toString(),
    );
  }

  @override
  List<Object?> get props => [id, nombre, email, rol];
}
