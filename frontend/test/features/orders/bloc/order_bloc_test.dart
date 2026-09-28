import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pathseek/core/errors/failures.dart';
import 'package:pathseek/features/orders/domain/entities/order.dart';
import 'package:pathseek/features/orders/domain/repositories/order_repository.dart';
import 'package:pathseek/features/orders/presentation/bloc/order_bloc.dart';

class MockOrderRepository extends Mock implements OrderRepository {}

void main() {
  late MockOrderRepository repository;
  late OrderBloc bloc;

  const order = Order(
    id: 'o1',
    clienteId: 'c1',
    direccion: 'Av. Real 123',
    gpsLat: -12.0678,
    gpsLon: -75.2132,
    peso: 20,
    volumen: 0.5,
    ventanaInicio: '08:00',
    ventanaFin: '12:00',
    prioridad: 'EXPRESS',
    tipoProducto: 'PERECEDERO',
  );

  setUp(() {
    repository = MockOrderRepository();
    bloc = OrderBloc(repository: repository);
  });

  tearDown(() => bloc.close());

  group('OrderBloc', () {
    test('initial state is initial', () {
      expect(bloc.state, const OrderState.initial());
    });

    blocTest<OrderBloc, OrderState>(
      'loads orders successfully',
      build: () {
        when(() => repository.getOrders())
            .thenAnswer((_) async => [order]);
        return bloc;
      },
      act: (bloc) => bloc.add(const OrdersLoaded()),
      expect: () => [
        isA<OrderState>().having((s) => s.isLoading, 'isLoading', true),
        isA<OrderState>()
            .having((s) => s.orders, 'orders', [order])
            .having((s) => s.isLoading, 'isLoading', false),
      ],
    );

    blocTest<OrderBloc, OrderState>(
      'creates order successfully',
      build: () {
        when(() => repository.createOrder(order))
            .thenAnswer((_) async => order);
        return bloc;
      },
      act: (bloc) => bloc.add(const OrderCreated(order)),
      expect: () => [
        isA<OrderState>().having((s) => s.isSaving, 'isSaving', true),
        isA<OrderState>()
            .having((s) => s.saveSuccess, 'saveSuccess', true)
            .having((s) => s.orders, 'orders', [order]),
      ],
    );

    blocTest<OrderBloc, OrderState>(
      'updates order in list',
      build: () {
        when(() => repository.updateOrder(order))
            .thenAnswer((_) async => order);
        return bloc;
      },
      seed: () => const OrderState(orders: [order]),
      act: (bloc) => bloc.add(const OrderUpdated(order)),
      expect: () => [
        isA<OrderState>().having((s) => s.isSaving, 'isSaving', true),
        isA<OrderState>()
            .having((s) => s.saveSuccess, 'saveSuccess', true)
            .having((s) => s.orders, 'orders', [order]),
      ],
    );

    blocTest<OrderBloc, OrderState>(
      'sets save error on incompatible time window',
      build: () {
        when(() => repository.createOrder(order))
            .thenThrow(
          const ValidationFailure(
            'La hora de fin debe ser posterior a la hora de inicio',
          ),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(const OrderCreated(order)),
      expect: () => [
        isA<OrderState>().having((s) => s.isSaving, 'isSaving', true),
        isA<OrderState>()
            .having(
              (s) => s.saveErrorMessage,
              'saveError',
              'La hora de fin debe ser posterior a la hora de inicio',
            ),
      ],
    );

    blocTest<OrderBloc, OrderState>(
      'deletes order from list',
      build: () {
        when(() => repository.deleteOrder('o1')).thenAnswer((_) async {});
        return bloc;
      },
      seed: () => const OrderState(orders: [order]),
      act: (bloc) => bloc.add(const OrderDeleted('o1')),
      expect: () => [
        isA<OrderState>().having((s) => s.isSaving, 'isSaving', true),
        isA<OrderState>().having((s) => s.orders, 'orders', isEmpty),
      ],
    );
  });
}
