import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pathseek/core/errors/failures.dart';
import 'package:pathseek/features/carbon/domain/entities/carbon_plan.dart';
import 'package:pathseek/features/carbon/domain/repositories/carbon_repository.dart';

part 'carbon_event.dart';
part 'carbon_state.dart';

class CarbonBloc extends Bloc<CarbonEvent, CarbonState> {
  CarbonBloc({required CarbonRepository repository})
      : _repository = repository,
        super(const CarbonState.initial()) {
    on<CarbonPlanRequested>(_onRequested);
  }

  final CarbonRepository _repository;

  Future<void> _onRequested(
    CarbonPlanRequested event,
    Emitter<CarbonState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final plan = await _repository.getPlan();
      emit(state.copyWith(isLoading: false, plan: plan));
    } on Failure catch (failure) {
      emit(state.copyWith(isLoading: false, errorMessage: failure.message));
    }
  }
}
