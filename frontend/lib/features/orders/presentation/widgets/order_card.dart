import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/permissions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/record_details.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
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
  final ValueChanged<Order> onEdit, onDelete;
  final bool canEdit, canDelete;
  @override
  Widget build(BuildContext context) {
    final AppUser? user = () {
      try {
        return context.watch<AuthBloc>().state.user;
      } catch (_) {
        return null;
      }
    }();
    final canViewClients = AppPermissions.canView(user, AppModule.clients);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.inventory_2_outlined,
                  color: AppTheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.direccion,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      if (canViewClients)
                        InkWell(
                          onTap: () => context.go('/clients'),
                          borderRadius: BorderRadius.circular(4),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.storefront_outlined,
                                  size: 14,
                                  color: AppTheme.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Cliente: ${order.clienteId}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: AppTheme.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        Text(
                          'Cliente: ${order.clienteId}',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppTheme.mutedText),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              StatusBadge(
                label: switch (order.prioridad) {
                  'ESTANDAR' => 'Estándar',
                  'ECONOMICO' => 'Económico',
                  'EXPRESS' => 'Express',
                  _ => order.prioridad,
                },
                icon: Icons.flag_outlined,
                tone: order.prioridad == 'EXPRESS'
                    ? StatusTone.warning
                    : StatusTone.neutral,
              ),
              OrderStatusChip(estado: order.estado),
              StatusBadge(
                label: switch (order.tipoProducto) {
                  'PERECEDERO' => 'Perecedero',
                  'NO_PERECEDERO' => 'No perecedero',
                  _ => order.tipoProducto,
                },
                icon: Icons.category_outlined,
              ),
            ],
          ),
          const SizedBox(height: 20),
          RecordDetails(
            items: {
              'Peso': '${Formatters.decimal.format(order.peso)} kg',
              'Volumen': '${Formatters.decimal.format(order.volumen)} m³',
              'Ventana de entrega':
                  '${order.ventanaInicio} – ${order.ventanaFin}',
            },
          ),
          RecordActions(
            onEdit: canEdit ? () => onEdit(order) : null,
            onDelete: canDelete ? () => onDelete(order) : null,
          ),
        ],
      ),
    ),
  );
}
}

class OrderStatusChip extends StatelessWidget {
  const OrderStatusChip({super.key, required this.estado});
  final String estado;
  @override
  Widget build(BuildContext context) {
    final (label, icon, tone) = switch (estado) {
      'PENDIENTE' => ('Pendiente', Icons.schedule_outlined, StatusTone.warning),
      'PLANIFICADO' => (
        'Planificado',
        Icons.event_note_outlined,
        StatusTone.info,
      ),
      'EN_RUTA' => ('En ruta', Icons.local_shipping_outlined, StatusTone.info),
      'ENTREGADO' => (
        'Entregado',
        Icons.check_circle_outline,
        StatusTone.success,
      ),
      'CANCELADO' => ('Cancelado', Icons.cancel_outlined, StatusTone.danger),
      _ => (estado, Icons.info_outline, StatusTone.neutral),
    };
    return StatusBadge(label: label, icon: icon, tone: tone);
  }
}
