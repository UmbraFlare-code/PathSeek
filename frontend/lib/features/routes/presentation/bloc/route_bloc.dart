import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/services/offline_route_cache.dart';
import '../../../../core/services/sync_queue.dart';
import '../../data/models/delivery_route_model.dart';
import '../../domain/entities/delivery_route.dart';
import '../../domain/repositories/route_repository.dart';

part 'route_event.dart';
part 'route_state.dart';

class RouteBloc extends Bloc<RouteEvent, RouteState> {
  RouteBloc({
    required RouteRepository repository,
    OfflineRouteCache? offlineCache,
    SyncQueue? syncQueue,
  })  : _repository = repository,
        _offlineCache = offlineCache ?? OfflineRouteCache(),
        _syncQueue = syncQueue ?? SyncQueue(),
        super(const RouteState.initial()) {
    on<RoutesLoaded>(_onRoutesLoaded);
    on<RoutesGenerated>(_onRoutesGenerated);
    on<RouteDetailRequested>(_onRouteDetailRequested);
    on<RouteDeleted>(_onRouteDeleted);
    on<DeliveryCompleted>(_onDeliveryCompleted);
    on<PositionReported>(_onPositionReported);
    on<IncidentReported>(_onIncidentReported);
    on<RouteReoptimized>(_onRouteReoptimized);
  }

  final RouteRepository _repository;
  final OfflineRouteCache _offlineCache;
  final SyncQueue _syncQueue;

  Future<void> _onRoutesLoaded(
    RoutesLoaded event,
    Emitter<RouteState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null, offlineMessage: null));
    try {
      final routes = await _repository.getRoutes(fecha: event.fecha);
      emit(state.copyWith(isLoading: false, routes: routes));
    } on NetworkFailure {
      final cached = await _offlineCache.readRoutes();
      if (cached != null && cached.isNotEmpty) {
        final routes = cached
            .map((json) => DeliveryRouteModel.fromJson(json).toEntity())
            .toList();
        emit(
          state.copyWith(
            isLoading: false,
            routes: routes,
            offlineMessage: 'Sin conexión: mostrando rutas guardadas.',
          ),
        );
      } else {
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage: 'Sin conexión y sin datos guardados en este equipo.',
          ),
        );
      }
    } on Failure catch (failure) {
      emit(state.copyWith(isLoading: false, errorMessage: failure.message));
    }
  }

  Future<void> _onRoutesGenerated(
    RoutesGenerated event,
    Emitter<RouteState> emit,
  ) async {
    if (state.isGenerating) return;
    emit(state.copyWith(isGenerating: true, generateSuccess: false, generateErrorMessage: null));
    try {
      final result = await _repository.generateRoutes();
      emit(
        state.copyWith(
          isGenerating: false,
          generateSuccess: true,
          generatedRoutes: result.rutas.length,
          unassignedOrders: result.pedidosNoAsignados.length,
          routes: {
            for (final route in state.routes) route.id: route,
            for (final route in result.rutas) route.id: route,
          }.values.toList(),
        ),
      );
    } on Failure catch (failure) {
      emit(
        state.copyWith(
          isGenerating: false,
          generateErrorMessage: failure.message,
        ),
      );
    }
  }

  Future<void> _onRouteDetailRequested(
    RouteDetailRequested event,
    Emitter<RouteState> emit,
  ) async {
    emit(state.copyWith(isDetailLoading: true, detailError: null, offlineMessage: null));
    try {
      final route = await _repository.getRouteById(event.id);
      emit(state.copyWith(isDetailLoading: false, selectedRoute: route));
    } on NetworkFailure {
      final cached = await _offlineCache.readRouteDetail(event.id);
      if (cached != null) {
        emit(
          state.copyWith(
            isDetailLoading: false,
            selectedRoute: DeliveryRouteModel.fromJson(cached).toEntity(),
            offlineMessage: 'Sin conexión: mostrando la ruta guardada.',
          ),
        );
      } else {
        emit(
          state.copyWith(
            isDetailLoading: false,
            detailError: 'Sin conexión y sin datos guardados para esta ruta.',
          ),
        );
      }
    } on Failure catch (failure) {
      emit(
        state.copyWith(isDetailLoading: false, detailError: failure.message),
      );
    }
  }

  Future<void> _onRouteDeleted(
    RouteDeleted event,
    Emitter<RouteState> emit,
  ) async {
    emit(state.copyWith(isSaving: true, saveErrorMessage: null));
    try {
      await _repository.deleteRoute(event.id);
      emit(
        state.copyWith(
          isSaving: false,
          routes: state.routes.where((r) => r.id != event.id).toList(),
        ),
      );
    } on Failure catch (failure) {
      emit(
        state.copyWith(isSaving: false, saveErrorMessage: failure.message),
      );
    }
  }

  Future<void> _onDeliveryCompleted(
    DeliveryCompleted event,
    Emitter<RouteState> emit,
  ) async {
    emit(state.copyWith(isExecuting: true, executionMessage: null));
    try {
      final update = await _repository.completeDelivery(
        event.rutaId,
        event.pedidoId,
      );
      emit(
        state.copyWith(
          isExecuting: false,
          executionMessage: update.yaRegistrado
              ? 'La entrega ya estaba registrada.'
              : 'Entrega registrada. Estado de la ruta: ${update.rutaEstado}.',
        ),
      );
      await _reloadDetail(emit, event.rutaId);
    } on NetworkFailure {
      await _syncQueue.enqueue(
        tipo: 'completar',
        rutaId: event.rutaId,
        pedidoId: event.pedidoId,
      );
      emit(
        state.copyWith(
          isExecuting: false,
          executionMessage:
              'Sin conexión: la entrega quedó guardada y se sincronizará al recuperar la red.',
        ),
      );
    } on Failure catch (failure) {
      emit(
        state.copyWith(isExecuting: false, executionMessage: failure.message),
      );
    }
  }

  Future<void> _onPositionReported(
    PositionReported event,
    Emitter<RouteState> emit,
  ) async {
    emit(state.copyWith(isExecuting: true, executionMessage: null));
    try {
      final update = await _repository.reportPosition(
        event.rutaId,
        event.lat,
        event.lon,
      );
      emit(
        state.copyWith(
          isExecuting: false,
          executionMessage: 'Posición registrada. Estado de la ruta: ${update.rutaEstado}.',
        ),
      );
      await _reloadDetail(emit, event.rutaId);
    } on NetworkFailure {
      await _syncQueue.enqueue(
        tipo: 'posicion',
        rutaId: event.rutaId,
        lat: event.lat,
        lon: event.lon,
      );
      emit(
        state.copyWith(
          isExecuting: false,
          executionMessage:
              'Sin conexión: la posición quedó guardada y se sincronizará al recuperar la red.',
        ),
      );
    } on Failure catch (failure) {
      emit(
        state.copyWith(isExecuting: false, executionMessage: failure.message),
      );
    }
  }

  Future<void> _onIncidentReported(
    IncidentReported event,
    Emitter<RouteState> emit,
  ) async {
    emit(state.copyWith(isExecuting: true, executionMessage: null));
    try {
      await _repository.reportIncident(event.rutaId, event.payload);
      emit(
        state.copyWith(
          isExecuting: false,
          executionMessage: 'Incidente registrado. Ya puede reoptimizar la ruta.',
        ),
      );
    } on Failure catch (failure) {
      emit(
        state.copyWith(isExecuting: false, executionMessage: failure.message),
      );
    }
  }

  Future<void> _onRouteReoptimized(
    RouteReoptimized event,
    Emitter<RouteState> emit,
  ) async {
    emit(state.copyWith(isExecuting: true, executionMessage: null));
    try {
      final result = await _repository.reoptimize(event.payload);
      emit(
        state.copyWith(
          isExecuting: false,
          executionMessage: 'Reoptimización lista: ${result.rutasReoptimizadas} ruta(s) '
              'recalculada(s), ${result.rutasSinCambios} sin cambios, '
              '${result.notificacionesGeneradas} aviso(s) al conductor '
              '(${result.tiempoCalculoMs} ms).',
        ),
      );
      await _reloadDetail(emit, event.rutaId);
    } on Failure catch (failure) {
      emit(
        state.copyWith(isExecuting: false, executionMessage: failure.message),
      );
    }
  }

  Future<void> _reloadDetail(Emitter<RouteState> emit, String rutaId) async {
    try {
      final route = await _repository.getRouteById(rutaId);
      emit(state.copyWith(selectedRoute: route));
    } on Failure {
      // La acción ya se confirmó; el refresco puede esperar.
    }
  }
}
