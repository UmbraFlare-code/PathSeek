import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/permissions.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/catalog_layout.dart';
import '../../../../core/widgets/search_sort_controls.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/order.dart';
import '../bloc/order_bloc.dart';
import '../order_filters.dart';
import '../widgets/order_card.dart';

class OrderListPage extends StatelessWidget {
  const OrderListPage({super.key});
  @override
  Widget build(BuildContext context) => BlocProvider<OrderBloc>(
    create: (_) => locator<OrderBloc>()..add(const OrdersLoaded()),
    child: const OrderListView(),
  );
}

class OrderListView extends StatefulWidget {
  const OrderListView({super.key});
  @override
  State<OrderListView> createState() => _OrderListViewState();
}

class _OrderListViewState extends State<OrderListView> {
  final _queryController = TextEditingController();
  OrderSort _sort = OrderSort.prioridad;
  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthBloc>().state.user;
    final canCreate = AppPermissions.canCreate(user, AppModule.orders);
    final canEdit = AppPermissions.canUpdate(user, AppModule.orders);
    final canDelete = AppPermissions.canDelete(user, AppModule.orders);
    return BlocConsumer<OrderBloc, OrderState>(
      listenWhen: (previous, current) =>
          current.hasSaveError &&
          previous.saveErrorMessage != current.saveErrorMessage,
      listener: (context, state) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(state.saveErrorMessage!),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
      },
      builder: (context, state) {
        final filtered = sortOrders(
          filterOrders(state.orders, _queryController.text),
          _sort,
        );
        return CatalogLayout(
          title: user?.rol == 'CLIENTE'
              ? 'Mis pedidos'
              : 'Pedidos de distribución',
          description: 'Consulta entregas, prioridades y ventanas de atención.',
          icon: Icons.inventory_2_outlined,
          actions: [
            OutlinedButton.icon(
              onPressed: state.isLoading
                  ? null
                  : () => context.read<OrderBloc>().add(const OrdersLoaded()),
              icon: const Icon(Icons.refresh),
              label: const Text('Actualizar'),
            ),
            if (canCreate)
              FilledButton.icon(
                onPressed: () => context.go('/orders/new'),
                icon: const Icon(Icons.add),
                label: const Text('Nuevo pedido'),
              ),
          ],
          isLoading: state.isLoading,
          loadingMessage: 'Cargando registros…',
          errorMessage: state.errorMessage,
          onRetry: () => context.read<OrderBloc>().add(const OrdersLoaded()),
          toolbar: SearchSortControls<OrderSort>(
            queryController: _queryController,
            hint: 'Dirección o cliente',
            sortItems: const {
              OrderSort.prioridad: 'Prioridad',
              OrderSort.ventana: 'Ventana de entrega',
              OrderSort.estado: 'Estado',
            },
            sortValue: _sort,
            onQueryChanged: () => setState(() {}),
            onSortChanged: (value) => setState(() => _sort = value),
          ),
          totalCount: state.orders.length,
          itemCount: filtered.length,
          emptyMessage: state.orders.isEmpty
              ? 'Aún no hay pedidos registrados.'
              : 'No hay resultados para tu búsqueda. Prueba con otro término.',
          itemBuilder: (context, index) => OrderCard(
            order: filtered[index],
            canEdit: canEdit,
            canDelete: canDelete,
            onEdit: (item) =>
                context.go('/orders/${item.id}/edit', extra: item),
            onDelete: (item) => _confirmDelete(context, item),
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, Order item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: const Text('Eliminar pedido'),
        content: Text(
          '¿Deseas eliminar el pedido con dirección "${item.direccion}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialog, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialog).colorScheme.error,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<OrderBloc>().add(OrderDeleted(item.id));
    }
  }
}
