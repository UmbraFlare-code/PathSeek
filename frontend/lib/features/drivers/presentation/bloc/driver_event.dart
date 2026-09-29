part of 'driver_bloc.dart';

sealed class DriverEvent extends Equatable {
  const DriverEvent();

  @override
  List<Object?> get props => [];
}

class DriversLoaded extends DriverEvent {
  const DriversLoaded();
}

class DriverCreated extends DriverEvent {
  const DriverCreated(this.driver);

  final Driver driver;

  @override
  List<Object?> get props => [driver];
}

class DriverUpdated extends DriverEvent {
  const DriverUpdated(this.driver);

  final Driver driver;

  @override
  List<Object?> get props => [driver];
}

class DriverDeleted extends DriverEvent {
  const DriverDeleted(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}
