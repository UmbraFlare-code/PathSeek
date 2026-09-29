import 'package:equatable/equatable.dart';

class Order extends Equatable {
  const Order({
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

  bool get esVentanaValida => ventanaFin.compareTo(ventanaInicio) > 0;

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
