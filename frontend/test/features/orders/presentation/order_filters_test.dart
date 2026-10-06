import 'package:flutter_test/flutter_test.dart';
import 'package:pathseek/features/orders/domain/entities/order.dart';
import 'package:pathseek/features/orders/presentation/order_filters.dart';

Order _order(
  String id,
  String direccion,
  String cliente,
  String prioridad,
  String ventana,
  String estado,
) =>
    Order(
      id: id,
      clienteId: cliente,
      direccion: direccion,
      gpsLat: -12,
      gpsLon: -75,
      peso: 10,
      volumen: 0.5,
      ventanaInicio: ventana,
      ventanaFin: '12:00',
      prioridad: prioridad,
      tipoProducto: 'NO_PERECEDERO',
      estado: estado,
    );

void main() {
  final orders = [
    _order('1', 'Av. Ferrocarril 450', 'IE-SAN-CARLOS', 'ESTANDAR', '09:00', 'PENDIENTE'),
    _order('2', 'Jr. Real 1250', 'IE-MARISCAL', 'EXPRESS', '08:00', 'ENTREGADO'),
    _order('3', 'Av. Giraldez 310', 'IE-GUZMAN', 'ECONOMICO', '14:00', 'CANCELADO'),
  ];

  group('filterOrders', () {
    test('empty query returns all', () {
      expect(filterOrders(orders, ''), orders);
    });

    test('searches by direccion (case-insensitive)', () {
      expect(filterOrders(orders, 'ferrocarril').map((o) => o.id), ['1']);
    });

    test('searches by cliente', () {
      expect(filterOrders(orders, 'MARISCAL').map((o) => o.id), ['2']);
    });

    test('no matches returns empty', () {
      expect(filterOrders(orders, 'zzz'), isEmpty);
    });
  });

  group('sortOrders', () {
    test('sorts by prioridad (EXPRESS primero)', () {
      final sorted = sortOrders(orders, OrderSort.prioridad);
      expect(sorted.map((o) => o.prioridad).toList(),
          ['EXPRESS', 'ESTANDAR', 'ECONOMICO']);
    });

    test('sorts by ventana asc', () {
      final sorted = sortOrders(orders, OrderSort.ventana);
      expect(sorted.map((o) => o.ventanaInicio).toList(),
          ['08:00', '09:00', '14:00']);
    });

    test('sorts by estado (PENDIENTE primero)', () {
      final sorted = sortOrders(orders, OrderSort.estado);
      expect(sorted.map((o) => o.estado).toList(),
          ['PENDIENTE', 'ENTREGADO', 'CANCELADO']);
    });

    test('does not mutate original list', () {
      sortOrders(orders, OrderSort.prioridad);
      expect(orders.map((o) => o.id).toList(), ['1', '2', '3']);
    });
  });
}
