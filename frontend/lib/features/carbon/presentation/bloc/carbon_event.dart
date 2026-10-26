part of 'carbon_bloc.dart';

sealed class CarbonEvent extends Equatable {
  const CarbonEvent();

  @override
  List<Object?> get props => [];
}

class CarbonPlanRequested extends CarbonEvent {
  const CarbonPlanRequested();
}
