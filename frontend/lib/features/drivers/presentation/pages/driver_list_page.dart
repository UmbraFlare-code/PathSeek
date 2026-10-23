import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/permissions.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/catalog_layout.dart';
import '../../../../core/widgets/search_sort_controls.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/driver.dart';
import '../bloc/driver_bloc.dart';
import '../driver_filters.dart';
import '../widgets/driver_card.dart';

class DriverListPage extends StatelessWidget {
  const DriverListPage({super.key});
  @override
  Widget build(BuildContext context) => BlocProvider<DriverBloc>(
    create: (_) => locator<DriverBloc>()..add(const DriversLoaded()),
    child: const DriverListView(),
  );
}

class DriverListView extends StatefulWidget {
  const DriverListView({super.key});
  @override
  State<DriverListView> createState() => _DriverListViewState();
}

class _DriverListViewState extends State<DriverListView> {
  final _queryController = TextEditingController();
  DriverSort _sort = DriverSort.nombre;
  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthBloc>().state.user;
    final canCreate = AppPermissions.canCreate(user, AppModule.drivers);
    final canEdit = AppPermissions.canUpdate(user, AppModule.drivers);
    final canDelete = AppPermissions.canDelete(user, AppModule.drivers);
    return BlocConsumer<DriverBloc, DriverState>(
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
        final filtered = sortDrivers(
          filterDrivers(state.drivers, _queryController.text),
          _sort,
        );
        return CatalogLayout(
          title: 'Conductores',
          description:
              'Gestiona licencias, experiencia y disponibilidad para la distribución.',
          icon: Icons.badge_outlined,
          actions: [
            OutlinedButton.icon(
              onPressed: state.isLoading
                  ? null
                  : () => context.read<DriverBloc>().add(const DriversLoaded()),
              icon: const Icon(Icons.refresh),
              label: const Text('Actualizar'),
            ),
            if (canCreate)
              FilledButton.icon(
                onPressed: () => context.go('/drivers/new'),
                icon: const Icon(Icons.add),
                label: const Text('Nuevo conductor'),
              ),
          ],
          isLoading: state.isLoading,
          loadingMessage: 'Cargando registros…',
          errorMessage: state.errorMessage,
          onRetry: () => context.read<DriverBloc>().add(const DriversLoaded()),
          toolbar: SearchSortControls<DriverSort>(
            queryController: _queryController,
            hint: 'Nombre, DNI o licencia',
            sortItems: const {
              DriverSort.nombre: 'Nombre',
              DriverSort.experiencia: 'Experiencia',
            },
            sortValue: _sort,
            onQueryChanged: () => setState(() {}),
            onSortChanged: (value) => setState(() => _sort = value),
          ),
          totalCount: state.drivers.length,
          itemCount: filtered.length,
          emptyMessage: state.drivers.isEmpty
              ? 'Aún no hay conductores registrados.'
              : 'No hay resultados para tu búsqueda. Prueba con otro término.',
          itemBuilder: (context, index) => DriverCard(
            driver: filtered[index],
            canEdit: canEdit,
            canDelete: canDelete,
            onEdit: (item) =>
                context.go('/drivers/${item.id}/edit', extra: item),
            onDelete: (item) => _confirmDelete(context, item),
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, Driver item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: const Text('Eliminar conductor'),
        content: Text(
          '¿Deseas eliminar al conductor ${item.nombre} (${item.dni})?',
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
      context.read<DriverBloc>().add(DriverDeleted(item.id));
    }
  }
}
