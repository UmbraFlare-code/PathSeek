import 'package:equatable/equatable.dart';
import 'package:pathseek/features/notifications/domain/entities/route_notification.dart';

class RouteNotificationModel extends Equatable {
  const RouteNotificationModel({
    required this.id,
    required this.rutaId,
    required this.mensaje,
    required this.leida,
    this.createdAt,
  });

  final String id;
  final String rutaId;
  final String mensaje;
  final bool leida;
  final DateTime? createdAt;

  factory RouteNotificationModel.fromJson(Map<String, dynamic> json) {
    return RouteNotificationModel(
      id: (json['notificacion_id'] ?? '').toString(),
      rutaId: (json['ruta_id'] ?? '').toString(),
      mensaje: (json['mensaje'] ?? '').toString(),
      leida: json['leida'] == true,
      createdAt: DateTime.tryParse((json['created_at'] ?? '').toString()),
    );
  }

  RouteNotification toEntity() => RouteNotification(
    id: id,
    rutaId: rutaId,
    mensaje: mensaje,
    leida: leida,
    createdAt: createdAt,
  );

  @override
  List<Object?> get props => [id, rutaId, mensaje, leida, createdAt];
}
