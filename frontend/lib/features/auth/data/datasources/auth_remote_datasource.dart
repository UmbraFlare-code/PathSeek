import '../../../../core/constants/api_paths.dart';
import '../../../../core/network/api_client.dart';
import '../models/auth_response_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  });

  Future<void> logout({required String refreshToken});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._client);

  final ApiClient _client;

  @override
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.dio.post(
      ApiPaths.authLogin,
      data: {'email': email, 'password': password},
    );
    return AuthResponseModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<void> logout({required String refreshToken}) async {
    await _client.dio.post(
      ApiPaths.authLogout,
      data: {'refreshToken': refreshToken},
    );
  }
}
