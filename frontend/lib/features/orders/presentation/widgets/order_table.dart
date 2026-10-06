import 'package:flutter/material.dart';

import '../../../../core/utils/formatters.dart';
import '../../domain/entities/order.dart';

class OrderTable extends StatelessWidget {
  const OrderTable({
    super.key,
    required this.orders,
    required this.onEdit,
    required this.onDelete,
    this.canEdit = true,
    this.canDelete = true,
  });

  final List<Order> orders;
  final ValueChanged<Order> onEdit;
  final ValueChanged<Order> onDelete;
  final bool canEdit;
  final bool canDelete;

  bool get _showActions => canEdit || canDelete;

  @override
  Widget build(BuildContext context) {
    final headers = [
      'Direccion',
      'Peso (kg)',
      'Vol. (m3)',
      'Ventana',
      'Prioridad',
      'Tipo',
      'Estado',
      if (_showActions) 'Acciones',
    ];

    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: headers
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
                DataCell(OrderStatusChip(estado: order.estado)),
                if (_showActions)
                  DataCell(
                    Row(
                      children: [
                        if (canEdit)
                          IconButton(
                            tooltip: 'Editar',
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () => onEdit(order),
                          ),
                        if (canDelete)
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

class OrderStatusChip extends StatelessWidget {
  const OrderStatusChip({super.key, required this.estado});

  final String estado;

  @override
  Widget build(BuildContext context) {
    final (color, foreground) = switch (estado) {
      'PENDIENTE' => (Colors.orange.shade100, Colors.orange.shade900),
      'PLANIFICADO' => (Colors.blue.shade100, Colors.blue.shade900),
      'EN_RUTA' => (Colors.indigo.shade100, Colors.indigo.shade900),
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
