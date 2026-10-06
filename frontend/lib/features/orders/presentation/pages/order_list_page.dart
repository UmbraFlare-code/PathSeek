import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/permissions.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/empty_view.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/search_sort_controls.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/order.dart';
import '../bloc/order_bloc.dart';
import '../order_filters.dart';
import '../widgets/order_card.dart';

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

    return _OrderFilteredGrid(
      orders: state.orders,
      canEdit: canEdit,
      canDelete: canDelete,
    );
  }
}

class _OrderFilteredGrid extends StatefulWidget {
  const _OrderFilteredGrid({
    required this.orders,
    required this.canEdit,
    required this.canDelete,
  });

  final List<Order> orders;
  final bool canEdit;
  final bool canDelete;

  @override
  State<_OrderFilteredGrid> createState() => _OrderFilteredGridState();
}

class _OrderFilteredGridState extends State<_OrderFilteredGrid> {
  final _queryController = TextEditingController();
  OrderSort _sort = OrderSort.prioridad;

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final narrow = isNarrow(context);
    final filtered = sortOrders(
      filterOrders(widget.orders, _queryController.text),
      _sort,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '// ${filtered.length} DE ${widget.orders.length} PEDIDOS',
          style: const TextStyle(
            color: AppTheme.primaryDark,
            fontWeight: FontWeight.bold,
            fontSize: 12,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 12),
        SearchSortControls<OrderSort>(
          queryController: _queryController,
          hint: 'Buscar por direccion o cliente',
          sortItems: const {
            OrderSort.prioridad: 'Ordenar: Prioridad',
            OrderSort.ventana: 'Ordenar: Ventana',
            OrderSort.estado: 'Ordenar: Estado',
          },
          sortValue: _sort,
          onQueryChanged: () => setState(() {}),
          onSortChanged: (value) => setState(() => _sort = value),
        ),
        const SizedBox(height: 16),
        if (filtered.isEmpty)
          const Expanded(
            child: EmptyView(
              message: 'Sin resultados para la busqueda.',
              icon: Icons.search_off_outlined,
            ),
          )
        else
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.zero,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _columnsFor(context),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                mainAxisExtent: narrow ? 250 : 240,
              ),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final order = filtered[index];
                return OrderCard(
                  order: order,
                  canEdit: widget.canEdit,
                  canDelete: widget.canDelete,
                  onEdit: (order) =>
                      context.go('/orders/${order.id}/edit', extra: order),
                  onDelete: (order) => _confirmDelete(context, order),
                );
              },
            ),
          ),
      ],
    );
  }

  int _columnsFor(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < 600) return 1;
    if (width < 1000) return 2;
    if (width < 1400) return 3;
    return 4;
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
