import '../domain/entities/order.dart';

enum OrderSort { prioridad, ventana, estado }

int _priorityRank(String prioridad) => switch (prioridad) {
      'EXPRESS' => 0,
      'ESTANDAR' => 1,
      'ECONOMICO' => 2,
      _ => 3,
    };

int _estadoRank(String estado) => switch (estado) {
      'PENDIENTE' => 0,
      'EN_RUTA' => 1,
      'ENTREGADO' => 2,
      'CANCELADO' => 3,
      _ => 4,
    };

List<Order> filterOrders(List<Order> orders, String query) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return orders;
  return orders
      .where(
        (o) =>
            o.direccion.toLowerCase().contains(q) ||
            o.clienteId.toLowerCase().contains(q),
      )
      .toList();
}

List<Order> sortOrders(List<Order> orders, OrderSort sort) {
  final list = [...orders];
  switch (sort) {
    case OrderSort.prioridad:
      list.sort((a, b) => _priorityRank(a.prioridad).compareTo(_priorityRank(b.prioridad)));
    case OrderSort.ventana:
      list.sort((a, b) => a.ventanaInicio.compareTo(b.ventanaInicio));
    case OrderSort.estado:
      list.sort((a, b) => _estadoRank(a.estado).compareTo(_estadoRank(b.estado)));
  }
  return list;
}
