import 'package:equatable/equatable.dart';

class ClientProfile extends Equatable {
  const ClientProfile({
    required this.id,
    required this.usuarioId,
    required this.nombre,
    this.direccion,
    this.puntoReferencia,
    this.telefono,
    this.horarioAtencionInicio,
    this.horarioAtencionFin,
    this.restriccionesAcceso,
  });

  final String id;
  final String usuarioId;
  final String nombre;
  final String? direccion;
  final String? puntoReferencia;
  final String? telefono;
  final String? horarioAtencionInicio;
  final String? horarioAtencionFin;
  final String? restriccionesAcceso;

  String get horarioLabel {
    if (horarioAtencionInicio == null || horarioAtencionFin == null) {
      return 'Horario no definido';
    }
    return '$horarioAtencionInicio – $horarioAtencionFin';
  }

  @override
  List<Object?> get props => [
    id,
    usuarioId,
    nombre,
    direccion,
    puntoReferencia,
    telefono,
    horarioAtencionInicio,
    horarioAtencionFin,
    restriccionesAcceso,
  ];
}
