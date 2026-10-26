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

class DeliveryCompleted extends RouteEvent {
  const DeliveryCompleted(this.rutaId, this.pedidoId);

  final String rutaId;
  final String pedidoId;

  @override
  List<Object?> get props => [rutaId, pedidoId];
}

class PositionReported extends RouteEvent {
  const PositionReported(this.rutaId, this.lat, this.lon);

  final String rutaId;
  final double lat;
  final double lon;

  @override
  List<Object?> get props => [rutaId, lat, lon];
}

class IncidentReported extends RouteEvent {
  const IncidentReported(this.rutaId, this.payload);

  final String rutaId;
  final Map<String, dynamic> payload;

  @override
  List<Object?> get props => [rutaId, payload];
}

class RouteReoptimized extends RouteEvent {
  const RouteReoptimized(this.rutaId, this.payload);

  final String rutaId;
  final Map<String, dynamic> payload;

  @override
  List<Object?> get props => [rutaId, payload];
}
