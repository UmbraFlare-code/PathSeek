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
import '../../domain/entities/vehicle.dart';
import '../bloc/fleet_bloc.dart';
import '../vehicle_filters.dart';
import '../widgets/vehicle_card.dart';

class FleetListPage extends StatelessWidget {
  const FleetListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FleetBloc>(
      create: (_) => locator<FleetBloc>()..add(const FleetLoaded()),
      child: const FleetListView(),
    );
  }
}

class FleetListView extends StatelessWidget {
  const FleetListView({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthBloc>().state.user;
    final canCreate = AppPermissions.canCreate(user, AppModule.fleet);
    final canEdit = AppPermissions.canUpdate(user, AppModule.fleet);
    final canDelete = AppPermissions.canDelete(user, AppModule.fleet);
    final narrow = isNarrow(context);

    return BlocConsumer<FleetBloc, FleetState>(
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
                    const _FleetHeader(),
                    const SizedBox(height: 12),
                    if (canCreate)
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () => context.go('/fleet/new'),
                          icon: const Icon(Icons.add_rounded, size: 18),
                          label: const Text('Nuevo vehículo'),
                        ),
                      ),
                  ],
                )
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Expanded(child: _FleetHeader()),
                    if (canCreate)
                      FilledButton.icon(
                        onPressed: () => context.go('/fleet/new'),
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text('Nuevo vehículo'),
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
    FleetState state,
    bool canEdit,
    bool canDelete,
  ) {
    if (state.isLoading) {
      return const LoadingIndicator(message: 'Cargando flota...');
    }

    if (state.hasError) {
      return ErrorView(
        message: state.errorMessage!,
        onRetry: () => context.read<FleetBloc>().add(const FleetLoaded()),
      );
    }

    if (state.isEmpty) {
      return const EmptyView(
        message: 'Aun no hay vehiculos registrados.',
        icon: Icons.local_shipping_outlined,
      );
    }

    return _FleetFilteredGrid(
      vehicles: state.vehicles,
      canEdit: canEdit,
      canDelete: canDelete,
    );
  }
}

class _FleetHeader extends StatelessWidget {
  const _FleetHeader();

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
              'GESTIÓN DE FLOTA',
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
          'Control de Flota y Vehículos',
          style: TextStyle(
            color: AppTheme.textHighContrast,
            fontSize: 20,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          'Capacidades de carga, rendimiento y registro de emisiones',
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

class _FleetFilteredGrid extends StatefulWidget {
  const _FleetFilteredGrid({
    required this.vehicles,
    required this.canEdit,
    required this.canDelete,
  });

  final List<Vehicle> vehicles;
  final bool canEdit;
  final bool canDelete;

  @override
  State<_FleetFilteredGrid> createState() => _FleetFilteredGridState();
}

class _FleetFilteredGridState extends State<_FleetFilteredGrid> {
  final _queryController = TextEditingController();
  VehicleSort _sort = VehicleSort.placa;

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final narrow = isNarrow(context);
    final filtered = sortVehicles(
      filterVehicles(widget.vehicles, _queryController.text),
      _sort,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '${filtered.length} de ${widget.vehicles.length} vehículos registrados',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w400,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SearchSortControls<VehicleSort>(
          queryController: _queryController,
          hint: 'Buscar por placa o tipo',
          sortItems: const {
            VehicleSort.placa: 'Ordenar: Placa',
            VehicleSort.anio: 'Ordenar: Anio',
            VehicleSort.capacidad: 'Ordenar: Capacidad',
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
                final vehicle = filtered[index];
                return VehicleCard(
                  vehicle: vehicle,
                  canEdit: widget.canEdit,
                  canDelete: widget.canDelete,
                  onEdit: (vehicle) => context
                      .go('/fleet/${vehicle.id}/edit', extra: vehicle),
                  onDelete: (vehicle) => _confirmDelete(context, vehicle),
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

  Future<void> _confirmDelete(BuildContext context, Vehicle vehicle) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar vehículo'),
        content: Text(
            '¿Seguro que desea eliminar el vehículo con placa ${vehicle.placa}?'),
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
      context.read<FleetBloc>().add(FleetVehicleDeleted(vehicle.id));
    }
  }
}
