import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pathseek/core/errors/failures.dart';
import 'package:pathseek/features/routes/domain/entities/delivery_route.dart';
import 'package:pathseek/features/routes/domain/entities/generate_routes_result.dart';
import 'package:pathseek/features/routes/domain/repositories/route_repository.dart';
import 'package:pathseek/features/routes/presentation/bloc/route_bloc.dart';

class MockRouteRepository extends Mock implements RouteRepository {}

void main() {
  late MockRouteRepository repository;
  late RouteBloc bloc;

  const route = DeliveryRoute(
    id: 'r1',
    fecha: '2026-10-05',
    conductorId: 'd1',
    conductorNombre: 'Carlos Gomez',
    vehiculoId: 'v1',
    placa: 'ABC123',
    distanciaKm: 45.2,
    co2Kg: 11.3,
    combustibleL: 8.5,
    estado: 'PLANIFICADA',
    pedidos: [
      RouteOrder(
        pedidoId: 'o1',
        orden: 1,
        horaEstimada: '08:30',
        direccion: 'Av. Real 123',
        peso: 20,
        ventanaInicio: '08:00',
        ventanaFin: '12:00',
      ),
    ],
  );

  setUp(() {
    repository = MockRouteRepository();
    bloc = RouteBloc(repository: repository);
  });

  tearDown(() => bloc.close());

  group('RouteBloc', () {
    test('initial state is initial', () {
      expect(bloc.state, const RouteState.initial());
    });

    blocTest<RouteBloc, RouteState>(
      'loads routes successfully',
      build: () {
        when(() => repository.getRoutes(fecha: any(named: 'fecha')))
            .thenAnswer((_) async => [route]);
        return bloc;
      },
      act: (bloc) => bloc.add(const RoutesLoaded()),
      expect: () => [
        isA<RouteState>().having((s) => s.isLoading, 'isLoading', true),
        isA<RouteState>()
            .having((s) => s.routes, 'routes', [route])
            .having((s) => s.isLoading, 'isLoading', false),
      ],
    );

    blocTest<RouteBloc, RouteState>(
      'generates routes and reports counts',
      build: () {
        when(() => repository.generateRoutes()).thenAnswer(
          (_) async => const GenerateRoutesResult(
            rutas: [route],
            pedidosNoAsignados: ['o2'],
          ),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(const RoutesGenerated()),
      expect: () => [
        isA<RouteState>().having((s) => s.isGenerating, 'isGenerating', true),
        isA<RouteState>()
            .having((s) => s.generateSuccess, 'generateSuccess', true)
            .having((s) => s.generatedRoutes, 'generatedRoutes', 1)
            .having((s) => s.unassignedOrders, 'unassigned', 1)
            .having((s) => s.routes, 'routes', [route]),
      ],
    );

    blocTest<RouteBloc, RouteState>(
      'sets generate error on failure',
      build: () {
        when(() => repository.generateRoutes())
            .thenThrow(const ServerFailure('Error del motor'));
        return bloc;
      },
      act: (bloc) => bloc.add(const RoutesGenerated()),
      expect: () => [
        isA<RouteState>().having((s) => s.isGenerating, 'isGenerating', true),
        isA<RouteState>()
            .having((s) => s.hasGenerateError, 'hasError', true)
            .having((s) => s.generateErrorMessage, 'msg', 'Error del motor'),
      ],
    );

    blocTest<RouteBloc, RouteState>(
      'loads route detail',
      build: () {
        when(() => repository.getRouteById('r1'))
            .thenAnswer((_) async => route);
        return bloc;
      },
      act: (bloc) => bloc.add(const RouteDetailRequested('r1')),
      expect: () => [
        isA<RouteState>()
            .having((s) => s.isDetailLoading, 'isDetailLoading', true),
        isA<RouteState>()
            .having((s) => s.selectedRoute, 'selectedRoute', route)
            .having((s) => s.isDetailLoading, 'isDetailLoading', false),
      ],
    );

    blocTest<RouteBloc, RouteState>(
      'deletes route from list',
      build: () {
        when(() => repository.deleteRoute('r1')).thenAnswer((_) async {});
        return bloc;
      },
      seed: () => const RouteState(routes: [route]),
      act: (bloc) => bloc.add(const RouteDeleted('r1')),
      expect: () => [
        isA<RouteState>().having((s) => s.isSaving, 'isSaving', true),
        isA<RouteState>().having((s) => s.routes, 'routes', isEmpty),
      ],
    );
  });
}
