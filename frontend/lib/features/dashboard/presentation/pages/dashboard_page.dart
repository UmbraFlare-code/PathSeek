import 'dart:async';

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

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late final DashboardBloc _bloc;
  late final Timer _refresh;

  @override
  void initState() {
    super.initState();
    _bloc = locator<DashboardBloc>()..add(const DashboardLoaded());
    _refresh = Timer.periodic(const Duration(seconds: 10), (_) {
      if (WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed) {
        _bloc.add(const DashboardLoaded());
      }
    });
  }

  @override
  void dispose() {
    _refresh.cancel();
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocProvider<DashboardBloc>.value(
    value: _bloc,
    child: const DashboardView(),
  );
}

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        final metrics = state.summary?.executedRoutes;
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
                if (state.summary == null && !state.hasError)
                  const LoadingIndicator(message: 'Cargando indicadores...')
                else if (state.summary == null && state.hasError)
                  ErrorView(
                    message: state.errorMessage!,
                    onRetry: () => context.read<DashboardBloc>().add(
                      const DashboardLoaded(),
                    ),
                  )
                else ...[
                  if (state.hasError)
                    Semantics(
                      liveRegion: true,
                      child: const Text(
                        'No se pudo actualizar. Se muestran los últimos datos disponibles.',
                      ),
                    ),
                  if (metrics == null || metrics.completedRoutes == 0)
                    EmptyView(
                      message:
                          'Aún no hay rutas completadas. Los indicadores aparecerán al registrar las entregas de una ruta.',
                      icon: Icons.insert_chart_outlined,
                    )
                  else ...[
                    _FuelSavingsMessage(comparison: metrics.dailyComparison),
                    const SizedBox(height: 20),
                    _KpiGrid(summary: state.summary!, metrics: metrics),
                    const SizedBox(height: 24),
                    const _QuickAccess(),
                  ],
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
        'Indicadores de rutas completadas. Se actualizan automáticamente cada 10 segundos.',
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

class _FuelSavingsMessage extends StatelessWidget {
  const _FuelSavingsMessage({required this.comparison});

  final DailyFuelComparison? comparison;

  @override
  Widget build(BuildContext context) {
    final comparison = this.comparison;
    final savedSoles = comparison?.savedSoles;
    final String message;
    if (comparison == null) {
      message = 'Aún no hay rutas completadas comparables hoy.';
    } else if (savedSoles == null && comparison.savedLiters > 0) {
      message = 'El ahorro en soles requiere un precio por litro configurado.';
    } else if (savedSoles != null && savedSoles > 0) {
      message =
          'Has ahorrado ${Formatters.soles(savedSoles)} en combustible hoy';
    } else {
      return const SizedBox.shrink();
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(message, style: Theme.of(context).textTheme.titleMedium),
      ),
    );
  }
}

class _KpiGrid extends StatelessWidget {
  const _KpiGrid({required this.summary, required this.metrics});

  final DashboardSummary summary;
  final ExecutedRoutesMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final narrow = isNarrow(context);
    final comparison = metrics.dailyComparison;
    final windowPercent = metrics.onTimePercent;
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
          (
            'Rutas completadas',
            [
              KpiCard(
                label: 'Distancia recorrida estimada',
                value: Formatters.km(metrics.distanceKm),
                icon: Icons.route_outlined,
              ),
              KpiCard(
                label: 'Emisiones estimadas',
                value: Formatters.co2(metrics.co2Kg),
                icon: Icons.eco_outlined,
              ),
              KpiCard(
                label: 'Combustible consumido estimado',
                value: Formatters.liters(metrics.fuelLiters),
                icon: Icons.local_gas_station_outlined,
              ),
              KpiCard(
                label: 'Cumplimiento de ventanas',
                value: windowPercent == null
                    ? 'Sin horas registradas'
                    : Formatters.percent(windowPercent),
                icon: Icons.schedule_outlined,
              ),
            ],
          ),
          if (comparison != null)
            (
              'Comparación estimada de hoy con la ruta secuencial',
              [
                KpiCard(
                  label: 'Combustible de referencia',
                  value: Formatters.liters(comparison.sequentialLiters),
                  icon: Icons.alt_route_outlined,
                ),
                KpiCard(
                  label: 'Combustible ahorrado',
                  value: Formatters.liters(comparison.savedLiters),
                  icon: Icons.local_gas_station_outlined,
                ),
                KpiCard(
                  label: 'Ahorro comparado',
                  value: Formatters.percent(comparison.savedPercent),
                  icon: Icons.eco_outlined,
                ),
              ],
            ),
          ('Recursos de distribución', cards.sublist(0, 2)),
          ('Pedidos y planificación', cards.sublist(2)),
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
          description:
              'Horarios de atención, restricciones y perfiles de entrega.',
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
