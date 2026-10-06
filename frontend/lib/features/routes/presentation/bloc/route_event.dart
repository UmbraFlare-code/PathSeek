part of 'route_bloc.dart';

sealed class RouteEvent extends Equatable {
  const RouteEvent();

  @override
  List<Object?> get props => [];
}

class RoutesLoaded extends RouteEvent {
  const RoutesLoaded({this.fecha});

  final String? fecha;

  @override
  List<Object?> get props => [fecha];
}

class RoutesGenerated extends RouteEvent {
  const RoutesGenerated();
}

class RouteDetailRequested extends RouteEvent {
  const RouteDetailRequested(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

class RouteDeleted extends RouteEvent {
  const RouteDeleted(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}
