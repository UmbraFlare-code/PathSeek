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
    this.cumplioVentana = true,
    this.tipoSuperficie = 'ASFALTO',
    this.elevacionMetros = 3260,
    this.pendientePorcentaje = 2.5,
    this.nivelCongestion = 'FLUIDO',
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
  final String tipoSuperficie;
  final int elevacionMetros;
  final double pendientePorcentaje;
  final String nivelCongestion;

  factory RouteOrderModel.fromJson(Map<String, dynamic> json) {
    final ctx = json['contexto_vial'] ?? json['contextoVial'];
    Map<String, dynamic>? ctxMap = ctx is Map<String, dynamic> ? ctx : null;

    return RouteOrderModel(
      pedidoId: (json['pedido_id'] ?? json['pedidoId'] ?? '').toString(),
      orden: _toInt(json['orden']),
      horaEstimada: _toStringOrNull(json['hora_estimada'] ?? json['horaEstimada']),
      direccion: _toStringOrNull(json['direccion']),
      gpsLat: _toDoubleOrNull(json['gps_lat'] ?? json['gpsLat']),
      gpsLon: _toDoubleOrNull(json['gps_lon'] ?? json['gpsLon']),
      peso: _toDoubleOrNull(json['peso']),
      ventanaInicio: _toStringOrNull(json['ventana_inicio'] ?? json['ventanaInicio']),
      ventanaFin: _toStringOrNull(json['ventana_fin'] ?? json['ventanaFin']),
      cumplioVentana: json['cumplio_ventana'] ?? json['cumplioVentana'] ?? true,
      tipoSuperficie: ctxMap != null
          ? _toString(ctxMap['tipo_superficie'] ?? ctxMap['tipoSuperficie'] ?? 'ASFALTO')
          : 'ASFALTO',
      elevacionMetros: ctxMap != null
          ? _toInt(ctxMap['elevacion_metros'] ?? ctxMap['elevacionMetros'] ?? 3260)
          : 3260,
      pendientePorcentaje: ctxMap != null
          ? _toDouble(ctxMap['pendiente_media_porcentaje'] ?? ctxMap['pendienteMediaPorcentaje'] ?? 2.5)
          : 2.5,
      nivelCongestion: ctxMap != null
          ? _toString(ctxMap['nivel_congestion'] ?? ctxMap['nivelCongestion'] ?? 'FLUIDO')
          : 'FLUIDO',
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
        cumplioVentana: cumplioVentana,
        contextoVial: RoadContext(
          tipoSuperficie: tipoSuperficie,
          elevacionMetros: elevacionMetros,
          pendientePorcentaje: pendientePorcentaje,
          nivelCongestion: nivelCongestion,
        ),
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
        cumplioVentana,
        tipoSuperficie,
        elevacionMetros,
        pendientePorcentaje,
        nivelCongestion,
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
  final List<RouteOrderModel> pedidos;
  final String? encodedPolyline;

  factory DeliveryRouteModel.fromJson(Map<String, dynamic> json) {
    final pedidosJson = json['pedidos'];
    final pedidos = pedidosJson is List
        ? pedidosJson
            .map((p) => RouteOrderModel.fromJson(p as Map<String, dynamic>))
            .toList()
        : <RouteOrderModel>[];

    return DeliveryRouteModel(
      id: (json['ruta_id'] ?? json['id'] ?? '').toString(),
      fecha: _toString(json['fecha']),
      conductorId: _toStringOrNull(json['conductor_id'] ?? json['conductorId']),
      conductorNombre: _toStringOrNull(json['conductor_nombre'] ?? json['conductorNombre']),
      vehiculoId: _toStringOrNull(json['vehiculo_id'] ?? json['vehiculoId']),
      placa: _toStringOrNull(json['placa']),
      distanciaKm: _toDouble(json['distancia_km'] ?? json['distanciaKm']),
      co2Kg: _toDouble(json['co2_kg'] ?? json['co2Kg']),
      combustibleL: _toDouble(json['combustible_l'] ?? json['combustibleL']),
      estado: (json['estado'] ?? 'PLANIFICADA').toString(),
      pedidos: pedidos,
      encodedPolyline: _toStringOrNull(json['encoded_polyline'] ?? json['encodedPolyline']),
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
        encodedPolyline: encodedPolyline,
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
        encodedPolyline,
      ];
}

int _toInt(dynamic value) => value is num ? value.toInt() : int.tryParse('$value') ?? 0;

double _toDouble(dynamic value) =>
    value is num ? value.toDouble() : double.tryParse('$value') ?? 0;

String _toString(dynamic value) => value?.toString() ?? '';

String? _toStringOrNull(dynamic value) => value?.toString();

double? _toDoubleOrNull(dynamic value) =>
    value is num ? value.toDouble() : double.tryParse('$value');
