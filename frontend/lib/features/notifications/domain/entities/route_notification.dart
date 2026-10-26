import 'package:equatable/equatable.dart';

class RouteNotification extends Equatable {
  const RouteNotification({
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

  @override
  List<Object?> get props => [id, rutaId, mensaje, leida, createdAt];
}
