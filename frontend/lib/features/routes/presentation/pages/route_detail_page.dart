import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../domain/entities/delivery_route.dart';
import '../bloc/route_bloc.dart';
import '../widgets/dynamic_recalculation_sheet.dart';
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
        final route = state.selectedRoute;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Detalle de Ruta y Mapa Huancayo'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
            actions: [
              if (route != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilledButton.tonalIcon(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFFEF3C7),
                      foregroundColor: const Color(0xFFB45309),
                      visualDensity: VisualDensity.compact,
                    ),
                    icon: const Icon(Icons.alt_route_rounded, size: 16),
                    label: const Text('Recálculo dinámico', style: TextStyle(fontSize: 12)),
                    onPressed: () => DynamicRecalculationSheet.show(
                      context,
                      route: route,
                    ),
                  ),
                ),
            ],
          ),
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, RouteState state) {
    if (state.isDetailLoading) {
      return const LoadingIndicator(message: 'Cargando ruta y contexto vial de Huancayo...');
    }

    if (state.hasDetailError) {
      return ErrorView(message: state.detailError!);
    }

    final route = state.selectedRoute;
    if (route == null) {
      return const Center(child: Text('Ruta no disponible'));
    }

    final narrow = isNarrow(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(narrow ? 14 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MetricsHeader(route: route),
          const SizedBox(height: 16),

          // 1. Mapa Interactivo de Huancayo y la Ruta
          InteractiveRouteMap(
            route: route,
            height: narrow ? 340 : 400,
          ),
          const SizedBox(height: 16),

          // 2. Perfil Altimétrico y Calzada (Valle del Mantaro)
          ElevationProfileWidget(route: route),
          const SizedBox(height: 20),

          // 3. Lista de Entregas en Secuencia
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
              Text(
                '${route.pedidos.length} ENTREGAS EN ORDEN SECUENCIAL',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (route.pedidos.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.border, width: 1.0),
              ),
              child: const Center(
                child: Text(
                  'Esta ruta no tiene pedidos asignados.',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              ),
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
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: AppTheme.accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'RUTA PLANIFICADA // VRPTW HUANCAYO',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1.0,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _EstadoChip(estado: route.estado),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${route.fecha} · Conductor: ${route.conductorNombre ?? 'Sin asignar'}',
            style: const TextStyle(
              color: AppTheme.textHighContrast,
              fontSize: 18,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Vehículo asignado: ${route.placa ?? 'Sin placa'} · Depósito: UGEL Huancayo (Jr. Atalaya 1280)',
            style: const TextStyle(
              color: AppTheme.textMuted,
              fontSize: 12.5,
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final isSmall = constraints.maxWidth < 600;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _MetricTile(
                    label: 'Distancia total',
                    value: Formatters.km(route.distanciaKm),
                    icon: Icons.straighten_rounded,
                    width: isSmall ? (constraints.maxWidth - 12) / 2 : 140,
                  ),
                  _MetricTile(
                    label: 'Huella CO₂ est.',
                    value: Formatters.co2(route.co2Kg),
                    icon: Icons.eco_outlined,
                    iconColor: AppTheme.primary,
                    width: isSmall ? (constraints.maxWidth - 12) / 2 : 140,
                  ),
                  _MetricTile(
                    label: 'Combustible',
                    value: Formatters.liters(route.combustibleL),
                    icon: Icons.local_gas_station_outlined,
                    width: isSmall ? (constraints.maxWidth - 12) / 2 : 140,
                  ),
                  _MetricTile(
                    label: 'Paradas',
                    value: '${route.pedidos.length} Puntos',
                    icon: Icons.pin_drop_outlined,
                    width: isSmall ? (constraints.maxWidth - 12) / 2 : 140,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.icon,
    this.iconColor = AppTheme.textSecondary,
    required this.width,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.border, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: iconColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.textHighContrast,
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
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

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border, width: 1.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: isTrocha
                  ? const Color(0xFFFEF3C7)
                  : AppTheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Center(
              child: Text(
                '${pedido.orden}',
                style: TextStyle(
                  color: isTrocha ? const Color(0xFFB45309) : AppTheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pedido.direccion ?? 'Dirección no disponible',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 13.5,
                    color: AppTheme.textHighContrast,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  [
                    if (pedido.horaEstimada != null) 'Est.: ${pedido.horaEstimada}',
                    if (pedido.ventanaInicio != null && pedido.ventanaFin != null)
                      'Ventana: ${pedido.ventanaInicio} - ${pedido.ventanaFin}',
                    if (pedido.peso != null) '${Formatters.decimal.format(pedido.peso)} kg',
                  ].join(' · '),
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isTrocha ? const Color(0xFFFFFBEB) : const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: isTrocha ? const Color(0xFFFDE68A) : const Color(0xFFBBF7D0),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        '${ctx.tipoSuperficie} · ${ctx.elevacionMetros} msnm',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: isTrocha ? const Color(0xFFB45309) : const Color(0xFF15803D),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppTheme.border, width: 0.8),
                      ),
                      child: Text(
                        'Pendiente: ${ctx.pendientePorcentaje}% · ${ctx.nivelCongestion}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EstadoChip extends StatelessWidget {
  const _EstadoChip({required this.estado});

  final String estado;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, border) = switch (estado) {
      'PLANIFICADA' => (const Color(0xFFEFF6FF), const Color(0xFF1D4ED8), const Color(0xFFBFDBFE)),
      'EN_PROGRESO' => (const Color(0xFFFFFBEB), const Color(0xFFB45309), const Color(0xFFFDE68A)),
      'COMPLETADA' => (const Color(0xFFF0FDF4), const Color(0xFF15803D), const Color(0xFFBBF7D0)),
      'CANCELADA' => (const Color(0xFFFDF2F2), const Color(0xFFB91C1C), const Color(0xFFFCA5A5)),
      _ => (const Color(0xFFF3F4F6), const Color(0xFF374151), const Color(0xFFE5E7EB)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: border, width: 0.8),
      ),
      child: Text(
        estado,
        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w500, color: fg),
      ),
    );
  }
}
