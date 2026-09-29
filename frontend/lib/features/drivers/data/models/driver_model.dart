import 'package:equatable/equatable.dart';
import 'package:pathseek/features/drivers/domain/entities/driver.dart';

class DriverModel extends Equatable {
  const DriverModel({
    required this.id,
    required this.usuarioId,
    required this.dni,
    required this.nombre,
    required this.licencia,
    required this.categoria,
    required this.experiencia,
    this.disponible = true,
    this.contacto,
  });

  final String id;
  final String usuarioId;
  final String dni;
  final String nombre;
  final String licencia;
  final String categoria;
  final int experiencia;
  final bool disponible;
  final String? contacto;

  factory DriverModel.fromJson(Map<String, dynamic> json) {
    return DriverModel(
      id: (json['conductor_id'] ?? json['id']).toString(),
      usuarioId: (json['usuario_id'] ?? '').toString(),
      dni: (json['dni'] ?? '').toString(),
      nombre: (json['nombre'] ?? '').toString(),
      licencia: (json['licencia'] ?? '').toString(),
      categoria: (json['categoria'] ?? '').toString(),
      experiencia: _toInt(json['experiencia']),
      disponible: json['disponible'] is bool
          ? json['disponible'] as bool
          : true,
      contacto: json['contacto']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'conductor_id': id,
      'usuario_id': usuarioId,
      'dni': dni,
      'nombre': nombre,
      'licencia': licencia,
      'categoria': categoria,
      'experiencia': experiencia,
      'disponible': disponible,
      if (contacto != null && contacto!.isNotEmpty) 'contacto': contacto,
    };
  }

  Driver toEntity() => Driver(
        id: id,
        usuarioId: usuarioId,
        dni: dni,
        nombre: nombre,
        licencia: licencia,
        categoria: categoria,
        experiencia: experiencia,
        disponible: disponible,
        contacto: contacto,
      );

  factory DriverModel.fromEntity(Driver driver) => DriverModel(
        id: driver.id,
        usuarioId: driver.usuarioId,
        dni: driver.dni,
        nombre: driver.nombre,
        licencia: driver.licencia,
        categoria: driver.categoria,
        experiencia: driver.experiencia,
        disponible: driver.disponible,
        contacto: driver.contacto,
      );

  static int _toInt(dynamic value) =>
      value is num ? value.toInt() : int.parse(value.toString());

  @override
  List<Object?> get props => [
        id,
        usuarioId,
        dni,
        nombre,
        licencia,
        categoria,
        experiencia,
        disponible,
        contacto,
      ];
}
