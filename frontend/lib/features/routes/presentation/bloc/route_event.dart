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

class RouteReoptimized extends RouteEvent {
  const RouteReoptimized({
    required this.id,
    required this.motivo,
    required this.latitudIncidente,
    required this.longitudIncidente,
    this.radioBloqueoMetros = 250,
    this.pedidosCancelados = const [],
  });

  final String id;
  final String motivo;
  final double latitudIncidente;
  final double longitudIncidente;
  final int radioBloqueoMetros;
  final List<String> pedidosCancelados;

  @override
  List<Object?> get props => [
        id,
        motivo,
        latitudIncidente,
        longitudIncidente,
        radioBloqueoMetros,
        pedidosCancelados,
      ];
}

class RouteDeleted extends RouteEvent {
  const RouteDeleted(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}
