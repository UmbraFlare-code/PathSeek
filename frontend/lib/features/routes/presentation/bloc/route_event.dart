part of 'route_bloc.dart';

sealed class RouteEvent extends Equatable {
  const RouteEvent();

  @override
  List<Object?> get props => [];
}

class RoutesGenerateRequested extends RouteEvent {
  const RoutesGenerateRequested({
    required this.fechaOperacion,
    required this.depositoLat,
    required this.depositoLon,
    required this.velocidadKmh,
    this.tiempoServicioMin = 15,
  });

  final String fechaOperacion;
  final double depositoLat;
  final double depositoLon;
  final double velocidadKmh;
  final int tiempoServicioMin;

  @override
  List<Object?> get props => [
        fechaOperacion,
        depositoLat,
        depositoLon,
        velocidadKmh,
        tiempoServicioMin,
      ];
}

class RoutesPerformanceRequested extends RouteEvent {
  const RoutesPerformanceRequested();
}

class RoutesConfirmRequested extends RouteEvent {
  const RoutesConfirmRequested();
}
