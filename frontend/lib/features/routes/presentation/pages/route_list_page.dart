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
import '../../domain/entities/delivery_route.dart';
import '../bloc/route_bloc.dart';
import '../widgets/interactive_route_map.dart';

class RouteListPage extends StatelessWidget {
  const RouteListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RouteBloc>(
      create: (_) => locator<RouteBloc>()..add(const RoutesLoaded()),
      child: const RouteListView(),
    );
  }
}

class RouteListView extends StatefulWidget {
  const RouteListView({super.key});

  @override
  State<RouteListView> createState() => _RouteListViewState();
}

class _RouteListViewState extends State<RouteListView> {
  bool _showGeneralMap = false;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthBloc>().state.user;
    final canGenerate = AppPermissions.canCreate(user, AppModule.routes);
    final canDelete = AppPermissions.canDelete(user, AppModule.routes);

    return BlocConsumer<RouteBloc, RouteState>(
      listener: (context, state) {
        if (state.generateSuccess) {
          final message = state.unassignedOrders > 0
              ? '${state.generatedRoutes} rutas generadas. '
                  '${state.unassignedOrders} pedidos quedaron sin asignar.'
              : '${state.generatedRoutes} rutas generadas correctamente en el mapa de Huancayo.';
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(message)));
        } else if (state.hasGenerateError) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.generateErrorMessage!),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
        } else if (state.hasSaveError) {
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
        final narrow = isNarrow(context);
        return Padding(
          padding: EdgeInsets.all(narrow ? 14 : 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (narrow)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _RouteHeader(),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        // Switcher de vista: Lista vs Mapa
                        SegmentedButton<bool>(
                          segments: const [
                            ButtonSegment(
                              value: false,
                              icon: Icon(Icons.list_alt_rounded, size: 16),
                              label: Text('Lista'),
                            ),
                            ButtonSegment(
                              value: true,
                              icon: Icon(Icons.map_outlined, size: 16),
                              label: Text('Mapa'),
                            ),
                          ],
                          selected: {_showGeneralMap},
                          onSelectionChanged: (set) {
                            setState(() {
                              _showGeneralMap = set.first;
                            });
                          },
                          style: ButtonStyle(
                            visualDensity: VisualDensity.compact,
                            textStyle: WidgetStatePropertyAll(
                              TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (canGenerate)
                          FilledButton.icon(
                            onPressed: state.isGenerating
                                ? null
                                : () => context
                                    .read<RouteBloc>()
                                    .add(const RoutesGenerated()),
                            icon: const Icon(Icons.alt_route_rounded, size: 16),
                            label: const Text('Generar'),
                          ),
                      ],
                    ),
                  ],
                )
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Expanded(child: _RouteHeader()),
                    SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment(
                          value: false,
                          icon: Icon(Icons.table_chart_outlined, size: 16),
                          label: Text('Tabla'),
                        ),
                        ButtonSegment(
                          value: true,
                          icon: Icon(Icons.map_rounded, size: 16),
                          label: Text('Mapa Huancayo'),
                        ),
                      ],
                      selected: {_showGeneralMap},
                      onSelectionChanged: (set) {
                        setState(() {
                          _showGeneralMap = set.first;
                        });
                      },
                      style: const ButtonStyle(
                        visualDensity: VisualDensity.compact,
                        textStyle: WidgetStatePropertyAll(
                          TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (canGenerate)
                      FilledButton.icon(
                        onPressed: state.isGenerating
                            ? null
                            : () => context
                                .read<RouteBloc>()
                                .add(const RoutesGenerated()),
                        icon: const Icon(Icons.alt_route_rounded, size: 18),
                        label: const Text('Generar rutas'),
                      ),
                  ],
                ),
              const SizedBox(height: 14),

              if (state.isGenerating)
                const _GeneratingBanner()
              else if (state.routes.isNotEmpty)
                _SummaryStatsBanner(routes: state.routes),

              const SizedBox(height: 12),
              Expanded(
                child: _buildBody(
                  context,
                  state,
                  canDelete,
                  _showGeneralMap,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    RouteState state,
    bool canDelete,
    bool showMap,
  ) {
    if (state.isLoading) {
      return const LoadingIndicator(message: 'Cargando rutas de Huancayo...');
    }

    if (state.hasError) {
      return ErrorView(
        message: state.errorMessage!,
        onRetry: () => context.read<RouteBloc>().add(const RoutesLoaded()),
      );
    }

    if (state.isEmpty) {
      return const EmptyView(
        message: 'Aun no hay rutas generadas en Huancayo. Usa "Generar rutas" para '
            'planificar los pedidos pendientes con el algoritmo VRPTW.',
        icon: Icons.route_outlined,
      );
    }

    if (showMap) {
      return Column(
        children: [
          Expanded(
            child: InteractiveRouteMap(
              routes: state.routes,
              height: double.infinity,
            ),
          ),
        ],
      );
    }

    if (isNarrow(context)) {
      return _RoutesCardList(routes: state.routes, canDelete: canDelete);
    }

    return _RoutesTable(routes: state.routes, canDelete: canDelete);
  }
}

class _RouteHeader extends StatelessWidget {
  const _RouteHeader();

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
              'GESTIÓN DE RUTAS // VALLE DEL MANTARO',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w400,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        const Text(
          'Rutas Optimizadas (VRPTW)',
          style: TextStyle(
            color: AppTheme.textHighContrast,
            fontSize: 20,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          'Planificación sostenible con mapa cartográfico de Huancayo y monitoreo CO₂',
          style: TextStyle(
            color: AppTheme.textMuted,
            fontSize: 12.5,
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
    );
  }
}

class _SummaryStatsBanner extends StatelessWidget {
  const _SummaryStatsBanner({required this.routes});

  final List<DeliveryRoute> routes;

  @override
  Widget build(BuildContext context) {
    double totalKm = 0;
    double totalCo2 = 0;
    double totalCombustible = 0;
    int totalStops = 0;

    for (final r in routes) {
      totalKm += r.distanciaKm;
      totalCo2 += r.co2Kg;
      totalCombustible += r.combustibleL;
      totalStops += r.pedidos.length;
    }

    final items = [
      _StatItem(
        label: 'Rutas Activas',
        value: '${routes.length}',
        icon: Icons.alt_route_rounded,
      ),
      _StatItem(
        label: 'Distancia Total',
        value: Formatters.km(totalKm),
        icon: Icons.straighten_rounded,
      ),
      _StatItem(
        label: 'Huella CO₂ Total',
        value: Formatters.co2(totalCo2),
        icon: Icons.eco_outlined,
        iconColor: AppTheme.primary,
      ),
      _StatItem(
        label: 'Combustible',
        value: Formatters.liters(totalCombustible),
        icon: Icons.local_gas_station_outlined,
      ),
      _StatItem(
        label: 'Total Entregas',
        value: '$totalStops pts',
        icon: Icons.pin_drop_outlined,
      ),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border, width: 1.0),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            for (int i = 0; i < items.length; i++) ...[
              if (i > 0) const SizedBox(width: 20),
              items[i],
            ],
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    this.iconColor = AppTheme.textSecondary,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: iconColor),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                color: AppTheme.textMuted,
                fontSize: 9,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                color: AppTheme.textHighContrast,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _GeneratingBanner extends StatelessWidget {
  const _GeneratingBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border, width: 1.0),
      ),
      child: const Row(
        children: [
          SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2.5, color: AppTheme.primary),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Optimizando rutas sostenibles para Huancayo...',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 13.5,
                    color: AppTheme.textHighContrast,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'El motor VRPTW está calculando la mejor combinación en el Valle del Mantaro para minimizar CO₂.',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RoutesTable extends StatelessWidget {
  const _RoutesTable({required this.routes, required this.canDelete});

  final List<DeliveryRoute> routes;
  final bool canDelete;

  static const List<String> _headers = [
    'Fecha',
    'Conductor',
    'Vehículo',
    'Paradas',
    'Distancia',
    'CO₂',
    'Combustible',
    'Estado',
    'Acciones',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border, width: 1.0),
      ),
      child: SingleChildScrollView(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingTextStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12.5,
              color: AppTheme.textHighContrast,
            ),
            dataTextStyle: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 12.5,
              color: AppTheme.textSecondary,
            ),
            dividerThickness: 1.0,
            horizontalMargin: 16,
            columnSpacing: 18,
            columns: _headers
                .map((header) => DataColumn(label: Text(header)))
                .toList(),
            rows: routes.map((route) {
              return DataRow(
                onSelectChanged: (_) => context.go('/routes/${route.id}'),
                cells: [
                  DataCell(Text(route.fecha,
                      style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textHighContrast))),
                  DataCell(Text(route.conductorNombre ?? '-')),
                  DataCell(Text(route.placa ?? '-')),
                  DataCell(Text('${route.pedidos.length} pts')),
                  DataCell(Text(Formatters.km(route.distanciaKm))),
                  DataCell(Text(Formatters.co2(route.co2Kg))),
                  DataCell(Text(Formatters.liters(route.combustibleL))),
                  DataCell(_EstadoChip(estado: route.estado)),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Ver detalle y mapa',
                          icon: const Icon(Icons.visibility_outlined,
                              size: 18, color: AppTheme.textSecondary),
                          onPressed: () => context.go('/routes/${route.id}'),
                        ),
                        if (canDelete)
                          IconButton(
                            tooltip: 'Eliminar',
                            icon: Icon(
                              Icons.delete_outline,
                              size: 18,
                              color: Theme.of(context).colorScheme.error,
                            ),
                            onPressed: () => _confirmDelete(context, route),
                          ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, DeliveryRoute route) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar ruta'),
        content: Text(
          '¿Seguro que desea eliminar la ruta del ${route.fecha} '
          '(${route.placa ?? 'sin vehículo'})?',
        ),
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
      context.read<RouteBloc>().add(RouteDeleted(route.id));
    }
  }
}

class _RoutesCardList extends StatelessWidget {
  const _RoutesCardList({required this.routes, required this.canDelete});

  final List<DeliveryRoute> routes;
  final bool canDelete;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: routes.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final route = routes[index];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.border, width: 1.0),
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            leading: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Center(
                child: Icon(Icons.route_outlined, color: AppTheme.primary, size: 20),
              ),
            ),
            title: Text(
              '${route.fecha} · ${route.placa ?? 'Sin vehículo'}',
              style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: AppTheme.textHighContrast),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 2),
                Text(
                  '${route.conductorNombre ?? '-'} · '
                  '${route.pedidos.length} paradas · '
                  '${Formatters.km(route.distanciaKm)} · '
                  '${Formatters.co2(route.co2Kg)}',
                  style: const TextStyle(
                      fontSize: 11.5,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w300),
                ),
                const SizedBox(height: 6),
                _EstadoChip(estado: route.estado),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Ver detalle y mapa',
                  icon: const Icon(Icons.visibility_outlined,
                      size: 18, color: AppTheme.textSecondary),
                  onPressed: () => context.go('/routes/${route.id}'),
                ),
                if (canDelete)
                  IconButton(
                    tooltip: 'Eliminar',
                    icon: Icon(
                      Icons.delete_outline,
                      size: 18,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    onPressed: () => _confirmDelete(context, route),
                  ),
              ],
            ),
            onTap: () => context.go('/routes/${route.id}'),
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, DeliveryRoute route) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar ruta'),
        content: const Text('¿Seguro que desea eliminar esta ruta?'),
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
      context.read<RouteBloc>().add(RouteDeleted(route.id));
    }
  }
}

class _EstadoChip extends StatelessWidget {
  const _EstadoChip({required this.estado});

  final String estado;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, border) = switch (estado) {
      'PLANIFICADA' => (
          const Color(0xFFEFF6FF),
          const Color(0xFF1D4ED8),
          const Color(0xFFBFDBFE)
        ),
      'EN_PROGRESO' => (
          const Color(0xFFFFFBEB),
          const Color(0xFFB45309),
          const Color(0xFFFDE68A)
        ),
      'COMPLETADA' => (
          const Color(0xFFF0FDF4),
          const Color(0xFF15803D),
          const Color(0xFFBBF7D0)
        ),
      'CANCELADA' => (
          const Color(0xFFFDF2F2),
          const Color(0xFFB91C1C),
          const Color(0xFFFCA5A5)
        ),
      _ => (
          const Color(0xFFF3F4F6),
          const Color(0xFF374151),
          const Color(0xFFE5E7EB)
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: border, width: 0.8),
      ),
      child: Text(
        estado,
        style:
            TextStyle(fontSize: 10.5, fontWeight: FontWeight.w500, color: fg),
      ),
    );
  }
}
