import 'package:flutter_test/flutter_test.dart';
import 'package:pathseek/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:pathseek/features/drivers/domain/entities/driver.dart';
import 'package:pathseek/features/drivers/presentation/bloc/driver_bloc.dart';
import 'package:pathseek/features/fleet/domain/entities/vehicle.dart';
import 'package:pathseek/features/fleet/presentation/bloc/fleet_bloc.dart';
import 'package:pathseek/features/orders/domain/entities/order.dart';
import 'package:pathseek/features/orders/presentation/bloc/order_bloc.dart';

void main() {
  group('Event props', () {
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
    const driver = Driver(
      id: 'd1',
      usuarioId: 'u1',
      dni: '12345678',
      nombre: 'Carlos',
      licencia: 'Q12345678',
      categoria: 'AII',
      experiencia: 5,
    );
    const order = Order(
      id: 'o1',
      clienteId: 'c1',
      direccion: 'Av. Real 123',
      gpsLat: -12.0,
      gpsLon: -75.0,
      peso: 10,
      volumen: 0.5,
      ventanaInicio: '08:00',
      ventanaFin: '12:00',
      prioridad: 'ESTANDAR',
      tipoProducto: 'NO_PERECEDERO',
    );

    test('FleetEvent props', () {
      expect(const FleetLoaded().props, isEmpty);
      expect(const FleetVehicleCreated(vehicle).props, [vehicle]);
      expect(const FleetVehicleUpdated(vehicle).props, [vehicle]);
      expect(const FleetVehicleDeleted('v1').props, ['v1']);
    });

    test('DriverEvent props', () {
      expect(const DriversLoaded().props, isEmpty);
      expect(const DriverCreated(driver).props, [driver]);
      expect(const DriverUpdated(driver).props, [driver]);
      expect(const DriverDeleted('d1').props, ['d1']);
    });

    test('OrderEvent props', () {
      expect(const OrdersLoaded().props, isEmpty);
      expect(const OrderCreated(order).props, [order]);
      expect(const OrderUpdated(order).props, [order]);
      expect(const OrderDeleted('o1').props, ['o1']);
    });

    test('AuthEvent props', () {
      expect(const AuthCheckRequested().props, isEmpty);
      expect(
        const AuthLoginRequested(email: 'a@b.com', password: '123').props,
        ['a@b.com', '123'],
      );
      expect(const AuthLogoutRequested().props, isEmpty);
    });
  });

  group('State helpers', () {
    test('FleetState helpers', () {
      const state = FleetState.initial();
      expect(state.hasError, isFalse);
      expect(state.hasSaveError, isFalse);
      expect(state.isEmpty, isTrue);

      const withError = FleetState(errorMessage: 'error');
      expect(withError.hasError, isTrue);
    });

    test('DriverState helpers', () {
      const state = DriverState.initial();
      expect(state.hasError, isFalse);
      expect(state.hasSaveError, isFalse);
      expect(state.isEmpty, isTrue);
    });

    test('OrderState helpers', () {
      const state = OrderState.initial();
      expect(state.hasError, isFalse);
      expect(state.hasSaveError, isFalse);
      expect(state.isEmpty, isTrue);
    });

    test('AuthState helpers', () {
      const unknown = AuthState.unknown();
      expect(unknown.isUnknown, isTrue);
      expect(unknown.isAuthenticated, isFalse);

      const loading = AuthState.loading();
      expect(loading.isLoading, isTrue);

      final failure = AuthState.failure('msg');
      expect(failure.hasError, isTrue);
      expect(failure.errorMessage, 'msg');
      expect(failure.isUnauthenticated, isFalse);
    });
  });
}
