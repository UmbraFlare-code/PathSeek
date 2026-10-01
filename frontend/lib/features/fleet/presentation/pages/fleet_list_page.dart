import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/empty_view.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_indicator.dart';
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
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
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
                  ),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: () => context.go('/fleet/new'),
                    icon: const Icon(Icons.add),
                    label: const Text('Nuevo vehículo'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(child: _buildBody(context, state)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, FleetState state) {
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
        message: 'Aún no hay vehículos registrados.',
        icon: Icons.local_shipping_outlined,
      );
    }

    return _FleetTableWithCount(vehicles: state.vehicles);
  }
}

class _FleetTableWithCount extends StatelessWidget {
  const _FleetTableWithCount({required this.vehicles});

  final List<Vehicle> vehicles;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            '// ${vehicles.length} VEHÍCULOS REGISTRADOS',
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
                vehicles: vehicles,
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
