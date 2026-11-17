import 'package:equatable/equatable.dart';
import 'package:pathseek/features/dashboard/domain/entities/dashboard_summary.dart';

class DashboardSummaryModel extends Equatable {
  const DashboardSummaryModel({
    this.totalVehiculos = 0,
    this.conductoresDisponibles = 0,
    this.pedidosPendientes = 0,
    this.pedidosEnRuta = 0,
    this.pedidosEntregados = 0,
    this.pedidosCancelados = 0,
    this.rutasPlanificadas = 0,
    this.co2TotalKg = 0,
    this.combustibleTotalL = 0,
    this.executedRoutes,
  });

  final int totalVehiculos;
  final int conductoresDisponibles;
  final int pedidosPendientes;
  final int pedidosEnRuta;
  final int pedidosEntregados;
  final int pedidosCancelados;
  final int rutasPlanificadas;
  final double co2TotalKg;
  final double combustibleTotalL;
  final ExecutedRoutesMetrics? executedRoutes;

  factory DashboardSummaryModel.fromJson(Map<String, dynamic> json) {
    return DashboardSummaryModel(
      totalVehiculos: _toInt(json['total_vehiculos']),
      conductoresDisponibles: _toInt(json['conductores_disponibles']),
      pedidosPendientes: _toInt(json['pedidos_pendientes']),
      pedidosEnRuta: _toInt(json['pedidos_en_ruta']),
      pedidosEntregados: _toInt(json['pedidos_entregados']),
      pedidosCancelados: _toInt(json['pedidos_cancelados']),
      rutasPlanificadas: _toInt(json['rutas_planificadas']),
      co2TotalKg: _toDouble(json['co2_total_kg']),
      combustibleTotalL: _toDouble(json['combustible_total_l']),
      executedRoutes: _readExecutedRoutes(json['rutas_ejecutadas']),
    );
  }

  DashboardSummary toEntity() => DashboardSummary(
    totalVehiculos: totalVehiculos,
    conductoresDisponibles: conductoresDisponibles,
    pedidosPendientes: pedidosPendientes,
    pedidosEnRuta: pedidosEnRuta,
    pedidosEntregados: pedidosEntregados,
    pedidosCancelados: pedidosCancelados,
    rutasPlanificadas: rutasPlanificadas,
    co2TotalKg: co2TotalKg,
    combustibleTotalL: combustibleTotalL,
    executedRoutes: executedRoutes,
  );

  static ExecutedRoutesMetrics? _readExecutedRoutes(Object? value) {
    if (value is! Map<String, dynamic>) return null;
    final comparison = value['comparacion_hoy'];
    return ExecutedRoutesMetrics(
      completedRoutes: _toInt(value['rutas_completadas']),
      distanceKm: _toDouble(value['distancia_km']),
      co2Kg: _toDouble(value['co2_kg']),
      fuelLiters: _toDouble(value['combustible_l']),
      onTimePercent: _toNullableDouble(value['cumplimiento_ventanas_pct']),
      dailyComparison: comparison is Map<String, dynamic>
          ? DailyFuelComparison(
              sequentialLiters: _toDouble(
                comparison['combustible_secuencial_l'],
              ),
              savedLiters: _toDouble(comparison['ahorro_l']),
              savedPercent: _toDouble(comparison['ahorro_pct']),
              savedSoles: _toNullableDouble(comparison['ahorro_pen']),
            )
          : null,
    );
  }

  static int _toInt(dynamic value) =>
      value is num ? value.toInt() : int.tryParse('$value') ?? 0;

  static double? _toNullableDouble(Object? value) =>
      value is num ? value.toDouble() : double.tryParse('$value');

  static double _toDouble(Object? value) => _toNullableDouble(value) ?? 0;

  @override
  List<Object?> get props => [
    totalVehiculos,
    conductoresDisponibles,
    pedidosPendientes,
    pedidosEnRuta,
    pedidosEntregados,
    pedidosCancelados,
    rutasPlanificadas,
    co2TotalKg,
    combustibleTotalL,
    executedRoutes,
  ];
}
