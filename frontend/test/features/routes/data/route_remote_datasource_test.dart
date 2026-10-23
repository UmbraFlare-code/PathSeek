import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pathseek/core/network/api_client.dart';
import 'package:pathseek/core/network/token_storage.dart';
import 'package:pathseek/features/routes/data/datasources/route_remote_datasource.dart';

class Storage extends Mock implements TokenStorage {}
class Adapter implements HttpClientAdapter {
  final paths = <String>[];
  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? stream, Future<void>? cancel) async {
    paths.add(options.path);
    expect(options.headers['Authorization'], 'Bearer validated-token');
    return ResponseBody.fromString(options.path.endsWith('/geometria')
        ? '{"encodedPolyline":"test-geometry"}' : '{"ruta_id":"r1","fecha":"2026-10-22","pedidos":[]}', 200,
      headers: {Headers.contentTypeHeader: [Headers.jsonContentType]});
  }
  @override
  void close({bool force = false}) {}
}
void main() {
  test('detail combines the API geometry using the same authenticated client', () async {
    final storage = Storage();
    when(() => storage.readAccessToken()).thenAnswer((_) async => 'validated-token');
    final adapter = Adapter();
    final dio = Dio()..httpClientAdapter = adapter;
    final source = RouteRemoteDataSourceImpl(ApiClient(tokenStorage: storage, dio: dio));
    final model = await source.getRouteById('r1');
    expect(adapter.paths, ['/api/v1/rutas/r1', '/api/v1/rutas/r1/geometria']);
    expect(model.encodedPolyline, 'test-geometry');
    expect(model.toEntity().id, 'r1');
  });
}
