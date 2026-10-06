import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/route_plan.dart';
import '../../domain/repositories/route_repository.dart';

part 'route_event.dart';
part 'route_state.dart';

class RouteBloc extends Bloc<RouteEvent, RouteState> {
  RouteBloc({required RouteRepository repository})
      : _repository = repository,
        super(const RouteState.initial()) {
    on<RoutesGenerateRequested>(_onGenerate);
    on<RoutesPerformanceRequested>(_onPerformance);
    on<RoutesConfirmRequested>(_onConfirm);
  }

  final RouteRepository _repository;

  Future<void> _onGenerate(
    RoutesGenerateRequested event,
    Emitter<RouteState> emit,
  ) async {
    emit(state.copyWith(isGenerating: true, errorMessage: null));    try {
      final locked = await _repository.isLocked();
      if (locked) {
        emit(state.copyWith(
          isGenerating: false,
          errorMessage: 'Ya existe una generación en curso; intente nuevamente',
        ));
        return;
      }
      final plan = await _repository.generateRoutes(
        fechaOperacion: event.fechaOperacion,
        depositoLat: event.depositoLat,
        depositoLon: event.depositoLon,
        velocidadKmh: event.velocidadKmh,
        tiempoServicioMin: event.tiempoServicioMin,
      );
      final performance = await _repository.getPerformance();
      emit(state.copyWith(
        isGenerating: false,
        plan: plan,
        performance: performance,
      ));
    } on Failure catch (failure) {
      emit(state.copyWith(
        isGenerating: false,
        errorMessage: failure.message,
      ));
    }
  }

  Future<void> _onPerformance(
    RoutesPerformanceRequested event,
    Emitter<RouteState> emit,
  ) async {
    try {
      final performance = await _repository.getPerformance();
      emit(state.copyWith(performance: performance));
    } on Failure {
      // Métricas opcionales: no bloquear la pantalla si fallan.
    }
  }

  Future<void> _onConfirm(
    RoutesConfirmRequested event,
    Emitter<RouteState> emit,
  ) async {
    final plan = state.plan;
    if (plan == null) return;
    final ids = <String>[];
    for (final r in plan.rutas) {
      for (final s in r.paradas) {
        ids.add(s.pedidoId);
      }
    }
    if (ids.isEmpty) return;
    emit(state.copyWith(isGenerating: true, errorMessage: null));
    try {
      final result = await _repository.confirmRoutes(ids);
      emit(state.copyWith(
        isGenerating: false,
        clearPlan: true,
        lastNotice: '${result.confirmados} pedidos pasaron a EN_RUTA '
            '(${result.omitidos} omitidos). Ya no se replanificarán.',
      ));
    } on Failure catch (failure) {
      emit(state.copyWith(
        isGenerating: false,
        errorMessage: failure.message,
      ));
    }
  }
}
