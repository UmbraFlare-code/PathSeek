import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/widgets/empty_view.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_indicator.dart';
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
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Gestion de Pedidos',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: () => context.go('/orders/new'),
                    icon: const Icon(Icons.add),
                    label: const Text('Nuevo pedido'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(child: _buildBody(context, state)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, OrderState state) {
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${state.orders.length} pedidos registrados',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        Expanded(
          child: OrderTable(
            orders: state.orders,
            onEdit: (order) =>
                context.go('/orders/${order.id}/edit', extra: order),
            onDelete: (order) =>
                context.read<OrderBloc>().add(OrderDeleted(order.id)),
          ),
        ),
      ],
    );
  }
}
