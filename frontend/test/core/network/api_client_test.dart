import 'dart:typed_data';
import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pathseek/core/errors/exceptions.dart';
import 'package:pathseek/core/network/api_client.dart';
import 'package:pathseek/core/network/token_storage.dart';

class MockTokenStorage extends Mock implements TokenStorage {}

class _StubAdapter implements HttpClientAdapter {
  _StubAdapter(this.handler);

  final Future<ResponseBody> Function(RequestOptions options) handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) => handler(options);

  @override
  void close({bool force = false}) {}
}

ResponseBody _json(String body, int statusCode) => ResponseBody.fromString(
  body,
  statusCode,
  headers: {
    Headers.contentTypeHeader: [Headers.jsonContentType],
  },
);

void main() {
  late MockTokenStorage tokenStorage;

  setUp(() {
    tokenStorage = MockTokenStorage();
    when(() => tokenStorage.readAccessToken()).thenAnswer((_) async => null);
    when(() => tokenStorage.readRefreshToken()).thenAnswer((_) async => null);
    when(
      () => tokenStorage.saveTokens(
        accessToken: any(named: 'accessToken'),
        refreshToken: any(named: 'refreshToken'),
      ),
    ).thenAnswer((_) async {});
    when(() => tokenStorage.clear()).thenAnswer((_) async {});
  });

  group('ApiClient auth interceptor', () {
    test('attaches Bearer token when present', () async {
      when(
        () => tokenStorage.readAccessToken(),
      ).thenAnswer((_) async => 'access-123');

      RequestOptions? captured;
      final adapter = _StubAdapter((options) async {
        captured = options;
        return _json('[]', 200);
      });
      final dio = Dio()..httpClientAdapter = adapter;
      final client = ApiClient(tokenStorage: tokenStorage, dio: dio);

      await client.dio.get('/api/v1/vehiculos');

      expect(captured!.headers['Authorization'], 'Bearer access-123');
    });

    test('omits Authorization when no token', () async {
      RequestOptions? captured;
      final adapter = _StubAdapter((options) async {
        captured = options;
        return _json('[]', 200);
      });
      final dio = Dio()..httpClientAdapter = adapter;
      final client = ApiClient(tokenStorage: tokenStorage, dio: dio);

      await client.dio.get('/api/v1/vehiculos');

      expect(captured!.headers.containsKey('Authorization'), isFalse);
    });
  });

  group('ApiClient refresh interceptor', () {
    for (final status in [401, 500]) {
      test(
        'revoked refresh ends session; transient error does not: $status',
        () async {
          when(
            () => tokenStorage.readAccessToken(),
          ).thenAnswer((_) async => 'old');
          when(
            () => tokenStorage.readRefreshToken(),
          ).thenAnswer((_) async => 'refresh');
          var expired = 0;
          final dio = Dio()
            ..httpClientAdapter = _StubAdapter(
              (options) async => _json(
                '{}',
                options.path == '/api/v1/auth/refresh' ? status : 401,
              ),
            );
          final client = ApiClient(
            tokenStorage: tokenStorage,
            dio: dio,
            onSessionExpired: () async {
              expired++;
            },
          );
          await expectLater(
            client.dio.get('/api/v1/usuarios'),
            throwsA(isA<DioException>()),
          );
          expect(expired, status == 401 ? 1 : 0);
        },
      );
    }
    test('late 401 reuses the token renewed by a parallel request', () async {
      String accessToken = 'expired';
      when(
        () => tokenStorage.readAccessToken(),
      ).thenAnswer((_) async => accessToken);
      when(
        () => tokenStorage.readRefreshToken(),
      ).thenAnswer((_) async => 'refresh');
      when(
        () => tokenStorage.saveTokens(
          accessToken: any(named: 'accessToken'),
          refreshToken: any(named: 'refreshToken'),
        ),
      ).thenAnswer((call) async {
        accessToken = call.namedArguments[#accessToken] as String;
      });
      final lateRequestStarted = Completer<void>();
      final releaseLateResponse = Completer<void>();
      int refreshCount = 0;
      final dio = Dio()
        ..httpClientAdapter = _StubAdapter((options) async {
          if (options.path == '/api/v1/auth/refresh') {
            refreshCount++;
            return _json('{"token":"renewed","refreshToken":"rotated"}', 200);
          }
          if (options.headers['Authorization'] == 'Bearer expired') {
            if (options.path == '/late') {
              lateRequestStarted.complete();
              await releaseLateResponse.future;
            }
            return _json('{"message":"expired"}', 401);
          }
          return _json('[]', 200);
        });
      final client = ApiClient(tokenStorage: tokenStorage, dio: dio);
      final late = client.dio.get('/late');
      await lateRequestStarted.future;
      await client.dio.get('/first');
      releaseLateResponse.complete();
      expect((await late).statusCode, 200);
      expect(refreshCount, 1);
    });

    test('refreshes token and retries request on 401', () async {
      String accessToken = 'old-token';
      when(
        () => tokenStorage.readAccessToken(),
      ).thenAnswer((_) async => accessToken);
      when(
        () => tokenStorage.readRefreshToken(),
      ).thenAnswer((_) async => 'refresh-123');
      when(
        () => tokenStorage.saveTokens(
          accessToken: any(named: 'accessToken'),
          refreshToken: any(named: 'refreshToken'),
        ),
      ).thenAnswer((invocation) async {
        accessToken = invocation.namedArguments[#accessToken] as String;
      });

      var callCount = 0;
      RequestOptions? retriedRequest;
      final adapter = _StubAdapter((options) async {
        if (options.path == '/api/v1/auth/refresh') {
          return _json(
            '{"token":"new-token","refreshToken":"new-refresh"}',
            200,
          );
        }
        callCount++;
        if (callCount == 1) {
          throw DioException(
            requestOptions: options,
            response: Response(requestOptions: options, statusCode: 401),
          );
        }
        retriedRequest = options;
        return _json('[]', 200);
      });
      final dio = Dio()..httpClientAdapter = adapter;
      final client = ApiClient(tokenStorage: tokenStorage, dio: dio);

      final response = await client.dio.get(
        '/api/v1/vehiculos',
        queryParameters: {'fecha': '2026-10-21'},
        options: Options(receiveTimeout: const Duration(seconds: 90)),
      );

      expect(response.statusCode, 200);
      expect(callCount, 2);
      expect(retriedRequest!.headers['Authorization'], 'Bearer new-token');
      expect(retriedRequest!.receiveTimeout, const Duration(seconds: 90));
      expect(retriedRequest!.queryParameters['fecha'], '2026-10-21');
    });

    test('does not refresh on auth endpoints', () async {
      when(
        () => tokenStorage.readAccessToken(),
      ).thenAnswer((_) async => 'token');
      when(
        () => tokenStorage.readRefreshToken(),
      ).thenAnswer((_) async => 'refresh-123');

      var callCount = 0;
      final adapter = _StubAdapter((options) async {
        callCount++;
        throw DioException(
          requestOptions: options,
          response: Response(requestOptions: options, statusCode: 401),
        );
      });
      final dio = Dio()..httpClientAdapter = adapter;
      final client = ApiClient(tokenStorage: tokenStorage, dio: dio);

      await expectLater(
        client.dio.post('/api/v1/auth/login', data: {}),
        throwsA(isA<DioException>()),
      );

      // login no reincide ni llama a refresh
      expect(callCount, 1);
    });

    test('does not refresh when no refresh token stored', () async {
      when(
        () => tokenStorage.readAccessToken(),
      ).thenAnswer((_) async => 'token');
      when(() => tokenStorage.readRefreshToken()).thenAnswer((_) async => null);

      var callCount = 0;
      final adapter = _StubAdapter((options) async {
        callCount++;
        throw DioException(
          requestOptions: options,
          response: Response(requestOptions: options, statusCode: 401),
        );
      });
      final dio = Dio()..httpClientAdapter = adapter;
      final client = ApiClient(tokenStorage: tokenStorage, dio: dio);

      await expectLater(
        client.dio.get('/api/v1/vehiculos'),
        throwsA(isA<DioException>()),
      );

      expect(callCount, 1);
    });
  });

  group('ApiClient error interceptor', () {
    test('wraps connection errors with NoConnectionException', () async {
      final adapter = _StubAdapter((options) async {
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
          error: const SocketException('unreachable'),
        );
      });
      final dio = Dio()..httpClientAdapter = adapter;
      final client = ApiClient(tokenStorage: tokenStorage, dio: dio);

      await expectLater(
        client.dio.get('/api/v1/vehiculos'),
        throwsA(
          isA<DioException>().having(
            (e) => e.error,
            'error',
            isA<NoConnectionException>(),
          ),
        ),
      );
    });
  });
}

class SocketException implements Exception {
  const SocketException(this.message);

  final String message;

  @override
  String toString() => 'SocketException: $message';
}
