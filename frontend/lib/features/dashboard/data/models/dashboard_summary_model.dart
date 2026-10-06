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
      );

  static int _toInt(dynamic value) =>
      value is num ? value.toInt() : int.tryParse('$value') ?? 0;

  static double _toDouble(dynamic value) =>
      value is num ? value.toDouble() : double.tryParse('$value') ?? 0;

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
      ];
}
