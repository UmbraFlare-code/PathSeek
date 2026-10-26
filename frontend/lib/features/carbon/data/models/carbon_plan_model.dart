import 'package:equatable/equatable.dart';
import 'package:pathseek/features/carbon/domain/entities/carbon_plan.dart';

class CarbonPlanModel extends Equatable {
  const CarbonPlanModel({
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

  factory CarbonPlanModel.fromJson(Map<String, dynamic> json) {
    final proyectosJson = json['proyectos'];
    final proyectos = proyectosJson is List
        ? proyectosJson
              .whereType<Map>()
              .map(
                (item) => CarbonProjectOption(
                  proyectoId: (item['proyecto_id'] ?? '').toString(),
                  nombre: (item['nombre'] ?? '').toString(),
                  tipo: (item['tipo'] ?? '').toString(),
                  costoTonelada: _toDouble(item['costo_tonelada']),
                  costeEstimado: _toDouble(item['coste_compensacion_estimado']),
                  descripcion: item['descripcion']?.toString(),
                ),
              )
              .toList()
        : <CarbonProjectOption>[];
    return CarbonPlanModel(
      emisionesAnualesKg: _toDouble(json['emisiones_anuales_kg']),
      emisionesAnualesT: _toDouble(json['emisiones_anuales_t']),
      arbolesEquivalentes: _toInt(json['arboles_equivalentes']),
      periodoDesde: (json['periodo_desde'] ?? '').toString(),
      periodoHasta: (json['periodo_hasta'] ?? '').toString(),
      proyectos: proyectos,
    );
  }

  CarbonPlan toEntity() => CarbonPlan(
    emisionesAnualesKg: emisionesAnualesKg,
    emisionesAnualesT: emisionesAnualesT,
    arbolesEquivalentes: arbolesEquivalentes,
    periodoDesde: periodoDesde,
    periodoHasta: periodoHasta,
    proyectos: proyectos,
  );

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

int _toInt(dynamic value) =>
    value is num ? value.toInt() : int.tryParse('$value') ?? 0;

double _toDouble(dynamic value) =>
    value is num ? value.toDouble() : double.tryParse('$value') ?? 0;
