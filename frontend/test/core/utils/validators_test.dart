import 'package:flutter_test/flutter_test.dart';
import 'package:pathseek/core/utils/validators.dart';

void main() {
  group('Validators.required', () {
    test('returns error for null', () {
      expect(Validators.required(null, 'Campo'), 'Campo es obligatorio');
    });

    test('returns error for empty string', () {
      expect(Validators.required('', 'Campo'), 'Campo es obligatorio');
    });

    test('returns error for whitespace only', () {
      expect(Validators.required('   ', 'Campo'), 'Campo es obligatorio');
    });

    test('returns null for valid value', () {
      expect(Validators.required('valor', 'Campo'), isNull);
    });
  });

  group('Validators.email', () {
    test('accepts valid email', () {
      expect(Validators.email('user@example.com'), isNull);
    });

    test('rejects invalid email', () {
      expect(
        Validators.email('no-es-correo'),
        'Ingrese un correo valido',
      );
    });

    test('rejects empty email', () {
      expect(Validators.email(''), isNotNull);
    });
  });

  group('Validators.password', () {
    test('accepts password with 8+ chars', () {
      expect(Validators.password('12345678'), isNull);
    });

    test('rejects password shorter than 8 chars', () {
      expect(
        Validators.password('1234567'),
        'La contrasena debe tener al menos 8 caracteres',
      );
    });
  });

  group('Validators.plate', () {
    test('accepts valid peruvian plate', () {
      expect(Validators.plate('ABC123'), isNull);
      expect(Validators.plate('abc-123'), isNull);
      expect(Validators.plate('F5A123'), isNull);
    });

    test('rejects invalid plate', () {
      expect(Validators.plate('XYZ'), 'Formato de placa invalido (ej. ABC123)');
      expect(Validators.plate(''), isNotNull);
    });
  });

  group('Validators.dni', () {
    test('accepts 8-digit dni', () {
      expect(Validators.dni('12345678'), isNull);
    });

    test('rejects wrong length dni', () {
      expect(Validators.dni('12345'), 'El DNI debe tener 8 digitos');
    });

    test('rejects non-numeric dni', () {
      expect(Validators.dni('abcdefgh'), 'El DNI debe tener 8 digitos');
    });
  });

  group('Validators.license', () {
    test('accepts valid license format', () {
      expect(Validators.license('Q12345678'), isNull);
      expect(Validators.license('A1234567'), isNull);
    });

    test('rejects invalid license', () {
      expect(
        Validators.license('1234'),
        'Formato de licencia invalido (ej. Q12345678)',
      );
    });
  });

  group('Validators.decimal', () {
    test('accepts positive decimal', () {
      expect(Validators.decimal('12.5', 'Peso'), isNull);
    });

    test('accepts zero', () {
      expect(Validators.decimal('0', 'Peso'), isNull);
    });

    test('rejects negative', () {
      expect(
        Validators.decimal('-5', 'Peso'),
        'Peso debe ser un numero mayor o igual a 0',
      );
    });

    test('rejects non-numeric', () {
      expect(Validators.decimal('abc', 'Peso'), isNotNull);
    });
  });

  group('Validators.integer', () {
    test('accepts positive integer', () {
      expect(Validators.integer('2020', 'Anio'), isNull);
    });

    test('rejects decimal value', () {
      expect(Validators.integer('20.5', 'Anio'), isNotNull);
    });

    test('rejects non-numeric', () {
      expect(Validators.integer('abc', 'Anio'), isNotNull);
    });
  });

  group('Validators.timeWindow', () {
    test('accepts valid window', () {
      expect(Validators.timeWindow('08:00', '12:00'), isNull);
    });

    test('rejects end before start', () {
      expect(
        Validators.timeWindow('14:00', '10:00'),
        'La hora de fin debe ser posterior a la hora de inicio',
      );
    });

    test('rejects equal times', () {
      expect(
        Validators.timeWindow('10:00', '10:00'),
        'La hora de fin debe ser posterior a la hora de inicio',
      );
    });

    test('rejects invalid format', () {
      expect(
        Validators.timeWindow('8:00', '99:99'),
        'Formato de hora invalido (HH:mm)',
      );
    });

    test('rejects missing values', () {
      expect(Validators.timeWindow('', '12:00'), isNotNull);
      expect(Validators.timeWindow('08:00', ''), isNotNull);
    });
  });
}
