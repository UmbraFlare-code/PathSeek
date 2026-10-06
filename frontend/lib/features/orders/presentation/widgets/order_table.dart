import 'package:flutter/material.dart';

import '../../../../core/utils/formatters.dart';
import '../../domain/entities/order.dart';

class OrderTable extends StatelessWidget {
  const OrderTable({
    super.key,
    required this.orders,
    required this.onEdit,
    required this.onDelete,
  });

  final List<Order> orders;
  final ValueChanged<Order> onEdit;
  final ValueChanged<Order> onDelete;

  static const List<String> _headers = [
    'Direccion',
    'Peso (kg)',
    'Vol. (m3)',
    'Ventana',
    'Prioridad',
    'Tipo',
    'Estado',
    'Acciones',
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: _headers
              .map((header) => DataColumn(label: Text(header)))
              .toList(),
          rows: orders.map((order) {
            return DataRow(
              cells: [
                DataCell(Text(
                  order.direccion,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                )),
                DataCell(Text(Formatters.decimal.format(order.peso))),
                DataCell(Text(Formatters.decimal.format(order.volumen))),
                DataCell(Text('${order.ventanaInicio} - ${order.ventanaFin}')),
                DataCell(Text(order.prioridad)),
                DataCell(Text(order.tipoProducto)),
                DataCell(_EstadoChip(estado: order.estado)),
                DataCell(
                  Row(
                    children: [
                      IconButton(
                        tooltip: 'Editar',
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => onEdit(order),
                      ),
                      IconButton(
                        tooltip: 'Eliminar',
                        icon: Icon(
                          Icons.delete_outline,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        onPressed: () => _confirmDelete(context, order),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Order order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar pedido'),
        content: Text(
          'Seguro que desea eliminar el pedido con direccion "${order.direccion}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      onDelete(order);
    }
  }
}

class _EstadoChip extends StatelessWidget {
  const _EstadoChip({required this.estado});

  final String estado;

  @override
  Widget build(BuildContext context) {
    final (color, foreground) = switch (estado) {
      'PENDIENTE' => (Colors.orange.shade100, Colors.orange.shade900),
      'EN_RUTA' => (Colors.blue.shade100, Colors.blue.shade900),
      'PLANIFICADO' => (Colors.blue.shade100, Colors.blue.shade900),
      'ENTREGADO' => (Colors.green.shade100, Colors.green.shade900),
      'CANCELADO' => (Colors.red.shade100, Colors.red.shade900),
      _ => (Colors.grey.shade200, Colors.grey.shade800),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        estado,
        style: TextStyle(fontSize: 12, color: foreground),
      ),
    );
  }
}
