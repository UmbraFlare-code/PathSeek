part of 'fleet_bloc.dart';

sealed class FleetEvent extends Equatable {
  const FleetEvent();

  @override
  List<Object?> get props => [];
}

class FleetLoaded extends FleetEvent {
  const FleetLoaded();
}

class FleetVehicleCreated extends FleetEvent {
  const FleetVehicleCreated(this.vehicle);

  final Vehicle vehicle;

  @override
  List<Object?> get props => [vehicle];
}

class FleetVehicleUpdated extends FleetEvent {
  const FleetVehicleUpdated(this.vehicle);

  final Vehicle vehicle;

  @override
  List<Object?> get props => [vehicle];
}

class FleetVehicleDeleted extends FleetEvent {
  const FleetVehicleDeleted(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}
