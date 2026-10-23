import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/permissions.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/page_header.dart';
import '../../../../core/widgets/search_sort_controls.dart';
import '../../../../core/widgets/empty_view.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/delivery_route.dart';
import '../bloc/route_bloc.dart';
import '../widgets/route_status_badge.dart';

class RouteListPage extends StatelessWidget {
  const RouteListPage({super.key});
  @override
  Widget build(BuildContext context) => BlocProvider<RouteBloc>(
    create: (_) => locator<RouteBloc>()..add(const RoutesLoaded()),
    child: const RouteListView(),
  );
}

class RouteListView extends StatefulWidget {
  const RouteListView({super.key});
  @override
  State<RouteListView> createState() => _RouteListViewState();
}

class _RouteListViewState extends State<RouteListView> {
  final query = TextEditingController();
  String status = 'TODAS';
  String sort = 'fecha';
  static const statuses = {
    'TODAS': 'Todas',
    'PLANIFICADA': 'Planificadas',
    'EN_PROGRESO': 'En progreso',
    'COMPLETADA': 'Completadas',
    'CANCELADA': 'Canceladas',
  };
  @override
  void dispose() {
    query.dispose();
    super.dispose();
  }

  List<DeliveryRoute> visible(List<DeliveryRoute> routes) {
    final term = query.text.trim().toLowerCase();
    final result = routes
        .where(
          (r) =>
              (status == 'TODAS' || r.estado == status) &&
              '${r.fecha} ${r.placa ?? ''} ${r.conductorNombre ?? ''}'
                  .toLowerCase()
                  .contains(term),
        )
        .toList();
    result.sort(
      (a, b) => switch (sort) {
        'distancia' => b.distanciaKm.compareTo(a.distanciaKm),
        'co2' => b.co2Kg.compareTo(a.co2Kg),
        _ => b.fecha.compareTo(a.fecha),
      },
    );
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthBloc>().state.user;
    final canGenerate = AppPermissions.canCreate(user, AppModule.routes);
    final canDelete = AppPermissions.canDelete(user, AppModule.routes);
    final theme = Theme.of(context);
    return BlocConsumer<RouteBloc, RouteState>(
      listenWhen: (p, c) =>
          (!p.generateSuccess && c.generateSuccess) ||
          (c.generateErrorMessage != null &&
              p.generateErrorMessage != c.generateErrorMessage) ||
          (c.saveErrorMessage != null &&
              p.saveErrorMessage != c.saveErrorMessage),
      listener: (context, state) {
        final error = state.generateErrorMessage ?? state.saveErrorMessage;
        final message =
            error ??
            '${state.generatedRoutes} rutas generadas. ${state.unassignedOrders} pedidos sin asignar.';
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: error == null ? null : theme.colorScheme.error,
            ),
          );
      },
      builder: (context, state) {
        final routes = visible(state.routes);
        return LayoutBuilder(
          builder: (context, constraints) {
            final padding = constraints.maxWidth < 600 ? 16.0 : 28.0;
            final cards =
                constraints.maxWidth < 1050 ||
                MediaQuery.textScalerOf(context).scale(16) > 22;
            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.all(padding),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PageHeader(
                          title: user?.rol == 'CONDUCTOR'
                              ? 'Mis rutas'
                              : 'Rutas de distribución',
                          description: user?.rol == 'CONDUCTOR'
                              ? 'Consulta tus entregas y abre el mapa de cada recorrido.'
                              : 'Consulta la planificación, las entregas y el impacto estimado de cada recorrido.',
                          icon: Icons.route_outlined,
                          actions: [
                            OutlinedButton.icon(
                              onPressed: state.isGenerating || state.isLoading
                                  ? null
                                  : () => context.read<RouteBloc>().add(
                                      const RoutesLoaded(),
                                    ),
                              icon: const Icon(Icons.refresh),
                              label: const Text('Actualizar'),
                            ),
                            if (canGenerate)
                              FilledButton.icon(
                                onPressed: state.isGenerating
                                    ? null
                                    : () => context.read<RouteBloc>().add(
                                        const RoutesGenerated(),
                                      ),
                                icon: state.isGenerating
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.alt_route),
                                label: Text(
                                  state.isGenerating
                                      ? 'Generando…'
                                      : 'Generar rutas',
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        SearchSortControls<String>(
                          queryController: query,
                          hint: 'Fecha, placa o conductor',
                          sortItems: const {
                            'fecha': 'Fecha más reciente',
                            'distancia': 'Mayor distancia',
                            'co2': 'Mayor CO₂',
                          },
                          sortValue: sort,
                          onQueryChanged: () => setState(() {}),
                          onSortChanged: (value) =>
                              setState(() => sort = value),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: statuses.entries
                              .map(
                                (entry) => ChoiceChip(
                                  label: Text(entry.value),
                                  selected: status == entry.key,
                                  onSelected: (_) =>
                                      setState(() => status = entry.key),
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '${routes.length} de ${state.routes.length} rutas',
                          style: theme.textTheme.labelLarge,
                        ),
                        if (state.isGenerating) ...[
                          const SizedBox(height: 16),
                          const LinearProgressIndicator(),
                          const SizedBox(height: 8),
                          Semantics(
                            liveRegion: true,
                            child: const Text(
                              'Planificando los pedidos pendientes. Puedes seguir consultando las rutas existentes.',
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                if (state.isLoading)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: LoadingIndicator(message: 'Cargando rutas…'),
                  )
                else if (state.hasError)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: ErrorView(
                      message: state.errorMessage!,
                      onRetry: () =>
                          context.read<RouteBloc>().add(const RoutesLoaded()),
                    ),
                  )
                else if (routes.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyView(
                      icon: Icons.route_outlined,
                      message: state.routes.isNotEmpty
                          ? 'No hay rutas que coincidan con tu búsqueda o estado.'
                          : canGenerate
                          ? 'Todavía no hay rutas. Genera la planificación para los pedidos pendientes.'
                          : user?.rol == 'CONDUCTOR'
                          ? 'Todavía no tienes rutas asignadas. Consulta con el equipo de operaciones.'
                          : 'Todavía no hay rutas disponibles para consultar.',
                    ),
                  )
                else if (cards)
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(padding, 0, padding, padding),
                    sliver: SliverList.builder(
                      itemCount: routes.length,
                      itemBuilder: (context, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _RouteCard(
                          route: routes[i],
                          canDelete: canDelete && !state.isSaving,
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(padding, 0, padding, padding),
                    sliver: SliverToBoxAdapter(
                      child: Card(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minWidth: constraints.maxWidth - padding * 2 - 8,
                            ),
                            child: DataTable(
                              showCheckboxColumn: false,
                              columns:
                                  const [
                                        'Fecha / placa',
                                        'Conductor',
                                        'Distancia',
                                        'CO₂ estimado',
                                        'Combustible',
                                        'Estado',
                                        'Acciones',
                                      ]
                                      .map(
                                        (label) =>
                                            DataColumn(label: Text(label)),
                                      )
                                      .toList(),
                              rows: routes
                                  .map(
                                    (route) => DataRow(
                                      onSelectChanged: (_) =>
                                          context.go('/routes/${route.id}'),
                                      cells: [
                                        DataCell(
                                          Text(
                                            '${route.fecha}\n${route.placa ?? 'Sin vehículo'}',
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            route.conductorNombre ??
                                                'Sin asignar',
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            Formatters.km(route.distanciaKm),
                                          ),
                                        ),
                                        DataCell(
                                          Text(Formatters.co2(route.co2Kg)),
                                        ),
                                        DataCell(
                                          Text(
                                            Formatters.liters(
                                              route.combustibleL,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          RouteStatusBadge(
                                            status: route.estado,
                                          ),
                                        ),
                                        DataCell(
                                          _RouteActions(
                                            route: route,
                                            canDelete:
                                                canDelete && !state.isSaving,
                                            compact: true,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}

class _RouteCard extends StatelessWidget {
  const _RouteCard({required this.route, required this.canDelete});
  final DeliveryRoute route;
  final bool canDelete;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                route.placa ?? 'Sin vehículo',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              RouteStatusBadge(status: route.estado),
            ],
          ),
          const SizedBox(height: 12),
          Text('${route.fecha} · ${route.conductorNombre ?? 'Sin conductor'}'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 20,
            runSpacing: 8,
            children: [
              Text(Formatters.km(route.distanciaKm)),
              Text(Formatters.co2(route.co2Kg)),
              Text(Formatters.liters(route.combustibleL)),
            ],
          ),
          const Divider(),
          _RouteActions(route: route, canDelete: canDelete),
        ],
      ),
    ),
  );
}

class _RouteActions extends StatelessWidget {
  const _RouteActions({
    required this.route,
    required this.canDelete,
    this.compact = false,
  });
  final DeliveryRoute route;
  final bool canDelete;
  final bool compact;
  @override
  Widget build(BuildContext context) {
    void open() => context.go('/routes/${route.id}');
    Future<void> delete() async {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialog) => AlertDialog(
          title: const Text('¿Eliminar ruta planificada?'),
          content: Text(
            'La ruta del ${route.fecha} (${route.placa ?? 'sin vehículo'}) se eliminará. Sus pedidos en ruta volverán a estar pendientes.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialog, false),
              child: const Text('Conservar ruta'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(dialog).colorScheme.error,
              ),
              onPressed: () => Navigator.pop(dialog, true),
              child: const Text('Eliminar ruta'),
            ),
          ],
        ),
      );
      if (confirmed == true && context.mounted) {
        context.read<RouteBloc>().add(RouteDeleted(route.id));
      }
    }

    final removable = canDelete && route.estado == 'PLANIFICADA';
    if (compact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Ver ruta y mapa',
            onPressed: open,
            icon: const Icon(Icons.map_outlined),
          ),
          if (removable)
            IconButton(
              tooltip: 'Eliminar ruta planificada',
              onPressed: delete,
              color: Theme.of(context).colorScheme.error,
              icon: const Icon(Icons.delete_outline),
            ),
        ],
      );
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        TextButton.icon(
          onPressed: open,
          icon: const Icon(Icons.map_outlined),
          label: const Text('Ver ruta y mapa'),
        ),
        if (removable)
          TextButton.icon(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: delete,
            icon: const Icon(Icons.delete_outline),
            label: const Text('Eliminar'),
          ),
      ],
    );
  }
}
