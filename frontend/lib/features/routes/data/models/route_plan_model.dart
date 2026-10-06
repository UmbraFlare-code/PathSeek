import 'package:pathseek/features/routes/domain/entities/route_plan.dart';

class RoutePlanModel extends RoutePlan {
  const RoutePlanModel({
    required super.rutaId,
    required super.fechaOperacion,
    required super.duracionMs,
    required super.metricas,
    required super.rutas,
    required super.noAsignados,
    super.depositoLat,
    super.depositoLon,
  });

  factory RoutePlanModel.fromJson(Map<String, dynamic> json) {
    final m = json['metricas'] as Map<String, dynamic>? ?? {};
    final d = json['deposito'] as Map<String, dynamic>? ?? {};
    final rutas = (json['rutas'] as List? ?? [])
        .map((e) => _vehicleRoute(e as Map<String, dynamic>))
        .toList();
    final noAsignados = (json['no_asignados'] as List? ?? [])
        .map((e) => UnassignedOrder(
              pedidoId: (e['pedido_id'] ?? '').toString(),
              motivo: (e['motivo'] ?? '').toString(),
              clienteId: e['cliente_id']?.toString(),
              direccion: e['direccion']?.toString(),
              ventanaInicio: e['ventana_inicio']?.toString(),
              ventanaFin: e['ventana_fin']?.toString(),
              sugerencia: e['sugerencia']?.toString(),
            ))
        .toList();
    return RoutePlanModel(
      rutaId: (json['ruta_id'] ?? '').toString(),
      fechaOperacion: (json['fecha_operacion'] ?? '').toString(),
      duracionMs: _toInt(json['duracion_ms']),
      metricas: RouteMetrics(
        distanciaKm: _toDouble(m['distancia_km']),
        combustibleL: _toDouble(m['combustible_l']),
        co2Kg: _toDouble(m['co2_kg']),
        cumplimientoPct: _toDouble(m['cumplimiento_pct']),
        totalAsignados: _toInt(m['total_asignados']),
        totalNoAsignados: _toInt(m['total_no_asignados']),
        penalizacion: _toDouble(m['penalizacion']),
      ),
      rutas: rutas,
      noAsignados: noAsignados,
      depositoLat: _toDouble(d['latitud']),
      depositoLon: _toDouble(d['longitud']),
    );
  }

  static VehicleRoute _vehicleRoute(Map<String, dynamic> json) {
    final paradas = (json['paradas'] as List? ?? [])
        .map((e) => RouteStop(
              pedidoId: (e['pedido_id'] ?? '').toString(),
              orden: _toInt(e['orden']),
              llegadaEstimada: (e['llegada_estimada'] ?? '').toString(),
              distanciaTramoKm: _toDouble(e['distancia_tramo_km']),
              gpsLat: _toDouble(e['gps_lat']),
              gpsLon: _toDouble(e['gps_lon']),
              clienteId: e['cliente_id']?.toString(),
              direccion: e['direccion']?.toString(),
              ventanaInicio: e['ventana_inicio']?.toString(),
              ventanaFin: e['ventana_fin']?.toString(),
              peso: _toDouble(e['peso']),
              prioridad: (e['prioridad'] ?? '').toString(),
            ))
        .toList();
    return VehicleRoute(
      vehiculoId: (json['vehiculo_id'] ?? '').toString(),
      placa: (json['placa'] ?? '').toString(),
      distanciaKm: _toDouble(json['distancia_km']),
      combustibleL: _toDouble(json['combustible_l']),
      co2Kg: _toDouble(json['co2_kg']),
      paradas: paradas,
    );
  }

  static double _toDouble(dynamic v) =>
      v == null ? 0 : (v is num ? v.toDouble() : double.tryParse('$v') ?? 0);

  static int _toInt(dynamic v) =>
      v == null ? 0 : (v is num ? v.toInt() : int.tryParse('$v') ?? 0);
}

class RoutePerformanceModel extends RoutePerformance {
  const RoutePerformanceModel({
    required super.totalSolicitudes,
    required super.p50Ms,
    required super.p95Ms,
    required super.mediaMs,
    required super.minMs,
    required super.maxMs,
    required super.ultimaMs,
    required super.slaCumplido,
  });

  factory RoutePerformanceModel.fromJson(Map<String, dynamic> json) {
    return RoutePerformanceModel(
      totalSolicitudes: _toInt(json['total_solicitudes']),
      p50Ms: _toInt(json['p50_ms']),
      p95Ms: _toInt(json['p95_ms']),
      mediaMs: _toDouble(json['media_ms']),
      minMs: _toInt(json['min_ms']),
      maxMs: _toInt(json['max_ms']),
      ultimaMs: _toInt(json['ultima_ms']),
      slaCumplido: json['sla_45s_cumplido'] == true,
    );
  }

  static double _toDouble(dynamic v) =>
      v == null ? 0 : (v is num ? v.toDouble() : double.tryParse('$v') ?? 0);

  static int _toInt(dynamic v) =>
      v == null ? 0 : (v is num ? v.toInt() : int.tryParse('$v') ?? 0);
}
