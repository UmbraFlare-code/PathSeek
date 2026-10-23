import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/permissions.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/catalog_layout.dart';
import '../../../../core/widgets/search_sort_controls.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/vehicle.dart';
import '../bloc/fleet_bloc.dart';
import '../vehicle_filters.dart';
import '../widgets/vehicle_card.dart';

class FleetListPage extends StatelessWidget {
  const FleetListPage({super.key});
  @override
  Widget build(BuildContext context) => BlocProvider<FleetBloc>(
    create: (_) => locator<FleetBloc>()..add(const FleetLoaded()),
    child: const FleetListView(),
  );
}

class FleetListView extends StatefulWidget {
  const FleetListView({super.key});
  @override
  State<FleetListView> createState() => _FleetListViewState();
}

class _FleetListViewState extends State<FleetListView> {
  final _queryController = TextEditingController();
  VehicleSort _sort = VehicleSort.placa;
  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthBloc>().state.user;
    final canCreate = AppPermissions.canCreate(user, AppModule.fleet);
    final canEdit = AppPermissions.canUpdate(user, AppModule.fleet);
    final canDelete = AppPermissions.canDelete(user, AppModule.fleet);
    return BlocConsumer<FleetBloc, FleetState>(
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
        final filtered = sortVehicles(
          filterVehicles(state.vehicles, _queryController.text),
          _sort,
        );
        return CatalogLayout(
          title: 'Flota de distribución',
          description:
              'Consulta capacidades, consumo y emisiones de los vehículos.',
          icon: Icons.local_shipping_outlined,
          actions: [
            OutlinedButton.icon(
              onPressed: state.isLoading
                  ? null
                  : () => context.read<FleetBloc>().add(const FleetLoaded()),
              icon: const Icon(Icons.refresh),
              label: const Text('Actualizar'),
            ),
            if (canCreate)
              FilledButton.icon(
                onPressed: () => context.go('/fleet/new'),
                icon: const Icon(Icons.add),
                label: const Text('Nuevo vehículo'),
              ),
          ],
          isLoading: state.isLoading,
          loadingMessage: 'Cargando registros…',
          errorMessage: state.errorMessage,
          onRetry: () => context.read<FleetBloc>().add(const FleetLoaded()),
          toolbar: SearchSortControls<VehicleSort>(
            queryController: _queryController,
            hint: 'Placa o tipo de vehículo',
            sortItems: const {
              VehicleSort.placa: 'Placa',
              VehicleSort.anio: 'Año de fabricación',
              VehicleSort.capacidad: 'Capacidad',
            },
            sortValue: _sort,
            onQueryChanged: () => setState(() {}),
            onSortChanged: (value) => setState(() => _sort = value),
          ),
          totalCount: state.vehicles.length,
          itemCount: filtered.length,
          emptyMessage: state.vehicles.isEmpty
              ? 'Aún no hay vehículos registrados.'
              : 'No hay resultados para tu búsqueda. Prueba con otro término.',
          itemBuilder: (context, index) => VehicleCard(
            vehicle: filtered[index],
            canEdit: canEdit,
            canDelete: canDelete,
            onEdit: (item) => context.go('/fleet/${item.id}/edit', extra: item),
            onDelete: (item) => _confirmDelete(context, item),
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, Vehicle item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: const Text('Eliminar vehículo'),
        content: Text('¿Deseas eliminar el vehículo ${item.placa}?'),
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
      context.read<FleetBloc>().add(FleetVehicleDeleted(item.id));
    }
  }
}
