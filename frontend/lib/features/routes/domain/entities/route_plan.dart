import 'package:equatable/equatable.dart';

class RouteStop extends Equatable {
  const RouteStop({
    required this.pedidoId,
    required this.orden,
    required this.llegadaEstimada,
    required this.distanciaTramoKm,
    this.gpsLat = 0,
    this.gpsLon = 0,
    this.clienteId,
    this.direccion,
    this.ventanaInicio,
    this.ventanaFin,
    this.peso = 0,
    this.prioridad = '',
  });

  final String pedidoId;
  final int orden;
  final String llegadaEstimada;
  final double distanciaTramoKm;
  final double gpsLat;
  final double gpsLon;
  final String? clienteId;
  final String? direccion;
  final String? ventanaInicio;
  final String? ventanaFin;
  final double peso;
  final String prioridad;

  /// Nivel de congestión MVP por hora de llegada (hora punta Huancayo).
  /// Sin API de tráfico en Sprint 2: heurística documentada.
  String get congestion {
    final hour = int.tryParse(llegadaEstimada.split(':').firstOrNull ?? '') ?? -1;
    if ((hour >= 7 && hour < 9) || (hour >= 12 && hour < 14) || (hour >= 18 && hour < 20)) {
      return 'alta';
    }
    if ((hour >= 6 && hour < 10) || (hour >= 11 && hour < 15) || (hour >= 17 && hour < 21)) {
      return 'media';
    }
    return 'baja';
  }

  @override
  List<Object?> get props => [
        pedidoId,
        orden,
        llegadaEstimada,
        distanciaTramoKm,
        gpsLat,
        gpsLon,
        clienteId,
        direccion,
        ventanaInicio,
        ventanaFin,
        peso,
        prioridad,
      ];
}

class VehicleRoute extends Equatable {
  const VehicleRoute({
    required this.vehiculoId,
    required this.placa,
    required this.distanciaKm,
    required this.combustibleL,
    required this.co2Kg,
    required this.paradas,
  });

  final String vehiculoId;
  final String placa;
  final double distanciaKm;
  final double combustibleL;
  final double co2Kg;
  final List<RouteStop> paradas;

  @override
  List<Object?> get props =>
      [vehiculoId, placa, distanciaKm, combustibleL, co2Kg, paradas];
}

class UnassignedOrder extends Equatable {
  const UnassignedOrder({
    required this.pedidoId,
    required this.motivo,
    this.clienteId,
    this.direccion,
    this.ventanaInicio,
    this.ventanaFin,
    this.sugerencia,
  });

  final String pedidoId;
  final String motivo;
  final String? clienteId;
  final String? direccion;
  final String? ventanaInicio;
  final String? ventanaFin;
  final String? sugerencia;

  static const Map<String, String> motivosLegibles = {
    'VENTANA_INALCANZABLE': 'Ventana inalcanzable',
    'CAPACIDAD': 'Sin capacidad disponible',
    'RESTRICCION_PLACA': 'Vehículos con restricción de placa',
  };

  String get motivoLegible => motivosLegibles[motivo] ?? motivo;

  @override
  List<Object?> get props => [
        pedidoId,
        motivo,
        clienteId,
        direccion,
        ventanaInicio,
        ventanaFin,
        sugerencia,
      ];
}

class RouteMetrics extends Equatable {
  const RouteMetrics({
    required this.distanciaKm,
    required this.combustibleL,
    required this.co2Kg,
    required this.cumplimientoPct,
    required this.totalAsignados,
    required this.totalNoAsignados,
    required this.penalizacion,
  });

  final double distanciaKm;
  final double combustibleL;
  final double co2Kg;
  final double cumplimientoPct;
  final int totalAsignados;
  final int totalNoAsignados;
  final double penalizacion;

  @override
  List<Object?> get props => [
        distanciaKm,
        combustibleL,
        co2Kg,
        cumplimientoPct,
        totalAsignados,
        totalNoAsignados,
        penalizacion,
      ];
}

class RoutePlan extends Equatable {
  const RoutePlan({
    required this.rutaId,
    required this.fechaOperacion,
    required this.duracionMs,
    required this.metricas,
    required this.rutas,
    required this.noAsignados,
    this.depositoLat = 0,
    this.depositoLon = 0,
  });

  final String rutaId;
  final String fechaOperacion;
  final int duracionMs;
  final RouteMetrics metricas;
  final List<VehicleRoute> rutas;
  final List<UnassignedOrder> noAsignados;
  final double depositoLat;
  final double depositoLon;

  @override
  List<Object?> get props => [
        rutaId,
        fechaOperacion,
        duracionMs,
        metricas,
        rutas,
        noAsignados,
        depositoLat,
        depositoLon,
      ];
}

class RoutePerformance extends Equatable {
  const RoutePerformance({
    required this.totalSolicitudes,
    required this.p50Ms,
    required this.p95Ms,
    required this.mediaMs,
    required this.minMs,
    required this.maxMs,
    required this.ultimaMs,
    required this.slaCumplido,
  });

  final int totalSolicitudes;
  final int p50Ms;
  final int p95Ms;
  final double mediaMs;
  final int minMs;
  final int maxMs;
  final int ultimaMs;
  final bool slaCumplido;

  @override
  List<Object?> get props => [
        totalSolicitudes,
        p50Ms,
        p95Ms,
        mediaMs,
        minMs,
        maxMs,
        ultimaMs,
        slaCumplido,
      ];
}

class RouteConfirmResult extends Equatable {
  const RouteConfirmResult({required this.confirmados, required this.omitidos});

  final int confirmados;
  final int omitidos;

  @override
  List<Object?> get props => [confirmados, omitidos];
}
