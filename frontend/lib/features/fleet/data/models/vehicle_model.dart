import 'package:equatable/equatable.dart';
import 'package:pathseek/features/fleet/domain/entities/vehicle.dart';

class VehicleModel extends Equatable {
  const VehicleModel({
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

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: (json['vehiculo_id'] ?? json['id']).toString(),
      placa: (json['placa'] ?? '').toString(),
      tipo: (json['tipo'] ?? '').toString(),
      capacidadKg: _toDouble(json['capacidad_kg']),
      capacidadM3: _toDouble(json['capacidad_m3']),
      consumoKmL: _toDouble(json['consumo_km_l']),
      factorEmision: _toDouble(json['factor_emision']),
      anio: _toInt(json['anio']),
      restriccionPlacaDigito: json['restriccion_placa_digito'] == null
          ? null
          : _toInt(json['restriccion_placa_digito']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'vehiculo_id': id,
      'placa': placa,
      'tipo': tipo,
      'capacidad_kg': capacidadKg,
      'capacidad_m3': capacidadM3,
      'consumo_km_l': consumoKmL,
      'factor_emision': factorEmision,
      'anio': anio,
      if (restriccionPlacaDigito != null)
        'restriccion_placa_digito': restriccionPlacaDigito,
    };
  }

  Vehicle toEntity() => Vehicle(
        id: id,
        placa: placa,
        tipo: tipo,
        capacidadKg: capacidadKg,
        capacidadM3: capacidadM3,
        consumoKmL: consumoKmL,
        factorEmision: factorEmision,
        anio: anio,
        restriccionPlacaDigito: restriccionPlacaDigito,
      );

  factory VehicleModel.fromEntity(Vehicle vehicle) => VehicleModel(
        id: vehicle.id,
        placa: vehicle.placa,
        tipo: vehicle.tipo,
        capacidadKg: vehicle.capacidadKg,
        capacidadM3: vehicle.capacidadM3,
        consumoKmL: vehicle.consumoKmL,
        factorEmision: vehicle.factorEmision,
        anio: vehicle.anio,
        restriccionPlacaDigito: vehicle.restriccionPlacaDigito,
      );

  static double _toDouble(dynamic value) =>
      value is num ? value.toDouble() : double.parse(value.toString());

  static int _toInt(dynamic value) =>
      value is num ? value.toInt() : int.parse(value.toString());

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
