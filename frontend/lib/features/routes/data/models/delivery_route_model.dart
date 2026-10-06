import 'package:equatable/equatable.dart';
import 'package:pathseek/features/routes/domain/entities/delivery_route.dart';

class RouteOrderModel extends Equatable {
  const RouteOrderModel({
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

  factory RouteOrderModel.fromJson(Map<String, dynamic> json) {
    return RouteOrderModel(
      pedidoId: (json['pedido_id'] ?? '').toString(),
      orden: _toInt(json['orden']),
      horaEstimada: _toStringOrNull(json['hora_estimada']),
      direccion: _toStringOrNull(json['direccion']),
      gpsLat: _toDoubleOrNull(json['gps_lat']),
      gpsLon: _toDoubleOrNull(json['gps_lon']),
      peso: _toDoubleOrNull(json['peso']),
      ventanaInicio: _toStringOrNull(json['ventana_inicio']),
      ventanaFin: _toStringOrNull(json['ventana_fin']),
    );
  }

  RouteOrder toEntity() => RouteOrder(
        pedidoId: pedidoId,
        orden: orden,
        horaEstimada: horaEstimada,
        direccion: direccion,
        gpsLat: gpsLat,
        gpsLon: gpsLon,
        peso: peso,
        ventanaInicio: ventanaInicio,
        ventanaFin: ventanaFin,
      );

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

class DeliveryRouteModel extends Equatable {
  const DeliveryRouteModel({
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
  final List<RouteOrderModel> pedidos;

  factory DeliveryRouteModel.fromJson(Map<String, dynamic> json) {
    final pedidosJson = json['pedidos'];
    final pedidos = pedidosJson is List
        ? pedidosJson
            .map((p) => RouteOrderModel.fromJson(p as Map<String, dynamic>))
            .toList()
        : <RouteOrderModel>[];

    return DeliveryRouteModel(
      id: (json['ruta_id'] ?? '').toString(),
      fecha: _toString(json['fecha']),
      conductorId: _toStringOrNull(json['conductor_id']),
      conductorNombre: _toStringOrNull(json['conductor_nombre']),
      vehiculoId: _toStringOrNull(json['vehiculo_id']),
      placa: _toStringOrNull(json['placa']),
      distanciaKm: _toDouble(json['distancia_km']),
      co2Kg: _toDouble(json['co2_kg']),
      combustibleL: _toDouble(json['combustible_l']),
      estado: (json['estado'] ?? 'PLANIFICADA').toString(),
      pedidos: pedidos,
    );
  }

  DeliveryRoute toEntity() => DeliveryRoute(
        id: id,
        fecha: fecha,
        conductorId: conductorId,
        conductorNombre: conductorNombre,
        vehiculoId: vehiculoId,
        placa: placa,
        distanciaKm: distanciaKm,
        co2Kg: co2Kg,
        combustibleL: combustibleL,
        estado: estado,
        pedidos: pedidos.map((p) => p.toEntity()).toList(),
      );

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

int _toInt(dynamic value) => value is num ? value.toInt() : int.tryParse('$value') ?? 0;

double _toDouble(dynamic value) =>
    value is num ? value.toDouble() : double.tryParse('$value') ?? 0;

String _toString(dynamic value) => value?.toString() ?? '';

String? _toStringOrNull(dynamic value) => value?.toString();

double? _toDoubleOrNull(dynamic value) =>
    value is num ? value.toDouble() : double.tryParse('$value');
