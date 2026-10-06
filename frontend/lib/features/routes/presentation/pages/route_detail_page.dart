import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../domain/entities/delivery_route.dart';
import '../bloc/route_bloc.dart';
import '../widgets/elevation_profile_widget.dart';
import '../widgets/interactive_route_map.dart';

class RouteDetailPage extends StatelessWidget {
  const RouteDetailPage({super.key, required this.routeId});

  final String routeId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RouteBloc>(
      create: (_) => locator<RouteBloc>()..add(RouteDetailRequested(routeId)),
      child: const RouteDetailView(),
    );
  }
}

class RouteDetailView extends StatelessWidget {
  const RouteDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RouteBloc, RouteState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Detalle de ruta y mapa'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
          ),
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, RouteState state) {
    if (state.isDetailLoading) {
      return const LoadingIndicator(message: 'Cargando ruta y contexto vial...');
    }

    if (state.hasDetailError) {
      return ErrorView(message: state.detailError!);
    }

    final route = state.selectedRoute;
    if (route == null) {
      return const Center(child: Text('Ruta no disponible'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MetricsHeader(route: route),
          const SizedBox(height: 16),

          // 1. Mapa Interactivo de la Ruta
          InteractiveRouteMap(
            route: route,
            height: 360,
          ),
          const SizedBox(height: 16),

          // 2. Perfil Altimétrico y Calzada
          ElevationProfileWidget(route: route),
          const SizedBox(height: 20),

          // 3. Lista de Entregas en Secuencia
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '// ${route.pedidos.length} ENTREGAS EN ORDEN SECUENCIAL',
              style: const TextStyle(
                color: AppTheme.primaryDark,
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 1.0,
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (route.pedidos.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: Text('Esta ruta no tiene pedidos asignados.')),
            )
          else
            ...route.pedidos.map((pedido) => _OrderTile(pedido: pedido)),
        ],
      ),
    );
  }
}

class _MetricsHeader extends StatelessWidget {
  const _MetricsHeader({required this.route});

  final DeliveryRoute route;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.primaryDark,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'RUTA // PLANIFICADA (VRPTW)',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    letterSpacing: 0.5,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.accent),
                  ),
                  child: const Text(
                    'OSM ROAD CONTEXT',
                    style: TextStyle(
                      color: AppTheme.accent,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${route.fecha} · Conductor: ${route.conductorNombre ?? 'Sin asignar'} · '
              'Placa: ${route.placa ?? 'Sin vehículo'}',
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 24,
              runSpacing: 12,
              children: [
                _Metric(label: 'Distancia', value: Formatters.km(route.distanciaKm)),
                _Metric(label: 'CO2 Estimado', value: Formatters.co2(route.co2Kg)),
                _Metric(label: 'Combustible', value: Formatters.liters(route.combustibleL)),
                _Metric(label: 'Estado', value: route.estado),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: AppTheme.accent,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _OrderTile extends StatelessWidget {
  const _OrderTile({required this.pedido});

  final RouteOrder pedido;

  @override
  Widget build(BuildContext context) {
    final ctx = pedido.contextoVial;
    final isTrocha = ctx.tipoSuperficie == 'TROCHA' || ctx.tipoSuperficie == 'AFIRMADO';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isTrocha
              ? Colors.orange.withValues(alpha: 0.15)
              : AppTheme.primary.withValues(alpha: 0.12),
          child: Text(
            '${pedido.orden}',
            style: TextStyle(
              color: isTrocha ? Colors.orange.shade900 : AppTheme.primaryDark,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          pedido.direccion ?? 'Dirección no disponible',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(
              [
                if (pedido.horaEstimada != null) 'Estimado: ${pedido.horaEstimada}',
                if (pedido.ventanaInicio != null && pedido.ventanaFin != null)
                  'Ventana: ${pedido.ventanaInicio} - ${pedido.ventanaFin}',
                if (pedido.peso != null) '${Formatters.decimal.format(pedido.peso)} kg',
              ].join(' · '),
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isTrocha ? Colors.orange.shade50 : Colors.green.shade50,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: isTrocha ? Colors.orange.shade300 : Colors.green.shade300,
                    ),
                  ),
                  child: Text(
                    '${ctx.tipoSuperficie} · ${ctx.elevacionMetros} m',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isTrocha ? Colors.orange.shade900 : Colors.green.shade900,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Pendiente: ${ctx.pendientePorcentaje}% · ${ctx.nivelCongestion}',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
