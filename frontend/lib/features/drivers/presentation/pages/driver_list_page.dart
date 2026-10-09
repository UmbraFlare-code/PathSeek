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
import '../../domain/entities/driver.dart';
import '../bloc/driver_bloc.dart';
import '../driver_filters.dart';
import '../widgets/driver_card.dart';

class DriverListPage extends StatelessWidget {
  const DriverListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DriverBloc>(
      create: (_) => locator<DriverBloc>()..add(const DriversLoaded()),
      child: const DriverListView(),
    );
  }
}

class DriverListView extends StatelessWidget {
  const DriverListView({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthBloc>().state.user;
    final canCreate = AppPermissions.canCreate(user, AppModule.drivers);
    final canEdit = AppPermissions.canUpdate(user, AppModule.drivers);
    final canDelete = AppPermissions.canDelete(user, AppModule.drivers);
    final narrow = isNarrow(context);

    return BlocConsumer<DriverBloc, DriverState>(
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
          padding: EdgeInsets.all(narrow ? 14 : 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (narrow)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _DriverHeader(),
                    const SizedBox(height: 12),
                    if (canCreate)
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () => context.go('/drivers/new'),
                          icon: const Icon(Icons.add_rounded, size: 18),
                          label: const Text('Nuevo conductor'),
                        ),
                      ),
                  ],
                )
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Expanded(child: _DriverHeader()),
                    if (canCreate)
                      FilledButton.icon(
                        onPressed: () => context.go('/drivers/new'),
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text('Nuevo conductor'),
                      ),
                  ],
                ),
              const SizedBox(height: 16),
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
    DriverState state,
    bool canEdit,
    bool canDelete,
  ) {
    if (state.isLoading) {
      return const LoadingIndicator(message: 'Cargando conductores...');
    }

    if (state.hasError) {
      return ErrorView(
        message: state.errorMessage!,
        onRetry: () => context.read<DriverBloc>().add(const DriversLoaded()),
      );
    }

    if (state.isEmpty) {
      return const EmptyView(
        message: 'Aun no hay conductores registrados.',
        icon: Icons.badge_outlined,
      );
    }

    return _DriverFilteredGrid(
      drivers: state.drivers,
      canEdit: canEdit,
      canDelete: canDelete,
    );
  }
}

class _DriverHeader extends StatelessWidget {
  const _DriverHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: AppTheme.accent,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'GESTIÓN DE CONDUCTORES',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w400,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        const Text(
          'Registro de Conductores',
          style: TextStyle(
            color: AppTheme.textHighContrast,
            fontSize: 20,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          'Licencias, turnos asignados y disponibilidad operativa',
          style: TextStyle(
            color: AppTheme.textMuted,
            fontSize: 12.5,
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
    );
  }
}

class _DriverFilteredGrid extends StatefulWidget {
  const _DriverFilteredGrid({
    required this.drivers,
    required this.canEdit,
    required this.canDelete,
  });

  final List<Driver> drivers;
  final bool canEdit;
  final bool canDelete;

  @override
  State<_DriverFilteredGrid> createState() => _DriverFilteredGridState();
}

class _DriverFilteredGridState extends State<_DriverFilteredGrid> {
  final _queryController = TextEditingController();
  DriverSort _sort = DriverSort.nombre;

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final narrow = isNarrow(context);
    final filtered = sortDrivers(
      filterDrivers(widget.drivers, _queryController.text),
      _sort,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '${filtered.length} de ${widget.drivers.length} conductores registrados',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w400,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SearchSortControls<DriverSort>(
          queryController: _queryController,
          hint: 'Buscar por nombre, DNI o licencia',
          sortItems: const {
            DriverSort.nombre: 'Ordenar: Nombre',
            DriverSort.experiencia: 'Ordenar: Experiencia',
          },
          sortValue: _sort,
          onQueryChanged: () => setState(() {}),
          onSortChanged: (value) => setState(() => _sort = value),
        ),
        const SizedBox(height: 14),
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
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                mainAxisExtent: narrow ? 210 : 195,
              ),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final driver = filtered[index];
                return DriverCard(
                  driver: driver,
                  canEdit: widget.canEdit,
                  canDelete: widget.canDelete,
                  onEdit: (driver) => context
                      .go('/drivers/${driver.id}/edit', extra: driver),
                  onDelete: (driver) => _confirmDelete(context, driver),
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

  Future<void> _confirmDelete(BuildContext context, Driver driver) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar conductor'),
        content: Text(
            '¿Seguro que desea eliminar al conductor ${driver.nombre} (${driver.dni})?'),
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
      context.read<DriverBloc>().add(DriverDeleted(driver.id));
    }
  }
}
