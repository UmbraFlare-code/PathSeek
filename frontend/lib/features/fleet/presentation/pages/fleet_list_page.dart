import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
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
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Gestion de Flota',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: () => context.go('/fleet/new'),
                    icon: const Icon(Icons.add),
                    label: const Text('Nuevo vehiculo'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
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
        message: 'Aun no hay vehiculos registrados.',
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
        Text(
          '${vehicles.length} vehiculos registrados',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        Expanded(
          child: VehicleTable(
            vehicles: vehicles,
            onEdit: (vehicle) =>
                context.go('/fleet/${vehicle.id}/edit', extra: vehicle),
            onDelete: (vehicle) =>
                context.read<FleetBloc>().add(FleetVehicleDeleted(vehicle.id)),
          ),
        ),
      ],
    );
  }
}
