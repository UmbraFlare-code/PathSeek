import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pathseek/core/errors/exceptions.dart';
import 'package:pathseek/core/errors/failures.dart';
import 'package:pathseek/features/routes/data/datasources/route_remote_datasource.dart';
import 'package:pathseek/features/routes/data/models/delivery_route_model.dart';
import 'package:pathseek/features/routes/data/repositories/route_repository_impl.dart';

class MockRouteRemoteDataSource extends Mock
    implements RouteRemoteDataSource {}

void main() {
  late MockRouteRemoteDataSource remoteDataSource;
  late RouteRepositoryImpl repository;

  setUp(() {
    remoteDataSource = MockRouteRemoteDataSource();
    repository = RouteRepositoryImpl(remoteDataSource: remoteDataSource);
  });

  group('RouteRepositoryImpl.getRoutes', () {
    test('returns entities on success', () async {
      when(() => remoteDataSource.getRoutes(fecha: any(named: 'fecha')))
          .thenAnswer(
        (_) async => [
          const DeliveryRouteModel(
            id: 'r1',
            fecha: '2026-10-05',
            placa: 'ABC123',
            distanciaKm: 45.2,
          ),
        ],
      );

      final routes = await repository.getRoutes(fecha: '2026-10-05');

      expect(routes, hasLength(1));
      expect(routes.first.id, 'r1');
      expect(routes.first.placa, 'ABC123');
    });

    test('maps 404 to NotFoundFailure', () async {
      when(() => remoteDataSource.getRoutes(fecha: any(named: 'fecha')))
          .thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/api/v1/rutas'),
          response: Response(
            requestOptions: RequestOptions(path: '/api/v1/rutas'),
            statusCode: 404,
          ),
        ),
      );

      expect(
        () => repository.getRoutes(),
        throwsA(isA<NotFoundFailure>()),
      );
    });

    test('maps connection errors to NetworkFailure', () async {
      when(() => remoteDataSource.getRoutes(fecha: any(named: 'fecha')))
          .thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/api/v1/rutas'),
          error: const NoConnectionException(),
        ),
      );

      expect(
        () => repository.getRoutes(),
        throwsA(isA<NetworkFailure>()),
      );
    });
  });

  group('RouteRepositoryImpl.generateRoutes', () {
    test('parses rutas y pedidos no asignados', () async {
      when(() => remoteDataSource.generateRoutes()).thenAnswer(
        (_) async => {
          'rutas': [
            {
              'ruta_id': 'r1',
              'fecha': '2026-10-05',
              'distancia_km': 45.2,
              'pedidos': [
                {'pedido_id': 'o1', 'orden': 1},
              ],
            },
          ],
          'pedidos_no_asignados': ['o2'],
        },
      );

      final result = await repository.generateRoutes();

      expect(result.rutas, hasLength(1));
      expect(result.rutas.first.id, 'r1');
      expect(result.rutas.first.pedidos, hasLength(1));
      expect(result.pedidosNoAsignados, ['o2']);
    });

    test('tolerates missing keys in response', () async {
      when(() => remoteDataSource.generateRoutes())
          .thenAnswer((_) async => <String, dynamic>{});

      final result = await repository.generateRoutes();

      expect(result.rutas, isEmpty);
      expect(result.pedidosNoAsignados, isEmpty);
    });

    test('maps 500 to ServerFailure', () async {
      when(() => remoteDataSource.generateRoutes()).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/api/v1/rutas/generar'),
          response: Response(
            requestOptions: RequestOptions(path: '/api/v1/rutas/generar'),
            statusCode: 500,
            data: {'message': 'Error del motor'},
          ),
        ),
      );

      expect(
        () => repository.generateRoutes(),
        throwsA(
          isA<ServerFailure>()
              .having((f) => f.message, 'message', 'Error del motor'),
        ),
      );
    });
  });

  group('RouteRepositoryImpl.getRouteById / deleteRoute', () {
    test('returns entity by id', () async {
      when(() => remoteDataSource.getRouteById('r1')).thenAnswer(
        (_) async => const DeliveryRouteModel(
          id: 'r1',
          fecha: '2026-10-05',
          estado: 'PLANIFICADA',
        ),
      );

      final route = await repository.getRouteById('r1');

      expect(route.id, 'r1');
      expect(route.estado, 'PLANIFICADA');
    });

    test('deleteRoute maps errors', () async {
      when(() => remoteDataSource.deleteRoute('r1')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/api/v1/rutas/r1'),
          error: const NoConnectionException(),
        ),
      );

      expect(
        () => repository.deleteRoute('r1'),
        throwsA(isA<NetworkFailure>()),
      );
    });

    test('deleteRoute succeeds silently', () async {
      when(() => remoteDataSource.deleteRoute('r1'))
          .thenAnswer((_) async {});

      await repository.deleteRoute('r1');

      verify(() => remoteDataSource.deleteRoute('r1')).called(1);
    });
  });
}
