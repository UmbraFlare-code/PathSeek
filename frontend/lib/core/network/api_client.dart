import 'package:dio/dio.dart';

import '../config/environment.dart';
import '../constants/api_paths.dart';
import '../errors/exceptions.dart';
import '../errors/failures.dart';
import 'token_storage.dart';

class ApiClient {
  ApiClient({required TokenStorage tokenStorage, Dio? dio})
      : _tokenStorage = tokenStorage,
        _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: Environment.current.apiBaseUrl,
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 30),
                contentType: Headers.jsonContentType,
              ),
            ) {
    _dio.interceptors.addAll([
      _AuthInterceptor(_tokenStorage),
      _RefreshInterceptor(_tokenStorage, _dio),
      _ErrorInterceptor(),
    ]);
  }

  final TokenStorage _tokenStorage;
  final Dio _dio;

  Dio get dio => _dio;
}

class _AuthInterceptor extends Interceptor {
  _AuthInterceptor(this._tokenStorage);

  final TokenStorage _tokenStorage;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokenStorage.readAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}

class _RefreshInterceptor extends Interceptor {
  _RefreshInterceptor(this._tokenStorage, this._dio);

  final TokenStorage _tokenStorage;
  final Dio _dio;

  Future<void>? _refreshInProgress;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final statusCode = err.response?.statusCode;
    final isAuthEndpoint =
        err.requestOptions.path.contains(ApiPaths.authLogin) ||
            err.requestOptions.path.contains(ApiPaths.authRefresh) ||
            err.requestOptions.path.contains(ApiPaths.authLogout);

    if (statusCode != 401 || isAuthEndpoint || _isRetry(err)) {
      handler.next(err);
      return;
    }

    _refreshInProgress ??= _performRefresh();
    try {
      await _refreshInProgress;
      final retryResponse = await _retry(err.requestOptions);
      handler.resolve(retryResponse);
    } on DioException catch (refreshError) {
      handler.next(refreshError);
    } catch (_) {
      handler.next(err);
    } finally {
      _refreshInProgress = null;
    }
  }

  bool _isRetry(DioException err) =>
      err.requestOptions.extra['__retry__'] == true;

  Future<void> _performRefresh() async {
    final refreshToken = await _tokenStorage.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      throw const UnauthorizedFailure();
    }

    final response = await _dio.post(
      ApiPaths.authRefresh,
      data: {'refreshToken': refreshToken},
    );

    final data = response.data as Map<String, dynamic>;
    final accessToken = data['token'] as String?;
    final newRefreshToken = data['refreshToken'] as String?;

    if (accessToken == null) {
      throw const UnauthorizedFailure();
    }

    await _tokenStorage.saveTokens(
      accessToken: accessToken,
      refreshToken: newRefreshToken ?? refreshToken,
    );
  }

  Future<Response<dynamic>> _retry(RequestOptions options) async {
    final token = await _tokenStorage.readAccessToken();
    final requestOptions = Options(
      method: options.method,
      headers: {
        ...options.headers,
        'Authorization': 'Bearer $token',
      },
      extra: {...options.extra, '__retry__': true},
    );

    return _dio.request<dynamic>(
      options.path,
      data: options.data,
      queryParameters: options.queryParameters,
      options: requestOptions,
    );
  }
}

class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        handler.next(
          DioException(
            requestOptions: err.requestOptions,
            response: err.response,
            error: const NoConnectionException(),
          ),
        );
      default:
        handler.next(err);
    }
  }
}
