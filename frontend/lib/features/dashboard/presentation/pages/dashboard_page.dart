import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/permissions.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/empty_view.dart';
import '../../../../core/widgets/page_header.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/dashboard_summary.dart';
import '../bloc/dashboard_bloc.dart';
import '../widgets/kpi_card.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DashboardBloc>(
      create: (_) => locator<DashboardBloc>()..add(const DashboardLoaded()),
      child: const DashboardView(),
    );
  }
}

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        return RefreshIndicator(
          onRefresh: () async =>
              context.read<DashboardBloc>().add(const DashboardLoaded()),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(isNarrow(context) ? 16 : 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HeaderBadge(),
                const SizedBox(height: 20),
                if (state.isLoading)
                  const LoadingIndicator(message: 'Cargando indicadores...')
                else if (state.hasError)
                  ErrorView(
                    message: state.errorMessage!,
                    onRetry: () => context.read<DashboardBloc>().add(
                      const DashboardLoaded(),
                    ),
                  )
                else if (state.summary == null || !state.summary!.hasData)
                  EmptyView(
                    message:
                        AppPermissions.canCreate(
                          context.watch<AuthBloc>().state.user,
                          AppModule.routes,
                        )
                        ? 'Aún no hay datos de operación. Genera rutas para consultar los indicadores de sostenibilidad.'
                        : 'Aún no hay datos de operación disponibles para consultar.',
                    icon: Icons.insert_chart_outlined,
                  )
                else ...[
                  _KpiGrid(summary: state.summary!),
                  const SizedBox(height: 24),
                  const _QuickAccess(),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HeaderBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) => PageHeader(
    title: 'Resumen operativo',
    description:
        'Consulta la actividad de distribución y sus indicadores de sostenibilidad.',
    icon: Icons.dashboard_outlined,
    actions: [
      OutlinedButton.icon(
        onPressed: context.watch<DashboardBloc>().state.isLoading
            ? null
            : () => context.read<DashboardBloc>().add(const DashboardLoaded()),
        icon: const Icon(Icons.refresh),
        label: const Text('Actualizar'),
      ),
    ],
  );
}

class _KpiGrid extends StatelessWidget {
  const _KpiGrid({required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final narrow = isNarrow(context);
    final cards = <Widget>[
      KpiCard(
        label: 'Vehículos registrados',
        value: Formatters.integer.format(summary.totalVehiculos),
        icon: Icons.local_shipping_outlined,
      ),
      KpiCard(
        label: 'Conductores disponibles',
        value: Formatters.integer.format(summary.conductoresDisponibles),
        icon: Icons.badge_outlined,
        accent: AppTheme.primaryDark,
      ),
      KpiCard(
        label: 'Pedidos pendientes',
        value: Formatters.integer.format(summary.pedidosPendientes),
        icon: Icons.schedule,
        accent: AppTheme.warning,
      ),
      KpiCard(
        label: 'Pedidos en ruta',
        value: Formatters.integer.format(summary.pedidosEnRuta),
        icon: Icons.local_shipping_outlined,
        accent: AppTheme.info,
      ),
      KpiCard(
        label: 'Pedidos entregados',
        value: Formatters.integer.format(summary.pedidosEntregados),
        icon: Icons.check_circle_outline,
        accent: AppTheme.success,
      ),
      KpiCard(
        label: 'Pedidos cancelados',
        value: Formatters.integer.format(summary.pedidosCancelados),
        icon: Icons.cancel_outlined,
        accent: AppTheme.danger,
      ),
      KpiCard(
        label: 'Rutas planificadas',
        value: Formatters.integer.format(summary.rutasPlanificadas),
        icon: Icons.route_outlined,
      ),
      KpiCard(
        label: 'CO2 total emitido',
        value: Formatters.co2(summary.co2TotalKg),
        icon: Icons.eco_outlined,
        accent: AppTheme.primary,
      ),
      KpiCard(
        label: 'Combustible consumido',
        value: Formatters.liters(summary.combustibleTotalL),
        icon: Icons.local_gas_station_outlined,
        accent: AppTheme.primaryDark,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns =
            constraints.maxWidth < 480 ||
                MediaQuery.textScalerOf(context).scale(16) > 22
            ? 1
            : narrow
            ? 2
            : 3;
        final width = (constraints.maxWidth - (columns - 1) * 16) / columns;
        final groups = [
          ('Recursos de distribución', cards.sublist(0, 2)),
          ('Estado de los pedidos', cards.sublist(2, 6)),
          ('Rutas y sostenibilidad', cards.sublist(6)),
        ];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final group in groups) ...[
              Semantics(
                header: true,
                child: Text(
                  group.$1,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: group.$2
                    .map((card) => SizedBox(width: width, child: card))
                    .toList(),
              ),
              const SizedBox(height: 32),
            ],
          ],
        );
      },
    );
  }
}

class _QuickAccess extends StatelessWidget {
  const _QuickAccess();

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthBloc>().state.user;
    final entries = _entriesFor(user);
    if (entries.isEmpty) return const SizedBox.shrink();

    final narrow = isNarrow(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(
            'Accesos rápidos',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns =
                narrow || MediaQuery.textScalerOf(context).scale(16) > 22
                ? 1
                : constraints.maxWidth < 900
                ? 2
                : 3;
            final width = (constraints.maxWidth - (columns - 1) * 16) / columns;
            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: entries
                  .map((entry) => SizedBox(width: width, child: entry))
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  List<Widget> _entriesFor(AppUser? user) {
    return [
      if (AppPermissions.canView(user, AppModule.fleet))
        _QuickCard(
          title: 'Gestión de vehículos',
          description: 'Control de capacidades, consumo y emisiones.',
          icon: Icons.local_shipping_outlined,
          onTap: (context) => context.go('/fleet'),
        ),
      if (AppPermissions.canView(user, AppModule.drivers))
        _QuickCard(
          title: 'Conductores',
          description: 'Licencias, disponibilidad y asignaciones.',
          icon: Icons.badge_outlined,
          onTap: (context) => context.go('/drivers'),
        ),
      if (AppPermissions.canView(user, AppModule.orders))
        _QuickCard(
          title: 'Pedidos de distribución',
          description: 'Estado de entrega y ventanas de tiempo.',
          icon: Icons.inventory_2_outlined,
          onTap: (context) => context.go('/orders'),
        ),
      if (AppPermissions.canView(user, AppModule.clients))
        _QuickCard(
          title: 'Clientes y preferencias',
          description: 'Horarios de atención, restricciones y perfiles de entrega.',
          icon: Icons.storefront_outlined,
          onTap: (context) => context.go('/clients'),
        ),
      if (AppPermissions.canView(user, AppModule.routes))
        _QuickCard(
          title: 'Rutas de distribución',
          description: AppPermissions.canCreate(user, AppModule.routes)
              ? 'Generación y consulta de rutas sostenibles.'
              : 'Consulta las entregas y el mapa de los recorridos disponibles.',
          icon: Icons.route_outlined,
          onTap: (context) => context.go('/routes'),
        ),
    ];
  }
}

class _QuickCard extends StatelessWidget {
  const _QuickCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final void Function(BuildContext) onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => onTap(context),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: AppTheme.primary, size: 30),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textHighContrast,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                description,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppTheme.mutedText),
              ),
              const SizedBox(height: 16),
              const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Abrir',
                    style: TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(width: 6),
                  Icon(Icons.arrow_forward, size: 16, color: AppTheme.primary),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
