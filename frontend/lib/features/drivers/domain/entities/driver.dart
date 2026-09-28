import 'package:equatable/equatable.dart';

class Driver extends Equatable {
  const Driver({
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
