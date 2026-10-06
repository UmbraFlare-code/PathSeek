import '../domain/entities/driver.dart';

enum DriverSort { nombre, experiencia }

List<Driver> filterDrivers(List<Driver> drivers, String query) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return drivers;
  return drivers
      .where(
        (d) =>
            d.nombre.toLowerCase().contains(q) ||
            d.dni.contains(q) ||
            d.licencia.toLowerCase().contains(q),
      )
      .toList();
}

List<Driver> sortDrivers(List<Driver> drivers, DriverSort sort) {
  final list = [...drivers];
  switch (sort) {
    case DriverSort.nombre:
      list.sort((a, b) => a.nombre.compareTo(b.nombre));
    case DriverSort.experiencia:
      list.sort((a, b) => b.experiencia.compareTo(a.experiencia));
  }
  return list;
}
