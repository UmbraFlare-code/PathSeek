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
import '../../domain/entities/driver.dart';
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

    if (isNarrow(context)) {
      return _DriverCards(
        drivers: state.drivers,
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
                canEdit: canEdit,
                canDelete: canDelete,
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

class _DriverCards extends StatelessWidget {
  const _DriverCards({
    required this.drivers,
    required this.canEdit,
    required this.canDelete,
  });

  final List<Driver> drivers;
  final bool canEdit;
  final bool canDelete;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: drivers.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final driver = drivers[index];
        final showActions = canEdit || canDelete;
        return Card(
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: driver.disponible
                  ? AppTheme.primary
                  : Theme.of(context).colorScheme.error,
              child: Icon(
                driver.disponible ? Icons.badge : Icons.badge_outlined,
                color: Colors.white,
                size: 20,
              ),
            ),
            title: Text(
              driver.nombre,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '${driver.dni} · Lic. ${driver.licencia} (${driver.categoria}) · '
              '${Formatters.integer.format(driver.experiencia)} anios',
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
                              '/drivers/${driver.id}/edit',
                              extra: driver),
                        ),
                      if (canDelete)
                        IconButton(
                          tooltip: 'Eliminar',
                          icon: Icon(
                            Icons.delete_outline,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          onPressed: () =>
                              _confirmDelete(context, driver),
                        ),
                    ],
                  )
                : null,
          ),
        );
      },
    );
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
