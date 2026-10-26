import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pathseek/core/errors/failures.dart';
import 'package:pathseek/core/services/offline_route_cache.dart';
import 'package:pathseek/core/services/sync_queue.dart';
import 'package:pathseek/features/routes/domain/entities/delivery_route.dart';
import 'package:pathseek/features/routes/domain/entities/delivery_update.dart';
import 'package:pathseek/features/routes/domain/repositories/route_repository.dart';
import 'package:pathseek/features/routes/presentation/bloc/route_bloc.dart';

class MockRouteRepository extends Mock implements RouteRepository {}

class MockSyncQueue extends Mock implements SyncQueue {}

class MockOfflineRouteCache extends Mock implements OfflineRouteCache {}

void main() {
  late MockRouteRepository repository;
  late MockSyncQueue syncQueue;
  late MockOfflineRouteCache cache;
  late RouteBloc bloc;

  setUp(() {
    repository = MockRouteRepository();
    syncQueue = MockSyncQueue();
    cache = MockOfflineRouteCache();
    bloc = RouteBloc(
      repository: repository,
      syncQueue: syncQueue,
      offlineCache: cache,
    );
  });

  tearDown(() => bloc.close());

  group('RouteBloc execution', () {
    blocTest<RouteBloc, RouteState>(
      'completes a delivery and reloads the detail',
      build: () {
        when(() => repository.completeDelivery('r1', 'o1')).thenAnswer(
          (_) async => const DeliveryUpdate(
            pedidoEstado: 'ENTREGADO',
            rutaEstado: 'EN_PROGRESO',
            cumplioVentana: true,
          ),
        );
        when(() => repository.getRouteById('r1')).thenAnswer(
          (_) async => const DeliveryRoute(id: 'r1', fecha: '2026-10-25'),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(const DeliveryCompleted('r1', 'o1')),
      expect: () => [
        isA<RouteState>()
            .having((s) => s.isExecuting, 'isExecuting', true),
        isA<RouteState>().having(
          (s) => s.executionMessage,
          'message',
          contains('Entrega registrada'),
        ),
        isA<RouteState>().having(
          (s) => s.selectedRoute?.id,
          'selectedRoute',
          'r1',
        ),
      ],
    );

    blocTest<RouteBloc, RouteState>(
      'queues the delivery when offline',
      build: () {
        when(() => repository.completeDelivery('r1', 'o1'))
            .thenThrow(const NetworkFailure());
        when(() => syncQueue.enqueue(
              tipo: any(named: 'tipo'),
              rutaId: any(named: 'rutaId'),
              pedidoId: any(named: 'pedidoId'),
            )).thenAnswer((_) async {});
        return bloc;
      },
      act: (bloc) => bloc.add(const DeliveryCompleted('r1', 'o1')),
      verify: (_) {
        verify(
          () => syncQueue.enqueue(tipo: 'completar', rutaId: 'r1', pedidoId: 'o1'),
        ).called(1);
      },
      expect: () => [
        isA<RouteState>()
            .having((s) => s.isExecuting, 'isExecuting', true),
        isA<RouteState>().having(
          (s) => s.executionMessage,
          'message',
          contains('Sin conexión'),
        ),
      ],
    );

    blocTest<RouteBloc, RouteState>(
      'queues the position when offline',
      build: () {
        when(() => repository.reportPosition('r1', -12.06, -75.21))
            .thenThrow(const NetworkFailure());
        when(() => syncQueue.enqueue(
              tipo: any(named: 'tipo'),
              rutaId: any(named: 'rutaId'),
              lat: any(named: 'lat'),
              lon: any(named: 'lon'),
            )).thenAnswer((_) async {});
        return bloc;
      },
      act: (bloc) => bloc.add(const PositionReported('r1', -12.06, -75.21)),
      verify: (_) {
        verify(
          () => syncQueue.enqueue(
            tipo: 'posicion',
            rutaId: 'r1',
            lat: -12.06,
            lon: -75.21,
          ),
        ).called(1);
      },
    );

    blocTest<RouteBloc, RouteState>(
      'falls back to the cached route list when offline',
      build: () {
        when(() => repository.getRoutes(fecha: any(named: 'fecha')))
            .thenThrow(const NetworkFailure());
        when(() => cache.readRoutes()).thenAnswer(
          (_) async => [
            {'ruta_id': 'r1', 'fecha': '2026-10-25', 'estado': 'PLANIFICADA'},
          ],
        );
        return bloc;
      },
      act: (bloc) => bloc.add(const RoutesLoaded()),
      expect: () => [
        isA<RouteState>().having((s) => s.isLoading, 'isLoading', true),
        isA<RouteState>()
            .having((s) => s.routes.length, 'routes', 1)
            .having(
              (s) => s.offlineMessage,
              'offlineMessage',
              contains('Sin conexión'),
            ),
      ],
    );

    blocTest<RouteBloc, RouteState>(
      'reports reoptimization results',
      build: () {
        when(() => repository.reoptimize(any())).thenAnswer(
          (_) async => const ReoptimizationResult(
            rutasReoptimizadas: 1,
            rutasSinCambios: 0,
            pedidosNoAsignados: 0,
            notificacionesGeneradas: 2,
            tiempoCalculoMs: 150,
          ),
        );
        when(() => repository.getRouteById('r1')).thenAnswer(
          (_) async => const DeliveryRoute(id: 'r1', fecha: '2026-10-25'),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(
        const RouteReoptimized('r1', {'tipo': 'INCIDENTE', 'rutas_ids': ['r1']}),
      ),
      expect: () => [
        isA<RouteState>()
            .having((s) => s.isExecuting, 'isExecuting', true),
        isA<RouteState>().having(
          (s) => s.executionMessage,
          'message',
          contains('Reoptimización lista'),
        ),
        isA<RouteState>().having(
          (s) => s.selectedRoute?.id,
          'selectedRoute',
          'r1',
        ),
      ],
    );
  });
}
