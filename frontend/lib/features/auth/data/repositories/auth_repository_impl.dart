import 'dart:convert';

import 'package:pathseek/core/network/session_store.dart';
import 'package:pathseek/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:pathseek/features/auth/data/models/auth_response_model.dart';
import 'package:pathseek/features/auth/domain/entities/app_user.dart';
import 'package:pathseek/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required SessionStore sessionStore,
  })  : _remoteDataSource = remoteDataSource,
        _sessionStore = sessionStore;

  final AuthRemoteDataSource _remoteDataSource;
  final SessionStore _sessionStore;

  @override
  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    final AuthResponseModel response = await _remoteDataSource.login(
      email: email,
      password: password,
    );

    await _sessionStore.saveSession(
      accessToken: response.token,
      refreshToken: response.refreshToken,
      userJson: jsonEncode({
        'usuario_id': response.usuario.id,
        'nombre': response.usuario.nombre,
        'email': response.usuario.email,
        'rol': response.usuario.rol,
      }),
    );

    return response.usuario.toEntity();
  }

  @override
  Future<AppUser?> currentUser() async {
    final userJson = await _sessionStore.readUserJson();
    if (userJson == null) return null;

    final map = jsonDecode(userJson) as Map<String, dynamic>;
    return AuthUserModel.fromJson(map).toEntity();
  }

  @override
  Future<void> logout() async {
    final refreshToken = await _sessionStore.readRefreshToken();
    try {
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await _remoteDataSource.logout(refreshToken: refreshToken);
      }
    } catch (_) {
      // La sesión local se limpia igual: cerrar sesión no debe fallar
      // aunque el backend no responda.
    } finally {
      await _sessionStore.clear();
    }
  }
}

extension on AuthUserModel {
  AppUser toEntity() => AppUser(
        id: id,
        nombre: nombre,
        email: email,
        rol: rol,
      );
}
