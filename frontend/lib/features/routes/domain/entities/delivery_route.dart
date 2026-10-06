import 'package:equatable/equatable.dart';

class RoadContext extends Equatable {
  const RoadContext({
    this.tipoSuperficie = 'ASFALTO',
    this.factorCalzada = 1.0,
    this.elevacionMetros = 3260,
    this.pendientePorcentaje = 2.5,
    this.nivelCongestion = 'FLUIDO',
    this.incidentes = const [],
  });

  final String tipoSuperficie;
  final double factorCalzada;
  final int elevacionMetros;
  final double pendientePorcentaje;
  final String nivelCongestion;
  final List<String> incidentes;

  @override
  List<Object?> get props => [
        tipoSuperficie,
        factorCalzada,
        elevacionMetros,
        pendientePorcentaje,
        nivelCongestion,
        incidentes,
      ];
}

class RouteOrder extends Equatable {
  const RouteOrder({
    required this.pedidoId,
    required this.orden,
    this.horaEstimada,
    this.direccion,
    this.gpsLat,
    this.gpsLon,
    this.peso,
    this.ventanaInicio,
    this.ventanaFin,
    this.cumplioVentana = true,
    this.contextoVial = const RoadContext(),
  });

  final String pedidoId;
  final int orden;
  final String? horaEstimada;
  final String? direccion;
  final double? gpsLat;
  final double? gpsLon;
  final double? peso;
  final String? ventanaInicio;
  final String? ventanaFin;
  final bool? cumplioVentana;
  final RoadContext contextoVial;

  @override
  List<Object?> get props => [
        pedidoId,
        orden,
        horaEstimada,
        direccion,
        gpsLat,
        gpsLon,
        peso,
        ventanaInicio,
        ventanaFin,
        cumplioVentana,
        contextoVial,
      ];
}

class DeliveryRoute extends Equatable {
  const DeliveryRoute({
    required this.id,
    required this.fecha,
    this.conductorId,
    this.conductorNombre,
    this.vehiculoId,
    this.placa,
    this.distanciaKm = 0,
    this.co2Kg = 0,
    this.combustibleL = 0,
    this.estado = 'PLANIFICADA',
    this.pedidos = const [],
    this.encodedPolyline,
  });

  final String id;
  final String fecha;
  final String? conductorId;
  final String? conductorNombre;
  final String? vehiculoId;
  final String? placa;
  final double distanciaKm;
  final double co2Kg;
  final double combustibleL;
  final String estado;
  final List<RouteOrder> pedidos;
  final String? encodedPolyline;

  @override
  List<Object?> get props => [
        id,
        fecha,
        conductorId,
        conductorNombre,
        vehiculoId,
        placa,
        distanciaKm,
        co2Kg,
        combustibleL,
        estado,
        pedidos,
        encodedPolyline,
      ];
}
