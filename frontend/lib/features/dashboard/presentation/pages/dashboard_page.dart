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
                    onRetry: () => context
                        .read<DashboardBloc>()
                        .add(const DashboardLoaded()),
                  )
                else if (state.summary == null || !state.summary!.hasData)
                  const EmptyView(
                    message:
                        'Aun no hay datos de operacion. Genera rutas para ver '
                        'los indicadores de sostenibilidad del dashboard.',
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
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text(
        '// PANEL DE CONTROL GENERAL',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

class _KpiGrid extends StatelessWidget {
  const _KpiGrid({required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final narrow = isNarrow(context);
    final cards = <Widget>[
      KpiCard(
        label: 'Vehiculos registrados',
        value: Formatters.integer.format(summary.totalVehiculos),
        icon: Icons.local_shipping,
      ),
      KpiCard(
        label: 'Conductores disponibles',
        value: Formatters.integer.format(summary.conductoresDisponibles),
        icon: Icons.badge,
        accent: AppTheme.primaryDark,
      ),
      KpiCard(
        label: 'Pedidos pendientes',
        value: Formatters.integer.format(summary.pedidosPendientes),
        icon: Icons.schedule,
        accent: const Color(0xFFE67E22),
      ),
      KpiCard(
        label: 'Pedidos en ruta',
        value: Formatters.integer.format(summary.pedidosEnRuta),
        icon: Icons.local_shipping_outlined,
        accent: const Color(0xFF1565C0),
      ),
      KpiCard(
        label: 'Pedidos entregados',
        value: Formatters.integer.format(summary.pedidosEntregados),
        icon: Icons.check_circle_outline,
        accent: const Color(0xFF2E7D32),
      ),
      KpiCard(
        label: 'Pedidos cancelados',
        value: Formatters.integer.format(summary.pedidosCancelados),
        icon: Icons.cancel_outlined,
        accent: const Color(0xFFBA1A1A),
      ),
      KpiCard(
        label: 'Rutas planificadas',
        value: Formatters.integer.format(summary.rutasPlanificadas),
        icon: Icons.route,
      ),
      KpiCard(
        label: 'CO2 total emitido',
        value: Formatters.co2(summary.co2TotalKg),
        icon: Icons.eco,
        accent: AppTheme.accent,
      ),
      KpiCard(
        label: 'Combustible consumido',
        value: Formatters.liters(summary.combustibleTotalL),
        icon: Icons.local_gas_station_outlined,
        accent: AppTheme.primaryDark,
      ),
    ];

    return GridView.count(
      crossAxisCount: narrow ? 2 : 3,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: narrow ? 1.35 : 1.9,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: cards,
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text(
            '// ACCESO RAPIDO',
            style: TextStyle(
              color: AppTheme.primaryDark,
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 1.0,
            ),
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: narrow ? 1 : 3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: narrow ? 3.2 : 1.8,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: entries,
        ),
      ],
    );
  }

  List<Widget> _entriesFor(AppUser? user) {
    return [
      if (AppPermissions.canView(user, AppModule.fleet))
        _QuickCard(
          title: 'Gestion de Vehiculos',
          description: 'Control de capacidades, consumo y emisiones.',
          icon: Icons.local_shipping,
          onTap: (context) => context.go('/fleet'),
        ),
      if (AppPermissions.canView(user, AppModule.drivers))
        _QuickCard(
          title: 'Conductores Registrados',
          description: 'Licencias, disponibilidad y asignaciones.',
          icon: Icons.badge,
          onTap: (context) => context.go('/drivers'),
        ),
      if (AppPermissions.canView(user, AppModule.orders))
        _QuickCard(
          title: 'Despacho de Pedidos',
          description: 'Estado de entrega y ventanas de tiempo.',
          icon: Icons.inventory_2,
          onTap: (context) => context.go('/orders'),
        ),
      if (AppPermissions.canView(user, AppModule.routes))
        _QuickCard(
          title: 'Rutas Optimizadas',
          description: 'Generacion y seguimiento de rutas sostenibles.',
          icon: Icons.route,
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
              Expanded(
                child: Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                    height: 1.4,
                  ),
                ),
              ),
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
