import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/entities/delivery_route.dart';
import '../../../../core/utils/formatters.dart';
import 'route_coordinates.dart';

class InteractiveRouteMap extends StatefulWidget {
  const InteractiveRouteMap({
    super.key,
    required this.route,
    this.height = 400,
    this.onStopSelected,
    this.showBaseMap = true,
  });
  final DeliveryRoute route;

  /// Height of the geographic viewport; controls and details grow with text size.
  final double height;
  final ValueChanged<RouteOrder>? onStopSelected;
  final bool showBaseMap;
  @override
  State<InteractiveRouteMap> createState() => _InteractiveRouteMapState();
}

class _InteractiveRouteMapState extends State<InteractiveRouteMap> {
  static const depot = LatLng(-12.0683, -75.2100);
  final controller = MapController();
  RouteOrder? selected;
  bool tileError = false;
  int tileAttempt = 0;
  static bool valid(RouteOrder p) =>
      p.gpsLat != null &&
      p.gpsLon != null &&
      p.gpsLat!.isFinite &&
      p.gpsLon!.isFinite &&
      p.gpsLat!.abs() <= 90 &&
      p.gpsLon!.abs() <= 180;
  List<RouteOrder> get stops =>
      widget.route.pedidos.where(valid).toList()
        ..sort((a, b) => a.orden.compareTo(b.orden));
  List<LatLng> get points {
    final decoded = decodeRoutePolyline(widget.route.encodedPolyline);
    return decoded.length >= 2
        ? decoded
        : [depot, ...stops.map((p) => LatLng(p.gpsLat!, p.gpsLon!)), depot];
  }

  void fit() => controller.fitCamera(
    CameraFit.bounds(
      bounds: LatLngBounds.fromPoints(points),
      padding: const EdgeInsets.all(60),
      maxZoom: 15,
    ),
  );
  void select(RouteOrder p) {
    setState(() => selected = p);
    controller.move(
      LatLng(p.gpsLat!, p.gpsLon!),
      controller.camera.zoom.clamp(14, 19).toDouble(),
    );
    widget.onStopSelected?.call(p);
  }

  @override
  void didUpdateWidget(covariant InteractiveRouteMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.route != widget.route) {
      selected = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) fit();
      });
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final deliveries = stops;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Mapa de entregas', style: theme.textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              '${deliveries.length} paradas · Trazado estimado · Sin tráfico en vivo',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ExcludeSemantics(
                    child: Icon(
                      Icons.warehouse_outlined,
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Origen y retorno',
                          style: theme.textTheme.labelLarge,
                        ),
                        const Text('Depósito UGEL · Atalaya 1280'),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Ver origen',
                    onPressed: () => controller.move(depot, 15),
                    icon: const Icon(Icons.my_location_outlined),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: fit,
                  icon: const Icon(Icons.center_focus_strong),
                  label: const Text('Ver ruta completa'),
                ),
                IconButton.outlined(
                  tooltip: 'Alejar',
                  onPressed: () => controller.move(
                    controller.camera.center,
                    (controller.camera.zoom - 1).clamp(3, 19).toDouble(),
                  ),
                  icon: const Icon(Icons.remove),
                ),
                IconButton.outlined(
                  tooltip: 'Acercar',
                  onPressed: () => controller.move(
                    controller.camera.center,
                    (controller.camera.zoom + 1).clamp(3, 19).toDouble(),
                  ),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            if (deliveries.isNotEmpty) ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                key: ValueKey(selected?.pedidoId),
                initialValue: selected?.pedidoId,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Ir a una entrega',
                  prefixIcon: Icon(Icons.place_outlined),
                ),
                items: deliveries
                    .map(
                      (p) => DropdownMenuItem(
                        value: p.pedidoId,
                        child: Text(
                          '${p.orden}. ${p.direccion ?? 'Entrega sin dirección'}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (id) {
                  if (id != null) {
                    select(deliveries.firstWhere((p) => p.pedidoId == id));
                  }
                },
              ),
            ],
            if (tileError)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Semantics(
                  liveRegion: true,
                  child: Text(
                    'Mapa base no disponible. Se conservan las paradas y el trazado.',
                    style: TextStyle(color: colors.error),
                  ),
                ),
              ),
            if (deliveries.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Text(
                  'No hay entregas con coordenadas válidas para mostrar. El depósito permanece visible.',
                ),
              ),
            if (deliveries.length != widget.route.pedidos.length)
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Text(
                  'Hay entregas sin coordenadas válidas; puedes consultarlas en la lista.',
                ),
              ),
            const SizedBox(height: 12),
            SizedBox(
              height: widget.height,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: FlutterMap(
                  key: ValueKey('map-${widget.route.id}'),
                  mapController: controller,
                  options: MapOptions(
                    initialCenter: depot,
                    initialZoom: 13,
                    initialCameraFit: CameraFit.bounds(
                      bounds: LatLngBounds.fromPoints(points),
                      padding: const EdgeInsets.all(60),
                      maxZoom: 15,
                    ),
                  ),
                  children: [
                    if (widget.showBaseMap)
                      TileLayer(
                        key: ValueKey(tileAttempt),
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'pe.edu.ugelhuancayo.pathseek',
                        errorTileCallback: (tile, error, stack) {
                          if (!tileError) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (mounted && !tileError) {
                                setState(() => tileError = true);
                              }
                            });
                          }
                        },
                      ),
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: points,
                          strokeWidth: 5,
                          color: colors.primary,
                        ),
                      ],
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: depot,
                          width: 48,
                          height: 48,
                          child: Tooltip(
                            message:
                                'Origen y retorno: depósito UGEL, Atalaya 1280',
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: colors.surface,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: colors.primary,
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                Icons.warehouse_outlined,
                                color: colors.primary,
                              ),
                            ),
                          ),
                        ),
                        ...deliveries.map(
                          (p) => Marker(
                            point: LatLng(p.gpsLat!, p.gpsLon!),
                            width: 48,
                            height: 48,
                            child: Semantics(
                              label:
                                  'Seleccionar parada ${p.orden}: ${p.direccion ?? 'Entrega'}',
                              button: true,
                              selected: selected?.pedidoId == p.pedidoId,
                              child: Material(
                                color: selected?.pedidoId == p.pedidoId
                                    ? colors.primary
                                    : colors.surface,
                                shape: CircleBorder(
                                  side: BorderSide(
                                    color: colors.primary,
                                    width: selected?.pedidoId == p.pedidoId
                                        ? 4
                                        : 2,
                                  ),
                                ),
                                child: InkWell(
                                  key: ValueKey('stop-${p.pedidoId}'),
                                  customBorder: const CircleBorder(),
                                  onTap: () => select(p),
                                  child: Center(
                                    child: Text(
                                      '${p.orden}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: selected?.pedidoId == p.pedidoId
                                            ? colors.onPrimary
                                            : colors.primary,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: ColoredBox(
                        color: colors.surface,
                        child: TextButton(
                          onPressed: () => launchUrl(
                            Uri.parse(
                              'https://www.openstreetmap.org/copyright',
                            ),
                          ),
                          child: const Text('© OpenStreetMap contributors'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ExcludeSemantics(
                      child: Icon(
                        Icons.warehouse_outlined,
                        size: 18,
                        color: colors.primary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text('Depósito'),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ExcludeSemantics(
                      child: Icon(
                        Icons.location_on_outlined,
                        size: 18,
                        color: colors.primary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Flexible(child: Text('Entregas numeradas')),
                  ],
                ),
              ],
            ),
            if (tileError)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => setState(() {
                    tileError = false;
                    tileAttempt++;
                  }),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar mapa'),
                ),
              ),
            const SizedBox(height: 12),
            if (selected case final p?)
              Semantics(
                liveRegion: true,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colors.primaryContainer.withValues(alpha: .35),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Parada #${p.orden}: ${p.direccion ?? 'Dirección no disponible'}',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 16,
                        runSpacing: 8,
                        children: [
                          Text('Cliente: ${p.clienteId ?? 'No disponible'}'),
                          Text(
                            'Ventana: ${p.ventanaInicio ?? '—'}–${p.ventanaFin ?? '—'}',
                          ),
                          Text('Llegada estimada: ${p.horaEstimada ?? '—'}'),
                          Text(
                            'Peso: ${Formatters.decimal.format(p.peso ?? 0)} kg',
                          ),
                        ],
                      ),
                      TextButton.icon(
                        onPressed: () => setState(() => selected = null),
                        icon: const Icon(Icons.close),
                        label: const Text('Cerrar detalle'),
                      ),
                    ],
                  ),
                ),
              )
            else
              Text(
                'Selecciona una parada en el mapa o en la lista para consultar la entrega.',
                style: theme.textTheme.bodyMedium,
              ),
          ],
        ),
      ),
    );
  }
}
