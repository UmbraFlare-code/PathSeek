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
import '../../domain/entities/vehicle.dart';
import '../bloc/fleet_bloc.dart';
import '../widgets/vehicle_table.dart';

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

    if (isNarrow(context)) {
      return _VehicleCards(
        vehicles: state.vehicles,
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
            '// ${state.vehicles.length} VEHICULOS REGISTRADOS',
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
              child: VehicleTable(
                vehicles: state.vehicles,
                canEdit: canEdit,
                canDelete: canDelete,
                onEdit: (vehicle) =>
                    context.go('/fleet/${vehicle.id}/edit', extra: vehicle),
                onDelete: (vehicle) => context
                    .read<FleetBloc>()
                    .add(FleetVehicleDeleted(vehicle.id)),
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

class _VehicleCards extends StatelessWidget {
  const _VehicleCards({
    required this.vehicles,
    required this.canEdit,
    required this.canDelete,
  });

  final List<Vehicle> vehicles;
  final bool canEdit;
  final bool canDelete;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: vehicles.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final vehicle = vehicles[index];
        final showActions = canEdit || canDelete;
        return Card(
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: const CircleAvatar(
              backgroundColor: AppTheme.primary,
              child: Icon(Icons.local_shipping, color: Colors.white, size: 20),
            ),
            title: Text(
              '${vehicle.placa} · ${vehicle.tipo}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Cap: ${Formatters.decimal.format(vehicle.capacidadKg)} kg · '
              '${Formatters.decimal.format(vehicle.consumoKmL)} km/L · '
              '${vehicle.anio}',
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
                              '/fleet/${vehicle.id}/edit',
                              extra: vehicle),
                        ),
                      if (canDelete)
                        IconButton(
                          tooltip: 'Eliminar',
                          icon: Icon(
                            Icons.delete_outline,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          onPressed: () =>
                              _confirmDelete(context, vehicle),
                        ),
                    ],
                  )
                : null,
          ),
        );
      },
    );
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
