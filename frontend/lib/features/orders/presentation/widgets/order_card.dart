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
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppTheme.border,
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Center(
                  child: Icon(
                    Icons.inventory_2_outlined,
                    color: AppTheme.primary,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.direccion,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        letterSpacing: 0.1,
                        color: AppTheme.textHighContrast,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Cliente: ${order.clienteId}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w300,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              _PriorityChip(prioridad: order.prioridad),
              OrderStatusChip(estado: order.estado),
              _TipoChip(tipo: order.tipoProducto),
            ],
          ),
          const SizedBox(height: 10),
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
                  value: '${Formatters.decimal.format(order.volumen)} m³',
                  icon: Icons.square_foot_outlined,
                ),
              ),
              Expanded(
                child: _MiniMetric(
                  label: 'Ventana',
                  value: '${order.ventanaInicio}-${order.ventanaFin}',
                  icon: Icons.schedule_outlined,
                ),
              ),
            ],
          ),
          if (_showActions) ...[
            const SizedBox(height: 8),
            const Divider(height: 1, thickness: 1, color: AppTheme.border),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (canEdit)
                  TextButton.icon(
                    onPressed: () => onEdit(order),
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('Editar', style: TextStyle(fontSize: 12)),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: const Size(0, 32),
                    ),
                  ),
                if (canDelete)
                  TextButton.icon(
                    onPressed: () => onDelete(order),
                    icon: Icon(
                      Icons.delete_outline,
                      size: 16,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    label: Text(
                      'Eliminar',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: const Size(0, 32),
                    ),
                  ),
              ],
            ),
          ],
        ],
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
        Icon(icon, size: 14, color: AppTheme.textMuted),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textHighContrast,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.textMuted,
                ),
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
    final (bg, fg, border) = switch (prioridad) {
      'EXPRESS' => (const Color(0xFFFDF2F2), const Color(0xFFB91C1C), const Color(0xFFFCA5A5)),
      'ESTANDAR' => (const Color(0xFFEFF6FF), const Color(0xFF1D4ED8), const Color(0xFFBFDBFE)),
      'ECONOMICO' => (const Color(0xFFF0FDF4), const Color(0xFF15803D), const Color(0xFFBBF7D0)),
      _ => (const Color(0xFFF3F4F6), const Color(0xFF374151), const Color(0xFFE5E7EB)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: border, width: 0.8),
      ),
      child: Text(
        prioridad,
        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w500, color: fg),
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
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F5F1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFD6E3D8), width: 0.8),
      ),
      child: Text(
        tipo,
        style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w400, color: AppTheme.primary),
      ),
    );
  }
}

class OrderStatusChip extends StatelessWidget {
  const OrderStatusChip({super.key, required this.estado});

  final String estado;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, border) = switch (estado) {
      'PENDIENTE' => (const Color(0xFFFFFBEB), const Color(0xFFB45309), const Color(0xFFFDE68A)),
      'PLANIFICADO' => (const Color(0xFFEFF6FF), const Color(0xFF1D4ED8), const Color(0xFFBFDBFE)),
      'EN_RUTA' => (const Color(0xFFEEF2FF), const Color(0xFF4338CA), const Color(0xFFC7D2FE)),
      'ENTREGADO' => (const Color(0xFFF0FDF4), const Color(0xFF15803D), const Color(0xFFBBF7D0)),
      'CANCELADO' => (const Color(0xFFFDF2F2), const Color(0xFFB91C1C), const Color(0xFFFCA5A5)),
      _ => (const Color(0xFFF3F4F6), const Color(0xFF374151), const Color(0xFFE5E7EB)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: border, width: 0.8),
      ),
      child: Text(
        estado,
        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w500, color: fg),
      ),
    );
  }
}
