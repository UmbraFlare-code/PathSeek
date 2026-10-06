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
                          onPressed: () => context.go('/drivers/new'),
                          icon: const Icon(Icons.add),
                          label: const Text('Nuevo conductor'),
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
                        onPressed: () => context.go('/drivers/new'),
                        icon: const Icon(Icons.add),
                        label: const Text('Nuevo conductor'),
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
        Text(
          '// ${filtered.length} DE ${widget.drivers.length} CONDUCTORES',
          style: const TextStyle(
            color: AppTheme.primaryDark,
            fontWeight: FontWeight.bold,
            fontSize: 12,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 12),
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
                mainAxisExtent: narrow ? 225 : 210,
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
            'Seguro que desea eliminar al conductor ${driver.nombre} (${driver.dni})?'),
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
        'GESTIÓN DE CONDUCTORES',
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
