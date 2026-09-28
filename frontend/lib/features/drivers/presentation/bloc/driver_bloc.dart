import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/driver.dart';
import '../../domain/repositories/driver_repository.dart';

part 'driver_event.dart';
part 'driver_state.dart';

class DriverBloc extends Bloc<DriverEvent, DriverState> {
  DriverBloc({required DriverRepository repository})
      : _repository = repository,
        super(const DriverState.initial()) {
    on<DriversLoaded>(_onDriversLoaded);
    on<DriverCreated>(_onDriverCreated);
    on<DriverUpdated>(_onDriverUpdated);
    on<DriverDeleted>(_onDriverDeleted);
  }

  final DriverRepository _repository;

  Future<void> _onDriversLoaded(
    DriversLoaded event,
    Emitter<DriverState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final drivers = await _repository.getDrivers();
      emit(state.copyWith(isLoading: false, drivers: drivers));
    } on Failure catch (failure) {
      emit(state.copyWith(isLoading: false, errorMessage: failure.message));
    }
  }

  Future<void> _onDriverCreated(
    DriverCreated event,
    Emitter<DriverState> emit,
  ) async {
    emit(state.copyWith(isSaving: true, saveErrorMessage: null, saveSuccess: false));
    try {
      final driver = await _repository.createDriver(event.driver);
      emit(
        state.copyWith(
          isSaving: false,
          saveSuccess: true,
          drivers: [...state.drivers, driver],
        ),
      );
    } on Failure catch (failure) {
      emit(
        state.copyWith(isSaving: false, saveErrorMessage: failure.message),
      );
    }
  }

  Future<void> _onDriverUpdated(
    DriverUpdated event,
    Emitter<DriverState> emit,
  ) async {
    emit(state.copyWith(isSaving: true, saveErrorMessage: null, saveSuccess: false));
    try {
      final driver = await _repository.updateDriver(event.driver);
      emit(
        state.copyWith(
          isSaving: false,
          saveSuccess: true,
          drivers: state.drivers
              .map((d) => d.id == driver.id ? driver : d)
              .toList(),
        ),
      );
    } on Failure catch (failure) {
      emit(
        state.copyWith(isSaving: false, saveErrorMessage: failure.message),
      );
    }
  }

  Future<void> _onDriverDeleted(
    DriverDeleted event,
    Emitter<DriverState> emit,
  ) async {
    emit(state.copyWith(isSaving: true, saveErrorMessage: null, saveSuccess: false));
    try {
      await _repository.deleteDriver(event.id);
      emit(
        state.copyWith(
          isSaving: false,
          drivers: state.drivers.where((d) => d.id != event.id).toList(),
        ),
      );
    } on Failure catch (failure) {
      emit(
        state.copyWith(isSaving: false, saveErrorMessage: failure.message),
      );
    }
  }
}
