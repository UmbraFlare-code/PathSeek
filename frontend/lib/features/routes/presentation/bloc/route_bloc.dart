import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/delivery_route.dart';
import '../../domain/repositories/route_repository.dart';

part 'route_event.dart';
part 'route_state.dart';

class RouteBloc extends Bloc<RouteEvent, RouteState> {
  RouteBloc({required RouteRepository repository})
      : _repository = repository,
        super(const RouteState.initial()) {
    on<RoutesLoaded>(_onRoutesLoaded);
    on<RoutesGenerated>(_onRoutesGenerated);
    on<RouteDetailRequested>(_onRouteDetailRequested);
    on<RouteReoptimized>(_onRouteReoptimized);
    on<RouteDeleted>(_onRouteDeleted);
  }

  final RouteRepository _repository;

  Future<void> _onRoutesLoaded(
    RoutesLoaded event,
    Emitter<RouteState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final routes = await _repository.getRoutes(fecha: event.fecha);
      emit(state.copyWith(isLoading: false, routes: routes));
    } on Failure catch (failure) {
      emit(state.copyWith(isLoading: false, errorMessage: failure.message));
    }
  }

  Future<void> _onRoutesGenerated(
    RoutesGenerated event,
    Emitter<RouteState> emit,
  ) async {
    emit(state.copyWith(isGenerating: true, generateErrorMessage: null));
    try {
      final result = await _repository.generateRoutes();
      emit(
        state.copyWith(
          isGenerating: false,
          generateSuccess: true,
          generatedRoutes: result.rutas.length,
          unassignedOrders: result.pedidosNoAsignados.length,
          routes: [...result.rutas, ...state.routes],
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
    emit(state.copyWith(isDetailLoading: true, detailError: null));
    try {
      final route = await _repository.getRouteById(event.id);
      emit(state.copyWith(isDetailLoading: false, selectedRoute: route));
    } on Failure catch (failure) {
      emit(
        state.copyWith(isDetailLoading: false, detailError: failure.message),
      );
    }
  }

  Future<void> _onRouteReoptimized(
    RouteReoptimized event,
    Emitter<RouteState> emit,
  ) async {
    emit(state.copyWith(isReoptimizing: true, reoptimizeErrorMessage: null, reoptimizeSuccess: false));
    try {
      final updatedRoute = await _repository.reoptimizeRoute(
        event.id,
        motivo: event.motivo,
        latitudIncidente: event.latitudIncidente,
        longitudIncidente: event.longitudIncidente,
        radioBloqueoMetros: event.radioBloqueoMetros,
        pedidosCancelados: event.pedidosCancelados,
      );
      final updatedRoutes = state.routes.map((r) => r.id == event.id ? updatedRoute : r).toList();
      emit(
        state.copyWith(
          isReoptimizing: false,
          reoptimizeSuccess: true,
          selectedRoute: updatedRoute,
          routes: updatedRoutes,
        ),
      );
    } on Failure catch (failure) {
      emit(
        state.copyWith(
          isReoptimizing: false,
          reoptimizeErrorMessage: failure.message,
        ),
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
}
