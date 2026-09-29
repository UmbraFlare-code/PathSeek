import 'package:flutter_test/flutter_test.dart';
import 'package:pathseek/features/fleet/data/models/vehicle_model.dart';
import 'package:pathseek/features/fleet/domain/entities/vehicle.dart';

void main() {
  group('VehicleModel', () {
    const json = {
      'vehiculo_id': 'v1',
      'placa': 'ABC123',
      'tipo': 'CAMIONETA',
      'capacidad_kg': 500,
      'capacidad_m3': 3,
      'consumo_km_l': 12.5,
      'factor_emision': 0.25,
      'anio': 2020,
    };

    test('fromJson parses all fields', () {
      final model = VehicleModel.fromJson(json);

      expect(model.id, 'v1');
      expect(model.placa, 'ABC123');
      expect(model.tipo, 'CAMIONETA');
      expect(model.capacidadKg, 500);
      expect(model.capacidadM3, 3);
      expect(model.consumoKmL, 12.5);
      expect(model.factorEmision, 0.25);
      expect(model.anio, 2020);
    });

    test('fromJson handles numeric strings', () {
      final model = VehicleModel.fromJson({
        ...json,
        'capacidad_kg': '500',
        'anio': '2020',
      });

      expect(model.capacidadKg, 500);
      expect(model.anio, 2020);
    });

    test('toJson maps to snake_case api contract', () {
      final model = VehicleModel.fromEntity(
        const Vehicle(
          id: '',
          placa: 'ABC123',
          tipo: 'CAMIONETA',
          capacidadKg: 500,
          capacidadM3: 3,
          consumoKmL: 12.5,
          factorEmision: 0.25,
          anio: 2020,
        ),
      );

      final map = model.toJson();
      expect(map['placa'], 'ABC123');
      expect(map['capacidad_kg'], 500);
      expect(map['consumo_km_l'], 12.5);
      expect(map.containsKey('vehiculo_id'), isFalse);
    });

    test('toEntity maps correctly', () {
      final entity = VehicleModel.fromJson(json).toEntity();

      expect(entity, isA<Vehicle>());
      expect(entity.id, 'v1');
      expect(entity.capacidadKg, 500);
    });

    test('fromJson parses optional plate restriction digit', () {
      final model = VehicleModel.fromJson({
        ...json,
        'restriccion_placa_digito': 3,
      });

      expect(model.restriccionPlacaDigito, 3);
    });

    test('toJson includes plate restriction when present', () {
      final model = VehicleModel.fromEntity(
        const Vehicle(
          id: '',
          placa: 'ABC123',
          tipo: 'CAMIONETA',
          capacidadKg: 500,
          capacidadM3: 3,
          consumoKmL: 12.5,
          factorEmision: 0.25,
          anio: 2020,
          restriccionPlacaDigito: 3,
        ),
      );

      expect(model.toJson()['restriccion_placa_digito'], 3);
    });

    test('entity capacity validation', () {
      const vehicle = Vehicle(
        id: 'v1',
        placa: 'ABC123',
        tipo: 'CAMIONETA',
        capacidadKg: 500,
        capacidadM3: 3,
        consumoKmL: 12,
        factorEmision: 0.25,
        anio: 2020,
      );

      expect(
        vehicle.capacidadSuficiente(peso: 400, volumen: 2),
        isTrue,
      );
      expect(
        vehicle.capacidadSuficiente(peso: 600, volumen: 2),
        isFalse,
      );
      expect(
        vehicle.capacidadSuficiente(peso: 400, volumen: 4),
        isFalse,
      );
    });
  });
}
