import 'package:flutter_test/flutter_test.dart';
import 'package:pathseek/features/auth/domain/entities/app_user.dart';

void main() {
  group('AppUser', () {
    const admin = AppUser(
      id: 'u1',
      nombre: 'Admin',
      email: 'admin@ugel.edu.pe',
      rol: 'ADMIN',
    );
    const operador = AppUser(
      id: 'u2',
      nombre: 'Operador',
      email: 'operador@ugel.edu.pe',
      rol: 'OPERADOR',
    );
    const conductor = AppUser(
      id: 'u3',
      nombre: 'Conductor',
      email: 'conductor@ugel.edu.pe',
      rol: 'CONDUCTOR',
    );
    const cliente = AppUser(
      id: 'u4',
      nombre: 'Cliente',
      email: 'cliente@ugel.edu.pe',
      rol: 'CLIENTE',
    );
    const auditor = AppUser(
      id: 'u5',
      nombre: 'Auditor',
      email: 'auditor@ugel.edu.pe',
      rol: 'AUDITOR',
    );

    test('role getters', () {
      expect(admin.isAdmin, isTrue);
      expect(admin.isOperador, isFalse);
      expect(operador.isOperador, isTrue);
      expect(conductor.isConductor, isTrue);
      expect(cliente.isCliente, isTrue);
      expect(auditor.isAuditor, isTrue);
    });

    test('hasAnyRole', () {
      expect(admin.hasAnyRole(['ADMIN', 'OPERADOR']), isTrue);
      expect(operador.hasAnyRole(['ADMIN', 'OPERADOR']), isTrue);
      expect(cliente.hasAnyRole(['ADMIN', 'OPERADOR']), isFalse);
      expect(conductor.hasAnyRole([]), isFalse);
    });

    test('equality', () {
      expect(admin, admin);
      expect(
        admin,
        const AppUser(
          id: 'u1',
          nombre: 'Admin',
          email: 'admin@ugel.edu.pe',
          rol: 'ADMIN',
        ),
      );
      expect(admin == operador, isFalse);
    });
  });
}
