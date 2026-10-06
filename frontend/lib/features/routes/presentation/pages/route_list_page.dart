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

class RouteListView extends StatelessWidget {
  const RouteListView({super.key});

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
              : '${state.generatedRoutes} rutas generadas correctamente.';
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
          padding: EdgeInsets.all(narrow ? 16 : 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (narrow)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _TitleBadge(),
                    const SizedBox(height: 12),
                    if (canGenerate)
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: state.isGenerating
                              ? null
                              : () => context
                                  .read<RouteBloc>()
                                  .add(const RoutesGenerated()),
                          icon: const Icon(Icons.alt_route),
                          label: const Text('Generar rutas'),
                        ),
                      ),
                  ],
                )
              else
                Row(
                  children: [
                    const _TitleBadge(),
                    const Spacer(),
                    if (canGenerate)
                      FilledButton.icon(
                        onPressed: state.isGenerating
                            ? null
                            : () => context
                                .read<RouteBloc>()
                                .add(const RoutesGenerated()),
                        icon: const Icon(Icons.alt_route),
                        label: const Text('Generar rutas'),
                      ),
                  ],
                ),
              const SizedBox(height: 20),
              if (state.isGenerating)
                const _GeneratingBanner()
              else
                Expanded(child: _buildBody(context, state, canDelete)),
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
  ) {
    if (state.isLoading) {
      return const LoadingIndicator(message: 'Cargando rutas...');
    }

    if (state.hasError) {
      return ErrorView(
        message: state.errorMessage!,
        onRetry: () => context.read<RouteBloc>().add(const RoutesLoaded()),
      );
    }

    if (state.isEmpty) {
      return const EmptyView(
        message: 'Aun no hay rutas generadas. Usa "Generar rutas" para '
            'planificar los pedidos pendientes.',
        icon: Icons.route_outlined,
      );
    }

    if (isNarrow(context)) {
      return _RoutesCardList(routes: state.routes, canDelete: canDelete);
    }

    return _RoutesTable(routes: state.routes, canDelete: canDelete);
  }
}

class _TitleBadge extends StatelessWidget {
  const _TitleBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.primaryDark,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text(
        'GESTIÓN DE RUTAS',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 20,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _GeneratingBanner extends StatelessWidget {
  const _GeneratingBanner();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Optimizando rutas...',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'El motor de optimizacion puede tardar hasta 45 segundos '
                    '(SLA RNF-001). No cierres esta pantalla.',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
    'Vehiculo',
    'Distancia (km)',
    'CO2 (kg)',
    'Combustible (L)',
    'Estado',
    'Acciones',
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: _headers
              .map((header) => DataColumn(label: Text(header)))
              .toList(),
          rows: routes.map((route) {
            return DataRow(
              onSelectChanged: (_) => context.go('/routes/${route.id}'),
              cells: [
                DataCell(Text(route.fecha)),
                DataCell(Text(route.conductorNombre ?? '-')),
                DataCell(Text(route.placa ?? '-')),
                DataCell(Text(Formatters.decimal.format(route.distanciaKm))),
                DataCell(Text(Formatters.decimal.format(route.co2Kg))),
                DataCell(Text(Formatters.decimal.format(route.combustibleL))),
                DataCell(_EstadoChip(estado: route.estado)),
                DataCell(
                  Row(
                    children: [
                      IconButton(
                        tooltip: 'Ver detalle',
                        icon: const Icon(Icons.visibility_outlined),
                        onPressed: () => context.go('/routes/${route.id}'),
                      ),
                      if (canDelete)
                        IconButton(
                          tooltip: 'Eliminar',
                          icon: Icon(
                            Icons.delete_outline,
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
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, DeliveryRoute route) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar ruta'),
        content: Text(
          'Seguro que desea eliminar la ruta del ${route.fecha} '
          '(${route.placa ?? 'sin vehiculo'})?',
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
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final route = routes[index];
        return Card(
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: const CircleAvatar(
              backgroundColor: AppTheme.primary,
              child: Icon(Icons.route, color: Colors.white, size: 20),
            ),
            title: Text(
              '${route.fecha} - ${route.placa ?? 'Sin vehiculo'}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${route.conductorNombre ?? '-'} · '
                  '${Formatters.km(route.distanciaKm)} · '
                  '${Formatters.co2(route.co2Kg)}',
                ),
                const SizedBox(height: 4),
                _EstadoChip(estado: route.estado),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Ver detalle',
                  icon: const Icon(Icons.visibility_outlined),
                  onPressed: () => context.go('/routes/${route.id}'),
                ),
                if (canDelete)
                  IconButton(
                    tooltip: 'Eliminar',
                    icon: Icon(
                      Icons.delete_outline,
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
        content: Text('Seguro que desea eliminar esta ruta?'),
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
    final (color, foreground) = switch (estado) {
      'PLANIFICADA' => (Colors.blue.shade100, Colors.blue.shade900),
      'EN_PROGRESO' => (Colors.orange.shade100, Colors.orange.shade900),
      'COMPLETADA' => (Colors.green.shade100, Colors.green.shade900),
      'CANCELADA' => (Colors.red.shade100, Colors.red.shade900),
      _ => (Colors.grey.shade200, Colors.grey.shade800),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        estado,
        style: TextStyle(fontSize: 12, color: foreground),
      ),
    );
  }
}
