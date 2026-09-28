import 'package:flutter_test/flutter_test.dart';
import 'package:pathseek/features/orders/data/models/order_model.dart';
import 'package:pathseek/features/orders/domain/entities/order.dart';

void main() {
  group('OrderModel', () {
    const json = {
      'pedido_id': 'o1',
      'cliente_id': 'c1',
      'direccion': 'Av. Real 123',
      'gps_lat': -12.0678,
      'gps_lon': -75.2132,
      'peso': 20,
      'volumen': 0.5,
      'ventana_inicio': '08:00:00',
      'ventana_fin': '12:00:00',
      'prioridad': 'EXPRESS',
      'tipo_producto': 'PERECEDERO',
      'estado': 'PENDIENTE',
    };

    test('fromJson parses all fields', () {
      final model = OrderModel.fromJson(json);

      expect(model.id, 'o1');
      expect(model.clienteId, 'c1');
      expect(model.gpsLat, -12.0678);
      expect(model.peso, 20);
      expect(model.prioridad, 'EXPRESS');
      expect(model.estado, 'PENDIENTE');
    });

    test('fromJson truncates time to HH:mm', () {
      final model = OrderModel.fromJson(json);

      expect(model.ventanaInicio, '08:00');
      expect(model.ventanaFin, '12:00');
    });

    test('toJson maps to snake_case api contract', () {
      final model = OrderModel.fromEntity(
        const Order(
          id: '',
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
        ),
      );

      final map = model.toJson();
      expect(map['gps_lat'], -12.0678);
      expect(map['ventana_inicio'], '08:00');
      expect(map.containsKey('pedido_id'), isFalse);
    });

    test('entity validates time window', () {
      const validOrder = Order(
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

      const invalidOrder = Order(
        id: 'o2',
        clienteId: 'c1',
        direccion: 'Av. Real 123',
        gpsLat: -12.0678,
        gpsLon: -75.2132,
        peso: 20,
        volumen: 0.5,
        ventanaInicio: '14:00',
        ventanaFin: '10:00',
        prioridad: 'EXPRESS',
        tipoProducto: 'PERECEDERO',
      );

      expect(validOrder.esVentanaValida, isTrue);
      expect(invalidOrder.esVentanaValida, isFalse);
    });
  });
}
