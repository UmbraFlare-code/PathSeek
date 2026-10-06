import 'package:flutter_test/flutter_test.dart';
import 'package:pathseek/features/fleet/domain/entities/vehicle.dart';
import 'package:pathseek/features/fleet/presentation/vehicle_filters.dart';

Vehicle _vehicle(String id, String placa, String tipo, int anio, double cap) =>
    Vehicle(
      id: id,
      placa: placa,
      tipo: tipo,
      capacidadKg: cap,
      capacidadM3: 1,
      consumoKmL: 10,
      factorEmision: 0.2,
      anio: anio,
    );

void main() {
  final vehicles = [
    _vehicle('1', 'ABC123', 'CAMIONETA', 2022, 1200),
    _vehicle('2', 'W2B-202', 'FURGON', 2021, 2500),
    _vehicle('3', 'MOTO-01', 'MOTO', 2023, 150),
  ];

  group('filterVehicles', () {
    test('empty query returns all', () {
      expect(filterVehicles(vehicles, ''), vehicles);
      expect(filterVehicles(vehicles, '   '), vehicles);
    });

    test('searches by placa (case-insensitive)', () {
      expect(filterVehicles(vehicles, 'abc').map((v) => v.id), ['1']);
      expect(filterVehicles(vehicles, 'w2b').map((v) => v.id), ['2']);
    });

    test('searches by tipo', () {
      expect(filterVehicles(vehicles, 'moto').map((v) => v.id), ['3']);
      expect(filterVehicles(vehicles, 'furgon').map((v) => v.id), ['2']);
    });

    test('no matches returns empty', () {
      expect(filterVehicles(vehicles, 'zzz'), isEmpty);
    });
  });

  group('sortVehicles', () {
    test('sorts by placa ascending', () {
      final sorted = sortVehicles(vehicles, VehicleSort.placa);
      expect(sorted.map((v) => v.placa).toList(),
          ['ABC123', 'MOTO-01', 'W2B-202']);
    });

    test('sorts by anio descending', () {
      final sorted = sortVehicles(vehicles, VehicleSort.anio);
      expect(sorted.map((v) => v.anio).toList(), [2023, 2022, 2021]);
    });

    test('sorts by capacidad descending', () {
      final sorted = sortVehicles(vehicles, VehicleSort.capacidad);
      expect(sorted.map((v) => v.capacidadKg).toList(), [2500, 1200, 150]);
    });

    test('does not mutate original list', () {
      sortVehicles(vehicles, VehicleSort.anio);
      expect(vehicles.map((v) => v.id).toList(), ['1', '2', '3']);
    });
  });
}
