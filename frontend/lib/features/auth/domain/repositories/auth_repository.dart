import 'package:pathseek/features/auth/domain/entities/app_user.dart';

abstract class AuthRepository {
  Future<AppUser> login({required String email, required String password});

  Future<AppUser?> currentUser();

  Future<void> logout();
}
