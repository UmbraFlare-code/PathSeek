import 'package:flutter_test/flutter_test.dart';
import 'package:pathseek/core/router/app_router.dart';
import 'package:pathseek/features/auth/domain/entities/app_user.dart';

void main() {
  const admin = AppUser(id: '1', nombre: 'A', email: 'a@x.pe', rol: 'ADMIN');
  const operador =
      AppUser(id: '2', nombre: 'O', email: 'o@x.pe', rol: 'OPERADOR');
  const auditor =
      AppUser(id: '3', nombre: 'Au', email: 'au@x.pe', rol: 'AUDITOR');
  const cliente =
      AppUser(id: '4', nombre: 'C', email: 'c@x.pe', rol: 'CLIENTE');
  const conductor =
      AppUser(id: '5', nombre: 'Co', email: 'co@x.pe', rol: 'CONDUCTOR');

  group('AppRouter.defaultHomeFor', () {
    test('usuario sin sesion va al login', () {
      expect(AppRouter.defaultHomeFor(null), '/login');
    });

    test('admin, operador, auditor y conductor van al dashboard', () {
      expect(AppRouter.defaultHomeFor(admin), '/');
      expect(AppRouter.defaultHomeFor(operador), '/');
      expect(AppRouter.defaultHomeFor(auditor), '/');
      expect(AppRouter.defaultHomeFor(conductor), '/');
    });

    test('cliente va a pedidos (sin acceso al dashboard segun DOC-008)', () {
      expect(AppRouter.defaultHomeFor(cliente), '/orders');
    });
  });
}
