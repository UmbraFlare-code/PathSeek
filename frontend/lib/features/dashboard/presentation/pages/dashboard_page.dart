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
            padding: EdgeInsets.all(isNarrow(context) ? 14 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _DashboardHeader(),
                const SizedBox(height: 16),
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
                  const SizedBox(height: 20),
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

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader();

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
              'PANEL DE CONTROL',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w400,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Resumen de Operaciones',
          style: TextStyle(
            color: AppTheme.textHighContrast,
            fontSize: 22,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Métricas operativas de flota, pedidos y optimización de sostenibilidad',
          style: TextStyle(
            color: AppTheme.textMuted,
            fontSize: 13,
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
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
        label: 'Vehículos registrados',
        value: Formatters.integer.format(summary.totalVehiculos),
        icon: Icons.local_shipping_outlined,
      ),
      KpiCard(
        label: 'Conductores disponibles',
        value: Formatters.integer.format(summary.conductoresDisponibles),
        icon: Icons.badge_outlined,
        accent: AppTheme.primary,
      ),
      KpiCard(
        label: 'Pedidos pendientes',
        value: Formatters.integer.format(summary.pedidosPendientes),
        icon: Icons.schedule_rounded,
        accent: const Color(0xFFD97706),
      ),
      KpiCard(
        label: 'Pedidos en ruta',
        value: Formatters.integer.format(summary.pedidosEnRuta),
        icon: Icons.alt_route_rounded,
        accent: const Color(0xFF2563EB),
      ),
      KpiCard(
        label: 'Pedidos entregados',
        value: Formatters.integer.format(summary.pedidosEntregados),
        icon: Icons.check_circle_outline_rounded,
        accent: const Color(0xFF16A34A),
      ),
      KpiCard(
        label: 'Pedidos cancelados',
        value: Formatters.integer.format(summary.pedidosCancelados),
        icon: Icons.cancel_outlined,
        accent: AppTheme.error,
      ),
      KpiCard(
        label: 'Rutas planificadas',
        value: Formatters.integer.format(summary.rutasPlanificadas),
        icon: Icons.route_outlined,
      ),
      KpiCard(
        label: 'CO₂ total emitido',
        value: Formatters.co2(summary.co2TotalKg),
        icon: Icons.eco_outlined,
        accent: AppTheme.accent,
      ),
      KpiCard(
        label: 'Combustible consumido',
        value: Formatters.liters(summary.combustibleTotalL),
        icon: Icons.local_gas_station_outlined,
        accent: AppTheme.primary,
      ),
    ];

    return GridView.count(
      crossAxisCount: narrow ? 2 : 3,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: narrow ? 1.6 : 2.5,
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: AppTheme.primary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'ACCESO RÁPIDO',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w400,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final count = width < 550 ? 1 : (width < 950 ? 2 : 4);
            final ratio = width < 550 ? 3.2 : (width < 950 ? 2.4 : 1.75);

            return GridView.count(
              crossAxisCount: count,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: ratio,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: entries,
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
          title: 'Gestión de Flota',
          description: 'Capacidad, tipo de combustible y estado operativo.',
          icon: Icons.local_shipping_outlined,
          onTap: (context) => context.go('/fleet'),
        ),
      if (AppPermissions.canView(user, AppModule.drivers))
        _QuickCard(
          title: 'Conductores',
          description: 'Licencias, disponibilidad y turnos asignados.',
          icon: Icons.badge_outlined,
          onTap: (context) => context.go('/drivers'),
        ),
      if (AppPermissions.canView(user, AppModule.orders))
        _QuickCard(
          title: 'Despacho de Pedidos',
          description: 'Estado de entregas y ventanas horarias escolares.',
          icon: Icons.inventory_2_outlined,
          onTap: (context) => context.go('/orders'),
        ),
      if (AppPermissions.canView(user, AppModule.routes))
        _QuickCard(
          title: 'Rutas Sostenibles',
          description: 'Optimización de trayectos y cálculo de huella CO₂.',
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppTheme.border,
          width: 1.0,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => onTap(context),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Center(
                      child: Icon(
                        icon,
                        color: AppTheme.primary,
                        size: 19,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 15,
                    color: AppTheme.textMuted,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textHighContrast,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 3),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w300,
                  color: AppTheme.textSecondary,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
