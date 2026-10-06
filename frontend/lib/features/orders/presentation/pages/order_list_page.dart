import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/permissions.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/empty_view.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/order.dart';
import '../bloc/order_bloc.dart';
import '../widgets/order_table.dart';

class OrderListPage extends StatelessWidget {
  const OrderListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<OrderBloc>(
      create: (_) => locator<OrderBloc>()..add(const OrdersLoaded()),
      child: const OrderListView(),
    );
  }
}

class OrderListView extends StatelessWidget {
  const OrderListView({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthBloc>().state.user;
    final canCreate = AppPermissions.canCreate(user, AppModule.orders);
    final canEdit = AppPermissions.canUpdate(user, AppModule.orders);
    final canDelete = AppPermissions.canDelete(user, AppModule.orders);
    final narrow = isNarrow(context);

    return BlocConsumer<OrderBloc, OrderState>(
      listener: (context, state) {
        if (state.hasSaveError) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.saveErrorMessage!),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
        }
      },
      builder: (context, state) {
        return Padding(
          padding: EdgeInsets.all(narrow ? 16 : 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (narrow)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _TitleBadge(),
                    const SizedBox(height: 12),
                    if (canCreate)
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () => context.go('/orders/new'),
                          icon: const Icon(Icons.add),
                          label: const Text('Nuevo pedido'),
                        ),
                      ),
                  ],
                )
              else
                Row(
                  children: [
                    const _TitleBadge(),
                    const Spacer(),
                    if (canCreate)
                      FilledButton.icon(
                        onPressed: () => context.go('/orders/new'),
                        icon: const Icon(Icons.add),
                        label: const Text('Nuevo pedido'),
                      ),
                  ],
                ),
              const SizedBox(height: 20),
              Expanded(
                child: _buildBody(context, state, canEdit, canDelete),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    OrderState state,
    bool canEdit,
    bool canDelete,
  ) {
    if (state.isLoading) {
      return const LoadingIndicator(message: 'Cargando pedidos...');
    }

    if (state.hasError) {
      return ErrorView(
        message: state.errorMessage!,
        onRetry: () => context.read<OrderBloc>().add(const OrdersLoaded()),
      );
    }

    if (state.isEmpty) {
      return const EmptyView(
        message: 'Aun no hay pedidos registrados.',
        icon: Icons.inventory_2_outlined,
      );
    }

    if (isNarrow(context)) {
      return _OrderCards(
        orders: state.orders,
        canEdit: canEdit,
        canDelete: canDelete,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            '// ${state.orders.length} PEDIDOS REGISTRADOS',
            style: const TextStyle(
              color: AppTheme.primaryDark,
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 1.0,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: OrderTable(
                orders: state.orders,
                canEdit: canEdit,
                canDelete: canDelete,
                onEdit: (order) =>
                    context.go('/orders/${order.id}/edit', extra: order),
                onDelete: (order) =>
                    context.read<OrderBloc>().add(OrderDeleted(order.id)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TitleBadge extends StatelessWidget {
  const _TitleBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.primaryDark,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text(
        'GESTIÓN DE PEDIDOS',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 20,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _OrderCards extends StatelessWidget {
  const _OrderCards({
    required this.orders,
    required this.canEdit,
    required this.canDelete,
  });

  final List<Order> orders;
  final bool canEdit;
  final bool canDelete;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: orders.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final order = orders[index];
        final showActions = canEdit || canDelete;
        return Card(
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: const CircleAvatar(
              backgroundColor: AppTheme.primary,
              child: Icon(Icons.inventory_2, color: Colors.white, size: 20),
            ),
            title: Text(
              order.direccion,
              style: const TextStyle(fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${order.prioridad} · ${order.tipoProducto} · '
                  '${Formatters.decimal.format(order.peso)} kg',
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text('${order.ventanaInicio} - ${order.ventanaFin}'),
                    const SizedBox(width: 8),
                    OrderStatusChip(estado: order.estado),
                  ],
                ),
              ],
            ),
            trailing: showActions
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (canEdit)
                        IconButton(
                          tooltip: 'Editar',
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () => context.go(
                              '/orders/${order.id}/edit',
                              extra: order),
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
                  )
                : null,
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, Order order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar pedido'),
        content: Text(
            'Seguro que desea eliminar el pedido con direccion "${order.direccion}"?'),
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

    if (confirmed == true && context.mounted) {
      context.read<OrderBloc>().add(OrderDeleted(order.id));
    }
  }
}
