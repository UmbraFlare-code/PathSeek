import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/empty_view.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../bloc/driver_bloc.dart';
import '../widgets/driver_table.dart';

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
                      'GESTIÓN DE CONDUCTORES',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.black,
                        fontSize: 20,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: () => context.go('/drivers/new'),
                    icon: const Icon(Icons.add),
                    label: const Text('Nuevo conductor'),
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

  Widget _buildBody(BuildContext context, DriverState state) {
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
        message: 'Aún no hay conductores registrados.',
        icon: Icons.badge_outlined,
      );
    }

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
            '// ${state.drivers.length} CONDUCTORES REGISTRADOS',
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
              child: DriverTable(
                drivers: state.drivers,
                onEdit: (driver) =>
                    context.go('/drivers/${driver.id}/edit', extra: driver),
                onDelete: (driver) =>
                    context.read<DriverBloc>().add(DriverDeleted(driver.id)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
