import '../domain/entities/vehicle.dart';

enum VehicleSort { placa, anio, capacidad }

List<Vehicle> filterVehicles(List<Vehicle> vehicles, String query) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return vehicles;
  return vehicles
      .where(
        (v) =>
            v.placa.toLowerCase().contains(q) ||
            v.tipo.toLowerCase().contains(q),
      )
      .toList();
}

List<Vehicle> sortVehicles(List<Vehicle> vehicles, VehicleSort sort) {
  final list = [...vehicles];
  switch (sort) {
    case VehicleSort.placa:
      list.sort((a, b) => a.placa.compareTo(b.placa));
    case VehicleSort.anio:
      list.sort((a, b) => b.anio.compareTo(a.anio));
    case VehicleSort.capacidad:
      list.sort((a, b) => b.capacidadKg.compareTo(a.capacidadKg));
  }
  return list;
}
