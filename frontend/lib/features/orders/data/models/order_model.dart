import 'package:equatable/equatable.dart';
import 'package:pathseek/features/orders/domain/entities/order.dart';

class OrderModel extends Equatable {
  const OrderModel({
    required this.id,
    required this.clienteId,
    required this.direccion,
    required this.gpsLat,
    required this.gpsLon,
    required this.peso,
    required this.volumen,
    required this.ventanaInicio,
    required this.ventanaFin,
    required this.prioridad,
    required this.tipoProducto,
    this.estado = 'PENDIENTE',
    this.clienteNombre,
  });

  final String id;
  final String clienteId;
  final String direccion;
  final double gpsLat;
  final double gpsLon;
  final double peso;
  final double volumen;
  final String ventanaInicio;
  final String ventanaFin;
  final String prioridad;
  final String tipoProducto;
  final String estado;
  final String? clienteNombre;

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: (json['pedido_id'] ?? json['id']).toString(),
      clienteId: (json['cliente_id'] ?? '').toString(),
      direccion: (json['direccion'] ?? '').toString(),
      gpsLat: _toDouble(json['gps_lat']),
      gpsLon: _toDouble(json['gps_lon']),
      peso: _toDouble(json['peso']),
      volumen: _toDouble(json['volumen']),
      ventanaInicio: _toTime(json['ventana_inicio']),
      ventanaFin: _toTime(json['ventana_fin']),
      prioridad: (json['prioridad'] ?? 'ESTANDAR').toString(),
      tipoProducto: (json['tipo_producto'] ?? '').toString(),
      estado: (json['estado'] ?? 'PENDIENTE').toString(),
      clienteNombre: json['cliente_nombre']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'pedido_id': id,
      'cliente_id': clienteId,
      'direccion': direccion,
      'gps_lat': gpsLat,
      'gps_lon': gpsLon,
      'peso': peso,
      'volumen': volumen,
      'ventana_inicio': ventanaInicio,
      'ventana_fin': ventanaFin,
      'prioridad': prioridad,
      'tipo_producto': tipoProducto,
      'estado': estado,
    };
  }

  Order toEntity() => Order(
        id: id,
        clienteId: clienteId,
        direccion: direccion,
        gpsLat: gpsLat,
        gpsLon: gpsLon,
        peso: peso,
        volumen: volumen,
        ventanaInicio: ventanaInicio,
        ventanaFin: ventanaFin,
        prioridad: prioridad,
        tipoProducto: tipoProducto,
        estado: estado,
        clienteNombre: clienteNombre,
      );

  factory OrderModel.fromEntity(Order order) => OrderModel(
        id: order.id,
        clienteId: order.clienteId,
        direccion: order.direccion,
        gpsLat: order.gpsLat,
        gpsLon: order.gpsLon,
        peso: order.peso,
        volumen: order.volumen,
        ventanaInicio: order.ventanaInicio,
        ventanaFin: order.ventanaFin,
        prioridad: order.prioridad,
        tipoProducto: order.tipoProducto,
        estado: order.estado,
        clienteNombre: order.clienteNombre,
      );

  static double _toDouble(dynamic value) =>
      value is num ? value.toDouble() : double.parse(value.toString());

  static String _toTime(dynamic value) {
    if (value is String) {
      if (value.length >= 5) return value.substring(0, 5);
      return value;
    }
    return value.toString().substring(0, 5);
  }

  @override
  List<Object?> get props => [
        id,
        clienteId,
        direccion,
        gpsLat,
        gpsLon,
        peso,
        volumen,
        ventanaInicio,
        ventanaFin,
        prioridad,
        tipoProducto,
        estado,
        clienteNombre,
      ];
}
