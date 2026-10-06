import 'package:equatable/equatable.dart';

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
      ];
}
