import 'package:equatable/equatable.dart';

class DeliveryUpdate extends Equatable {
  const DeliveryUpdate({
    required this.pedidoEstado,
    required this.rutaEstado,
    this.cumplioVentana,
    this.yaRegistrado = false,
  });

  final String? pedidoEstado;
  final String rutaEstado;
  final bool? cumplioVentana;
  final bool yaRegistrado;

  @override
  List<Object?> get props => [pedidoEstado, rutaEstado, cumplioVentana, yaRegistrado];
}

class ReoptimizationResult extends Equatable {
  const ReoptimizationResult({
    required this.rutasReoptimizadas,
    required this.rutasSinCambios,
    required this.pedidosNoAsignados,
    required this.notificacionesGeneradas,
    required this.tiempoCalculoMs,
  });

  final int rutasReoptimizadas;
  final int rutasSinCambios;
  final int pedidosNoAsignados;
  final int notificacionesGeneradas;
  final int tiempoCalculoMs;

  @override
  List<Object?> get props => [
    rutasReoptimizadas,
    rutasSinCambios,
    pedidosNoAsignados,
    notificacionesGeneradas,
    tiempoCalculoMs,
  ];
}
