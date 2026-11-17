import 'package:equatable/equatable.dart';

class DashboardSummary extends Equatable {
  const DashboardSummary({
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

  bool get hasData =>
      totalVehiculos > 0 ||
      conductoresDisponibles > 0 ||
      pedidosPendientes > 0 ||
      pedidosEnRuta > 0 ||
      pedidosEntregados > 0 ||
      pedidosCancelados > 0 ||
      rutasPlanificadas > 0 ||
      co2TotalKg > 0 ||
      combustibleTotalL > 0;

  int get pedidosTotales =>
      pedidosPendientes + pedidosEnRuta + pedidosEntregados + pedidosCancelados;

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

class ExecutedRoutesMetrics extends Equatable {
  const ExecutedRoutesMetrics({
    required this.completedRoutes,
    required this.distanceKm,
    required this.co2Kg,
    required this.fuelLiters,
    this.onTimePercent,
    this.dailyComparison,
  });

  final int completedRoutes;
  final double distanceKm;
  final double co2Kg;
  final double fuelLiters;
  final double? onTimePercent;
  final DailyFuelComparison? dailyComparison;

  @override
  List<Object?> get props => [
    completedRoutes,
    distanceKm,
    co2Kg,
    fuelLiters,
    onTimePercent,
    dailyComparison,
  ];
}

class DailyFuelComparison extends Equatable {
  const DailyFuelComparison({
    required this.sequentialLiters,
    required this.savedLiters,
    required this.savedPercent,
    this.savedSoles,
  });

  final double sequentialLiters;
  final double savedLiters;
  final double savedPercent;
  final double? savedSoles;

  @override
  List<Object?> get props => [
    sequentialLiters,
    savedLiters,
    savedPercent,
    savedSoles,
  ];
}
