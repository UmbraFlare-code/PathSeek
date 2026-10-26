import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/page_header.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
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
      final rol = context.watch<AuthBloc>().state.user?.rol;
      final isConductor = rol == 'CONDUCTOR';
      final isOperative = rol == 'ADMIN' || rol == 'OPERADOR';
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
                onRetryGeometry: () => context.read<RouteBloc>().add(
                  RouteDetailRequested(route.id),
                ),
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
              ...route.pedidos.map(
                (p) => _DeliveryCard(
                  order: p,
                  isConductor: isConductor,
                  isExecuting: state.isExecuting,
                ),
              ),
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
                  actions: [
                    RouteStatusBadge(status: route.estado),
                    if (isConductor)
                      FilledButton.tonalIcon(
                        onPressed: state.isExecuting
                            ? null
                            : () => _showPositionDialog(context, route),
                        icon: const Icon(Icons.my_location),
                        label: const Text('Reportar posición'),
                      ),
                    if (isOperative) ...[
                      OutlinedButton.icon(
                        onPressed: state.isExecuting
                            ? null
                            : () => _showIncidentDialog(context, route),
                        icon: const Icon(Icons.report_outlined),
                        label: const Text('Reportar incidente'),
                      ),
                      FilledButton.icon(
                        onPressed: state.isExecuting
                            ? null
                            : () => _confirmReoptimize(context, route),
                        icon: const Icon(Icons.auto_fix_high),
                        label: const Text('Reoptimizar'),
                      ),
                    ],
                  ],
                ),
                if (state.offlineMessage != null) ...[
                  const SizedBox(height: 12),
                  _NoticeBanner(
                    message: state.offlineMessage!,
                    icon: Icons.cloud_off_outlined,
                  ),
                ],
                if (state.executionMessage != null) ...[
                  const SizedBox(height: 12),
                  _NoticeBanner(
                    message: state.executionMessage!,
                    icon: state.isExecuting
                        ? Icons.hourglass_top
                        : Icons.check_circle_outline,
                  ),
                ],
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

  Future<void> _showPositionDialog(
    BuildContext context,
    DeliveryRoute route,
  ) async {
    final firstPending = route.pedidos
        .where((p) => p.pedidoEstado != 'ENTREGADO')
        .cast<RouteOrder?>()
        .firstWhere((p) => true, orElse: () => null);
    final latController = TextEditingController(
      text: firstPending?.gpsLat?.toStringAsFixed(6) ?? '',
    );
    final lonController = TextEditingController(
      text: firstPending?.gpsLon?.toStringAsFixed(6) ?? '',
    );
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reportar mi posición'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Ingresa tu latitud y longitud actuales. Sin conexión, la posición queda guardada y se sincroniza después.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: latController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
              decoration: const InputDecoration(labelText: 'Latitud'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: lonController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
              decoration: const InputDecoration(labelText: 'Longitud'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final lat = double.tryParse(latController.text);
              final lon = double.tryParse(lonController.text);
              if (lat == null ||
                  lon == null ||
                  lat < -90 ||
                  lat > 90 ||
                  lon < -180 ||
                  lon > 180) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(
                    content: Text('Coordenadas inválidas'),
                  ),
                );
                return;
              }
              Navigator.of(dialogContext).pop();
              context.read<RouteBloc>().add(
                    PositionReported(route.id, lat, lon),
                  );
            },
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
    latController.dispose();
    lonController.dispose();
  }

  Future<void> _showIncidentDialog(
    BuildContext context,
    DeliveryRoute route,
  ) async {
    var tipo = 'BLOQUEO';
    final descripcionController = TextEditingController();
    final radioController = TextEditingController(text: '250');
    final firstPending = route.pedidos
        .where((p) => p.pedidoEstado != 'ENTREGADO')
        .cast<RouteOrder?>()
        .firstWhere((p) => true, orElse: () => null);
    final latController = TextEditingController(
      text: firstPending?.gpsLat?.toStringAsFixed(6) ?? '',
    );
    final lonController = TextEditingController(
      text: firstPending?.gpsLon?.toStringAsFixed(6) ?? '',
    );
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: const Text('Reportar incidente vial'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: tipo,
                  decoration: const InputDecoration(labelText: 'Tipo'),
                  items: const [
                    DropdownMenuItem(value: 'BLOQUEO', child: Text('Bloqueo')),
                    DropdownMenuItem(value: 'OBRAS', child: Text('Obras')),
                    DropdownMenuItem(
                      value: 'ACCIDENTE',
                      child: Text('Accidente'),
                    ),
                    DropdownMenuItem(
                      value: 'CONGESTION_SEVERA',
                      child: Text('Congestión severa'),
                    ),
                  ],
                  onChanged: (value) => setDialogState(() => tipo = value!),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descripcionController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: latController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: true,
                  ),
                  decoration: const InputDecoration(labelText: 'Latitud'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: lonController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: true,
                  ),
                  decoration: const InputDecoration(labelText: 'Longitud'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: radioController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Radio de afectación (m)',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                final lat = double.tryParse(latController.text);
                final lon = double.tryParse(lonController.text);
                final radio = int.tryParse(radioController.text);
                if (descripcionController.text.trim().isEmpty ||
                    lat == null ||
                    lon == null ||
                    radio == null ||
                    radio < 1 ||
                    radio > 5000) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Completa descripción, coordenadas y radio (1–5000 m).',
                      ),
                    ),
                  );
                  return;
                }
                Navigator.of(dialogContext).pop();
                context.read<RouteBloc>().add(
                      IncidentReported(
                        route.id,
                        {
                          'tipo': tipo,
                          'descripcion': descripcionController.text.trim(),
                          'lat': lat,
                          'lon': lon,
                          'radioAfectacionMetros': radio,
                        },
                      ),
                    );
              },
              child: const Text('Registrar'),
            ),
          ],
        ),
      ),
    );
    descripcionController.dispose();
    radioController.dispose();
    latController.dispose();
    lonController.dispose();
  }

  Future<void> _confirmReoptimize(
    BuildContext context,
    DeliveryRoute route,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reoptimizar ruta'),
        content: const Text(
          'El sistema recalculará la secuencia pendiente evitando los incidentes activos '
          'y notificará al conductor. Las entregas ya realizadas se conservan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Reoptimizar'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    context.read<RouteBloc>().add(
          RouteReoptimized(
            route.id,
            {
              'evento_id': const Uuid().v4(),
              'tipo': 'INCIDENTE',
              'rutas_ids': [route.id],
            },
          ),
        );
  }
}

class _NoticeBanner extends StatelessWidget {
  const _NoticeBanner({required this.message, required this.icon});
  final String message;
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      color: theme.colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, color: theme.colorScheme.onSecondaryContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSecondaryContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
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
  const _DeliveryCard({
    required this.order,
    required this.isConductor,
    required this.isExecuting,
  });
  final RouteOrder order;
  final bool isConductor;
  final bool isExecuting;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final delivered = order.pedidoEstado == 'ENTREGADO';
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
                  backgroundColor: delivered
                      ? theme.colorScheme.primary
                      : theme.colorScheme.primaryContainer,
                  foregroundColor: delivered
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onPrimaryContainer,
                  child: Icon(
                    delivered ? Icons.check : Icons.place_outlined,
                    size: 20,
                  ),
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
                Text(
                  'Estado: ${order.pedidoEstado ?? 'ASIGNADO'}',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: delivered ? theme.colorScheme.primary : null,
                  ),
                ),
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
            if (isConductor && !delivered) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: isExecuting
                      ? null
                      : () => context.read<RouteBloc>().add(
                            DeliveryCompleted(
                              routeContextOf(context),
                              order.pedidoId,
                            ),
                          ),
                  icon: const Icon(Icons.done_all),
                  label: const Text('Completar entrega'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String routeContextOf(BuildContext context) {
    final state = context.read<RouteBloc>().state;
    return state.selectedRoute?.id ?? '';
  }
}
