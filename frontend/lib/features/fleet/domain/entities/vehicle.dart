import 'package:equatable/equatable.dart';

class Vehicle extends Equatable {
  const Vehicle({
    required this.id,
    required this.placa,
    required this.tipo,
    required this.capacidadKg,
    required this.capacidadM3,
    required this.consumoKmL,
    required this.factorEmision,
    required this.anio,
    this.restriccionPlacaDigito,
  });

  final String id;
  final String placa;
  final String tipo;
  final double capacidadKg;
  final double capacidadM3;
  final double consumoKmL;
  final double factorEmision;
  final int anio;
  final int? restriccionPlacaDigito;

  bool capacidadSuficiente({required double peso, required double volumen}) {
    return peso <= capacidadKg && volumen <= capacidadM3;
  }

  @override
  List<Object?> get props => [
        id,
        placa,
        tipo,
        capacidadKg,
        capacidadM3,
        consumoKmL,
        factorEmision,
        anio,
        restriccionPlacaDigito,
      ];
}
