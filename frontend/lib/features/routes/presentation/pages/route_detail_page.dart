import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/page_header.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../domain/entities/delivery_route.dart';
import '../bloc/route_bloc.dart';
import '../widgets/elevation_profile_widget.dart';
import '../widgets/interactive_route_map.dart';
import '../widgets/route_status_badge.dart';

class RouteDetailPage extends StatelessWidget {
  const RouteDetailPage({super.key, required this.routeId});
  final String routeId;
  @override
  Widget build(BuildContext context) => BlocProvider<RouteBloc>(
    create: (_) => locator<RouteBloc>()..add(RouteDetailRequested(routeId)),
    child: RouteDetailView(routeId: routeId),
  );
}

class RouteDetailView extends StatelessWidget {
  const RouteDetailView({super.key, this.routeId, this.showBaseMap = true});
  final String? routeId;
  final bool showBaseMap;
  @override
  Widget build(BuildContext context) => BlocBuilder<RouteBloc, RouteState>(
    builder: (context, state) {
      if (state.isDetailLoading) {
        return const LoadingIndicator(message: 'Cargando el recorrido…');
      }
      if (state.hasDetailError) {
        return ErrorView(
          message: state.detailError!,
          onRetry: routeId == null
              ? null
              : () => context.read<RouteBloc>().add(
                  RouteDetailRequested(routeId!),
                ),
        );
      }
      final route = state.selectedRoute;
      if (route == null) return const Center(child: Text('Ruta no disponible'));
      final theme = Theme.of(context);
      return LayoutBuilder(
        builder: (context, constraints) {
          final wide =
              constraints.maxWidth > 1100 &&
              MediaQuery.textScalerOf(context).scale(16) < 23;
          final map = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              InteractiveRouteMap(
                route: route,
                height: constraints.maxWidth < 600 ? 300 : 420,
                showBaseMap: showBaseMap,
              ),
              const SizedBox(height: 16),
              ElevationProfileWidget(route: route),
            ],
          );
          final stops = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(
                header: true,
                child: Text(
                  'Secuencia de entregas',
                  style: theme.textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${route.pedidos.length} entregas en el orden planificado',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              if (route.pedidos.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('Esta ruta no tiene pedidos asignados.'),
                  ),
                ),
              ...route.pedidos.map((p) => _DeliveryCard(order: p)),
            ],
          );
          return SingleChildScrollView(
            padding: EdgeInsets.all(constraints.maxWidth < 600 ? 16 : 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => context.canPop()
                        ? context.pop()
                        : context.go('/routes'),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Volver a rutas'),
                  ),
                ),
                const SizedBox(height: 12),
                PageHeader(
                  title: 'Detalle de ruta',
                  description:
                      '${route.fecha} · ${route.placa ?? 'Sin vehículo'} · ${route.conductorNombre ?? 'Sin conductor'}',
                  icon: Icons.route_outlined,
                  actions: [RouteStatusBadge(status: route.estado)],
                ),
                const SizedBox(height: 24),
                Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Wrap(
                      spacing: 36,
                      runSpacing: 20,
                      children: [
                        _Metric(
                          label: 'Distancia estimada',
                          value: Formatters.km(route.distanciaKm),
                          icon: Icons.straighten,
                        ),
                        _Metric(
                          label: 'CO₂ estimado',
                          value: Formatters.co2(route.co2Kg),
                          icon: Icons.eco_outlined,
                        ),
                        _Metric(
                          label: 'Combustible estimado',
                          value: Formatters.liters(route.combustibleL),
                          icon: Icons.local_gas_station_outlined,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                if (wide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 7, child: map),
                      const SizedBox(width: 24),
                      Expanded(flex: 4, child: stops),
                    ],
                  )
                else ...[
                  map,
                  const SizedBox(height: 24),
                  stops,
                ],
              ],
            ),
          );
        },
      );
    },
  );
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value, required this.icon});
  final String label, value;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, color: Theme.of(context).colorScheme.primary),
      const SizedBox(height: 8),
      Text(label, style: Theme.of(context).textTheme.bodyMedium),
      const SizedBox(height: 4),
      Text(
        value,
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
      ),
    ],
  );
}

class _DeliveryCard extends StatelessWidget {
  const _DeliveryCard({required this.order});
  final RouteOrder order;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  foregroundColor: theme.colorScheme.onPrimaryContainer,
                  child: Text('${order.orden}'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    order.direccion ?? 'Dirección no disponible',
                    style: theme.textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Cliente: ${order.clienteId ?? 'No disponible'}'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                Text('Llegada estimada: ${order.horaEstimada ?? '—'}'),
                Text(
                  'Ventana: ${order.ventanaInicio ?? '—'}–${order.ventanaFin ?? '—'}',
                ),
                if (order.peso != null)
                  Text('${Formatters.decimal.format(order.peso)} kg'),
              ],
            ),
            const Divider(),
            Text('Contexto vial estimado', style: theme.textTheme.labelLarge),
            const SizedBox(height: 6),
            Text(
              '${order.contextoVial.tipoSuperficie} · ${order.contextoVial.elevacionMetros} m · Pendiente ${order.contextoVial.pendientePorcentaje}% · ${order.contextoVial.nivelCongestion}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
