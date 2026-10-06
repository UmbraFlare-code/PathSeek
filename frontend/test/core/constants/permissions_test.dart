import 'package:flutter_test/flutter_test.dart';
import 'package:pathseek/core/constants/permissions.dart';
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

  group('AppPermissions.canView', () {
    test('fleet/drivers: admin, operador y auditor ven', () {
      expect(AppPermissions.canView(admin, AppModule.fleet), isTrue);
      expect(AppPermissions.canView(operador, AppModule.drivers), isTrue);
      expect(AppPermissions.canView(auditor, AppModule.fleet), isTrue);
      expect(AppPermissions.canView(cliente, AppModule.fleet), isFalse);
      expect(AppPermissions.canView(conductor, AppModule.drivers), isFalse);
    });

    test('orders: admin, operador, cliente y auditor ven', () {
      expect(AppPermissions.canView(admin, AppModule.orders), isTrue);
      expect(AppPermissions.canView(operador, AppModule.orders), isTrue);
      expect(AppPermissions.canView(cliente, AppModule.orders), isTrue);
      expect(AppPermissions.canView(auditor, AppModule.orders), isTrue);
      expect(AppPermissions.canView(conductor, AppModule.orders), isFalse);
    });

    test('routes/dashboard: admin, operador y auditor ven', () {
      expect(AppPermissions.canView(admin, AppModule.routes), isTrue);
      expect(AppPermissions.canView(operador, AppModule.dashboard), isTrue);
      expect(AppPermissions.canView(auditor, AppModule.routes), isTrue);
      expect(AppPermissions.canView(cliente, AppModule.routes), isFalse);
      expect(AppPermissions.canView(conductor, AppModule.dashboard), isFalse);
    });

    test('null user cannot view anything', () {
      expect(AppPermissions.canView(null, AppModule.fleet), isFalse);
    });
  });

  group('AppPermissions.canCreate', () {
    test('fleet/drivers: solo admin y operador', () {
      expect(AppPermissions.canCreate(admin, AppModule.fleet), isTrue);
      expect(AppPermissions.canCreate(operador, AppModule.drivers), isTrue);
      expect(AppPermissions.canCreate(auditor, AppModule.fleet), isFalse);
    });

    test('orders: admin, operador y cliente', () {
      expect(AppPermissions.canCreate(admin, AppModule.orders), isTrue);
      expect(AppPermissions.canCreate(cliente, AppModule.orders), isTrue);
      expect(AppPermissions.canCreate(auditor, AppModule.orders), isFalse);
    });

    test('routes: admin y operador', () {
      expect(AppPermissions.canCreate(admin, AppModule.routes), isTrue);
      expect(AppPermissions.canCreate(operador, AppModule.routes), isTrue);
      expect(AppPermissions.canCreate(auditor, AppModule.routes), isFalse);
      expect(AppPermissions.canCreate(cliente, AppModule.routes), isFalse);
    });

    test('dashboard nunca se crea', () {
      expect(AppPermissions.canCreate(admin, AppModule.dashboard), isFalse);
    });
  });

  group('AppPermissions.canUpdate / canDelete', () {
    test('admin y operador editan todo', () {
      for (final module in [
        AppModule.fleet,
        AppModule.drivers,
        AppModule.orders,
        AppModule.routes,
      ]) {
        expect(AppPermissions.canUpdate(admin, module), isTrue);
        expect(AppPermissions.canDelete(operador, module), isTrue);
      }
    });

    test('auditor y cliente no editan ni eliminan', () {
      expect(AppPermissions.canUpdate(auditor, AppModule.fleet), isFalse);
      expect(AppPermissions.canDelete(auditor, AppModule.orders), isFalse);
      expect(AppPermissions.canUpdate(cliente, AppModule.orders), isFalse);
      expect(AppPermissions.canDelete(cliente, AppModule.orders), isFalse);
    });
  });
}
