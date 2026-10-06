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
      ];
}
