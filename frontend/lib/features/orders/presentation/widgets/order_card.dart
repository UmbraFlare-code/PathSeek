import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/order.dart';

class OrderCard extends StatelessWidget {
  const OrderCard({
    super.key,
    required this.order,
    required this.onEdit,
    required this.onDelete,
    this.canEdit = true,
    this.canDelete = true,
  });

  final Order order;
  final ValueChanged<Order> onEdit;
  final ValueChanged<Order> onDelete;
  final bool canEdit;
  final bool canDelete;

  bool get _showActions => canEdit || canDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.inventory_2,
                    color: AppTheme.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.direccion,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: AppTheme.textHighContrast,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        order.clienteId,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF727970),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _PriorityChip(prioridad: order.prioridad),
                OrderStatusChip(estado: order.estado),
                _TipoChip(tipo: order.tipoProducto),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _MiniMetric(
                    label: 'Peso',
                    value: '${Formatters.decimal.format(order.peso)} kg',
                    icon: Icons.scale_outlined,
                  ),
                ),
                Expanded(
                  child: _MiniMetric(
                    label: 'Volumen',
                    value: '${Formatters.decimal.format(order.volumen)} m3',
                    icon: Icons.square_foot_outlined,
                  ),
                ),
                Expanded(
                  child: _MiniMetric(
                    label: 'Ventana',
                    value: '${order.ventanaInicio} - ${order.ventanaFin}',
                    icon: Icons.schedule_outlined,
                  ),
                ),
              ],
            ),
            if (_showActions) ...[
              const SizedBox(height: 8),
              const Divider(height: 1),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (canEdit)
                    TextButton.icon(
                      onPressed: () => onEdit(order),
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('Editar'),
                    ),
                  if (canDelete)
                    TextButton.icon(
                      onPressed: () => onDelete(order),
                      icon: Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      label: Text(
                        'Eliminar',
                        style:
                            TextStyle(color: Theme.of(context).colorScheme.error),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  const _MiniMetric({required this.label, required this.value, required this.icon});

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: const Color(0xFF727970)),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textHighContrast,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                label,
                style: const TextStyle(fontSize: 10, color: Color(0xFF727970)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PriorityChip extends StatelessWidget {
  const _PriorityChip({required this.prioridad});

  final String prioridad;

  @override
  Widget build(BuildContext context) {
    final (color, foreground) = switch (prioridad) {
      'EXPRESS' => (Colors.red.shade100, Colors.red.shade900),
      'ESTANDAR' => (Colors.blue.shade100, Colors.blue.shade900),
      'ECONOMICO' => (Colors.green.shade100, Colors.green.shade900),
      _ => (Colors.grey.shade200, Colors.grey.shade800),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        prioridad,
        style: TextStyle(fontSize: 11, color: foreground),
      ),
    );
  }
}

class _TipoChip extends StatelessWidget {
  const _TipoChip({required this.tipo});

  final String tipo;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        tipo,
        style: const TextStyle(fontSize: 11, color: AppTheme.primaryDark),
      ),
    );
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
        style: TextStyle(fontSize: 11, color: foreground),
      ),
    );
  }
}
