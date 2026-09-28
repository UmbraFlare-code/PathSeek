import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/vehicle.dart';
import '../../domain/repositories/fleet_repository.dart';

part 'fleet_event.dart';
part 'fleet_state.dart';

class FleetBloc extends Bloc<FleetEvent, FleetState> {
  FleetBloc({required FleetRepository repository})
      : _repository = repository,
        super(const FleetState.initial()) {
    on<FleetLoaded>(_onFleetLoaded);
    on<FleetVehicleCreated>(_onFleetVehicleCreated);
    on<FleetVehicleUpdated>(_onFleetVehicleUpdated);
    on<FleetVehicleDeleted>(_onFleetVehicleDeleted);
  }

  final FleetRepository _repository;

  Future<void> _onFleetLoaded(
    FleetLoaded event,
    Emitter<FleetState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final vehicles = await _repository.getVehicles();
      emit(state.copyWith(isLoading: false, vehicles: vehicles));
    } on Failure catch (failure) {
      emit(state.copyWith(isLoading: false, errorMessage: failure.message));
    }
  }

  Future<void> _onFleetVehicleCreated(
    FleetVehicleCreated event,
    Emitter<FleetState> emit,
  ) async {
    emit(state.copyWith(isSaving: true, saveErrorMessage: null, saveSuccess: false));
    try {
      final vehicle = await _repository.createVehicle(event.vehicle);
      emit(
        state.copyWith(
          isSaving: false,
          saveSuccess: true,
          vehicles: [...state.vehicles, vehicle],
        ),
      );
    } on Failure catch (failure) {
      emit(
        state.copyWith(isSaving: false, saveErrorMessage: failure.message),
      );
    }
  }

  Future<void> _onFleetVehicleUpdated(
    FleetVehicleUpdated event,
    Emitter<FleetState> emit,
  ) async {
    emit(state.copyWith(isSaving: true, saveErrorMessage: null, saveSuccess: false));
    try {
      final vehicle = await _repository.updateVehicle(event.vehicle);
      emit(
        state.copyWith(
          isSaving: false,
          saveSuccess: true,
          vehicles: state.vehicles
              .map((v) => v.id == vehicle.id ? vehicle : v)
              .toList(),
        ),
      );
    } on Failure catch (failure) {
      emit(
        state.copyWith(isSaving: false, saveErrorMessage: failure.message),
      );
    }
  }

  Future<void> _onFleetVehicleDeleted(
    FleetVehicleDeleted event,
    Emitter<FleetState> emit,
  ) async {
    emit(state.copyWith(isSaving: true, saveErrorMessage: null));
    try {
      await _repository.deleteVehicle(event.id);
      emit(
        state.copyWith(
          isSaving: false,
          vehicles:
              state.vehicles.where((v) => v.id != event.id).toList(),
        ),
      );
    } on Failure catch (failure) {
      emit(
        state.copyWith(isSaving: false, saveErrorMessage: failure.message),
      );
    }
  }
}
