import 'package:flutter_test/flutter_test.dart';
import 'package:pathseek/features/drivers/data/models/driver_model.dart';
import 'package:pathseek/features/drivers/domain/entities/driver.dart';

void main() {
  group('DriverModel', () {
    const json = {
      'conductor_id': 'd1',
      'usuario_id': 'u1',
      'dni': '12345678',
      'nombre': 'Carlos Gomez',
      'licencia': 'Q12345678',
      'categoria': 'AII',
      'experiencia': 5,
      'disponible': true,
      'contacto': '999888777',
    };

    test('fromJson parses all fields', () {
      final model = DriverModel.fromJson(json);

      expect(model.id, 'd1');
      expect(model.usuarioId, 'u1');
      expect(model.dni, '12345678');
      expect(model.nombre, 'Carlos Gomez');
      expect(model.licencia, 'Q12345678');
      expect(model.categoria, 'AII');
      expect(model.experiencia, 5);
      expect(model.disponible, isTrue);
      expect(model.contacto, '999888777');
    });

    test('fromJson defaults disponible to true when missing', () {
      final model = DriverModel.fromJson({
        ...json,
      }..remove('disponible'));

      expect(model.disponible, isTrue);
    });

    test('fromJson handles string experiencia', () {
      final model = DriverModel.fromJson({...json, 'experiencia': '5'});
      expect(model.experiencia, 5);
    });

    test('toJson maps to snake_case api contract', () {
      final model = DriverModel.fromEntity(
        const Driver(
          id: '',
          usuarioId: 'u1',
          dni: '12345678',
          nombre: 'Carlos Gomez',
          licencia: 'Q12345678',
          categoria: 'AII',
          experiencia: 5,
          disponible: true,
          contacto: '999888777',
        ),
      );

      final map = model.toJson();
      expect(map['dni'], '12345678');
      expect(map['experiencia'], 5);
      expect(map.containsKey('conductor_id'), isFalse);
    });

    test('toJson omits empty contacto', () {
      final model = DriverModel.fromEntity(
        const Driver(
          id: 'd1',
          usuarioId: 'u1',
          dni: '12345678',
          nombre: 'Carlos Gomez',
          licencia: 'Q12345678',
          categoria: 'AII',
          experiencia: 5,
          contacto: '',
        ),
      );

      expect(model.toJson().containsKey('contacto'), isFalse);
    });

    test('toEntity maps correctly', () {
      final entity = DriverModel.fromJson(json).toEntity();
      expect(entity, isA<Driver>());
      expect(entity.dni, '12345678');
      expect(entity.disponible, isTrue);
    });
  });
}
