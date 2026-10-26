import 'package:equatable/equatable.dart';

class CarbonProjectOption extends Equatable {
  const CarbonProjectOption({
    required this.proyectoId,
    required this.nombre,
    required this.tipo,
    required this.costoTonelada,
    required this.costeEstimado,
    this.descripcion,
  });

  final String proyectoId;
  final String nombre;
  final String tipo;
  final double costoTonelada;
  final double costeEstimado;
  final String? descripcion;

  @override
  List<Object?> get props => [
    proyectoId,
    nombre,
    tipo,
    costoTonelada,
    costeEstimado,
    descripcion,
  ];
}

class CarbonPlan extends Equatable {
  const CarbonPlan({
    required this.emisionesAnualesKg,
    required this.emisionesAnualesT,
    required this.arbolesEquivalentes,
    required this.periodoDesde,
    required this.periodoHasta,
    required this.proyectos,
  });

  final double emisionesAnualesKg;
  final double emisionesAnualesT;
  final int arbolesEquivalentes;
  final String periodoDesde;
  final String periodoHasta;
  final List<CarbonProjectOption> proyectos;

  @override
  List<Object?> get props => [
    emisionesAnualesKg,
    emisionesAnualesT,
    arbolesEquivalentes,
    periodoDesde,
    periodoHasta,
    proyectos,
  ];
}
