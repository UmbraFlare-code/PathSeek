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
            title: const Text('Detalle de ruta'),
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
      return const LoadingIndicator(message: 'Cargando ruta...');
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
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '// ${route.pedidos.length} ENTREGAS EN ORDEN',
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
            const Text(
              'RUTA // PLANIFICADA',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 16,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${route.fecha} · ${route.conductorNombre ?? 'Sin conductor'} · '
              '${route.placa ?? 'Sin vehiculo'}',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 24,
              runSpacing: 12,
              children: [
                _Metric(label: 'Distancia', value: Formatters.km(route.distanciaKm)),
                _Metric(label: 'CO2', value: Formatters.co2(route.co2Kg)),
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
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
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
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primary.withValues(alpha: 0.12),
          child: Text(
            '${pedido.orden}',
            style: const TextStyle(
              color: AppTheme.primaryDark,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(pedido.direccion ?? 'Direccion no disponible'),
        subtitle: Text(
          [
            if (pedido.horaEstimada != null)
              'Estimado: ${pedido.horaEstimada}',
            if (pedido.ventanaInicio != null && pedido.ventanaFin != null)
              'Ventana: ${pedido.ventanaInicio} - ${pedido.ventanaFin}',
            if (pedido.peso != null)
              'Peso: ${Formatters.decimal.format(pedido.peso)} kg',
          ].join(' · '),
        ),
      ),
    );
  }
}
