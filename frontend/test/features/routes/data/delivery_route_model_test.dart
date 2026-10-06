import 'package:flutter_test/flutter_test.dart';
import 'package:pathseek/features/routes/data/models/delivery_route_model.dart';

void main() {
  group('DeliveryRouteModel', () {
    const json = {
      'ruta_id': 'r1',
      'fecha': '2026-10-05',
      'conductor_id': 'd1',
      'conductor_nombre': 'Carlos Gomez',
      'vehiculo_id': 'v1',
      'placa': 'ABC123',
      'distancia_km': 45.2,
      'co2_kg': 11.3,
      'combustible_l': 8.5,
      'estado': 'PLANIFICADA',
      'pedidos': [
        {
          'pedido_id': 'o1',
          'orden': 1,
          'hora_estimada': '08:30:00',
          'direccion': 'Av. Real 123',
          'gps_lat': -12.0678,
          'gps_lon': -75.2132,
          'peso': 20,
          'ventana_inicio': '08:00',
          'ventana_fin': '12:00',
        },
      ],
    };

    test('fromJson parses route with pedidos', () {
      final model = DeliveryRouteModel.fromJson(json);

      expect(model.id, 'r1');
      expect(model.fecha, '2026-10-05');
      expect(model.conductorNombre, 'Carlos Gomez');
      expect(model.placa, 'ABC123');
      expect(model.distanciaKm, 45.2);
      expect(model.co2Kg, 11.3);
      expect(model.combustibleL, 8.5);
      expect(model.estado, 'PLANIFICADA');
      expect(model.pedidos, hasLength(1));
      expect(model.pedidos.first.pedidoId, 'o1');
      expect(model.pedidos.first.orden, 1);
      expect(model.pedidos.first.direccion, 'Av. Real 123');
    });

    test('fromJson tolerates missing pedidos', () {
      final model = DeliveryRouteModel.fromJson({
        ...json,
      }..remove('pedidos'));
      expect(model.pedidos, isEmpty);
    });

    test('fromJson defaults estado', () {
      final model = DeliveryRouteModel.fromJson({
        ...json,
      }..remove('estado'));
      expect(model.estado, 'PLANIFICADA');
    });

    test('toEntity maps pedidos correctly', () {
      final entity = DeliveryRouteModel.fromJson(json).toEntity();

      expect(entity.id, 'r1');
      expect(entity.pedidos, hasLength(1));
      final pedido = entity.pedidos.first;
      expect(pedido.pedidoId, 'o1');
      expect(pedido.orden, 1);
      expect(pedido.horaEstimada, '08:30:00');
      expect(pedido.peso, 20);
    });
  });
}
