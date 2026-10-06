import 'package:flutter_test/flutter_test.dart';
import 'package:pathseek/features/drivers/domain/entities/driver.dart';
import 'package:pathseek/features/drivers/presentation/driver_filters.dart';

Driver _driver(String id, String nombre, String dni, String licencia, int exp) =>
    Driver(
      id: id,
      usuarioId: '',
      dni: dni,
      nombre: nombre,
      licencia: licencia,
      categoria: 'AII',
      experiencia: exp,
    );

void main() {
  final drivers = [
    _driver('1', 'Juan Perez', '12345678', 'Q12345678', 5),
    _driver('2', 'Carlos Gomez', '87654321', 'Q87654321', 10),
    _driver('3', 'Ana Torres', '11223344', 'A11223344', 3),
  ];

  group('filterDrivers', () {
    test('empty query returns all', () {
      expect(filterDrivers(drivers, ''), drivers);
    });

    test('searches by nombre (case-insensitive)', () {
      expect(filterDrivers(drivers, 'carlos').map((d) => d.id), ['2']);
      expect(filterDrivers(drivers, 'ANA').map((d) => d.id), ['3']);
    });

    test('searches by dni', () {
      expect(filterDrivers(drivers, '87654321').map((d) => d.id), ['2']);
    });

    test('searches by licencia', () {
      expect(filterDrivers(drivers, 'Q12345678').map((d) => d.id), ['1']);
    });

    test('no matches returns empty', () {
      expect(filterDrivers(drivers, 'zzz'), isEmpty);
    });
  });

  group('sortDrivers', () {
    test('sorts by nombre ascending', () {
      final sorted = sortDrivers(drivers, DriverSort.nombre);
      expect(sorted.map((d) => d.nombre).toList(),
          ['Ana Torres', 'Carlos Gomez', 'Juan Perez']);
    });

    test('sorts by experiencia descending', () {
      final sorted = sortDrivers(drivers, DriverSort.experiencia);
      expect(sorted.map((d) => d.experiencia).toList(), [10, 5, 3]);
    });
  });
}
