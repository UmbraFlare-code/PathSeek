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
                          onPressed: () => context.go('/fleet/new'),
                          icon: const Icon(Icons.add),
                          label: const Text('Nuevo vehiculo'),
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
                        onPressed: () => context.go('/fleet/new'),
                        icon: const Icon(Icons.add),
                        label: const Text('Nuevo vehiculo'),
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
        Text(
          '// ${filtered.length} DE ${widget.vehicles.length} VEHICULOS',
          style: const TextStyle(
            color: AppTheme.primaryDark,
            fontWeight: FontWeight.bold,
            fontSize: 12,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 12),
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
                mainAxisExtent: narrow ? 230 : 215,
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
        title: const Text('Eliminar vehiculo'),
        content: Text(
            'Seguro que desea eliminar el vehiculo con placa ${vehicle.placa}?'),
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
        'GESTIÓN DE FLOTA',
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
