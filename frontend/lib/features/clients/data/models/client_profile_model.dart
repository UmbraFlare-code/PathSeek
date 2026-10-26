import 'package:equatable/equatable.dart';
import 'package:pathseek/features/clients/domain/entities/client_profile.dart';

class ClientProfileModel extends Equatable {
  const ClientProfileModel({
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

  factory ClientProfileModel.fromJson(Map<String, dynamic> json) {
    return ClientProfileModel(
      id: (json['cliente_id'] ?? '').toString(),
      usuarioId: (json['usuario_id'] ?? '').toString(),
      nombre: (json['nombre'] ?? '').toString(),
      direccion: _toStringOrNull(json['direccion']),
      puntoReferencia: _toStringOrNull(json['punto_referencia']),
      telefono: _toStringOrNull(json['telefono']),
      horarioAtencionInicio: _toStringOrNull(
        json['horario_atencion_inicio'],
      ),
      horarioAtencionFin: _toStringOrNull(json['horario_atencion_fin']),
      restriccionesAcceso: _toStringOrNull(json['restricciones_acceso']),
    );
  }

  ClientProfile toEntity() => ClientProfile(
    id: id,
    usuarioId: usuarioId,
    nombre: nombre,
    direccion: direccion,
    puntoReferencia: puntoReferencia,
    telefono: telefono,
    horarioAtencionInicio: horarioAtencionInicio,
    horarioAtencionFin: horarioAtencionFin,
    restriccionesAcceso: restriccionesAcceso,
  );

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

String? _toStringOrNull(dynamic value) => value?.toString();
