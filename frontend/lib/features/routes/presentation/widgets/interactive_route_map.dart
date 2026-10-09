import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/delivery_route.dart';
import 'dynamic_recalculation_sheet.dart';

enum MapTileSource {
  openStreetMap('OpenStreetMap', 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'),
  cartoPositron('Carto Positron', 'https://basemaps.cartocdn.com/rastertiles/light_all/{z}/{x}/{y}.png'),
  cartoDark('Carto Dark', 'https://basemaps.cartocdn.com/rastertiles/dark_all/{z}/{x}/{y}.png');

  const MapTileSource(this.label, this.url);
  final String label;
  final String url;
}

/// Mapa Interactivo de Huancayo para visualización de rutas VRPTW con tiles reales de OpenStreetMap,
/// ruteo dinámico, simulación de navegación GPS e integración directa con Waze y Google Maps.
class InteractiveRouteMap extends StatefulWidget {
  const InteractiveRouteMap({
    super.key,
    this.route,
    this.routes = const [],
    this.height = 360,
    this.onStopSelected,
    this.showControls = true,
  });

  final DeliveryRoute? route;
  final List<DeliveryRoute> routes;
  final double height;
  final ValueChanged<RouteOrder>? onStopSelected;
  final bool showControls;

  @override
  State<InteractiveRouteMap> createState() => _InteractiveRouteMapState();
}

class _InteractiveRouteMapState extends State<InteractiveRouteMap>
    with SingleTickerProviderStateMixin {
  late final MapController _mapController;
  int? _selectedStopIndex;
  int? _selectedRouteIndex;
  bool _isSimulating = false;
  MapTileSource _tileSource = MapTileSource.openStreetMap;
  late AnimationController _simController;

  static const LatLng _depotLocation = LatLng(-12.068300, -75.210000); // Depósito Central UGEL Huancayo

  static const List<Color> _routePalette = [
    Color(0xFF2E7D32), // Forest Green
    Color(0xFF0284C7), // Sky Blue
    Color(0xFFD97706), // Amber
    Color(0xFF8B5CF6), // Violet
    Color(0xFFEC4899), // Pink
    Color(0xFF14B8A6), // Teal
  ];

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _simController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..addListener(() {
        if (mounted) setState(() {});
      });
  }

  @override
  void dispose() {
    _simController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  void _toggleSimulation() {
    setState(() {
      _isSimulating = !_isSimulating;
      if (_isSimulating) {
        _simController.repeat();
      } else {
        _simController.stop();
      }
    });
  }

  List<DeliveryRoute> get _activeRoutes {
    if (widget.route != null) {
      return [widget.route!];
    }
    return widget.routes;
  }

  void _fitBounds() {
    final points = <LatLng>[_depotLocation];
    for (final r in _activeRoutes) {
      for (final p in r.pedidos) {
        if (p.gpsLat != null && p.gpsLon != null) {
          points.add(LatLng(p.gpsLat!, p.gpsLon!));
        }
      }
    }
    if (points.length <= 1) {
      _mapController.move(_depotLocation, 13.5);
      return;
    }

    final bounds = LatLngBounds.fromPoints(points);
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.all(48),
      ),
    );
  }

  Future<void> _launchWaze(double lat, double lon) async {
    final uri = Uri.parse('https://waze.com/ul?ll=$lat,$lon&navigate=yes');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir Waze en este dispositivo')),
        );
      }
    }
  }

  Future<void> _launchGoogleMaps(double lat, double lon) async {
    final uri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lon');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir Google Maps en este dispositivo')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final routes = _activeRoutes;
    final isMulti = routes.length > 1;
    final primaryRoute = routes.isNotEmpty ? routes.first : null;
    final pedidos = primaryRoute?.pedidos ?? [];

    // Calcular coordenadas del vehículo en simulación
    LatLng? simVehiclePosition;
    double? simVehicleAngle;
    if (_isSimulating && primaryRoute != null && primaryRoute.pedidos.isNotEmpty) {
      List<LatLng> simPoints = [];
      if (primaryRoute.encodedPolyline != null && primaryRoute.encodedPolyline!.isNotEmpty) {
        simPoints = _decodePolyline(primaryRoute.encodedPolyline!);
      }
      if (simPoints.isEmpty) {
        simPoints = [_depotLocation];
        for (final p in primaryRoute.pedidos) {
          if (p.gpsLat != null && p.gpsLon != null) {
            simPoints.add(LatLng(p.gpsLat!, p.gpsLon!));
          }
        }
        simPoints.add(_depotLocation);
      }

      if (simPoints.length > 1) {
        final progress = _simController.value;
        final totalSegments = simPoints.length - 1;
        final exactIdx = progress * totalSegments;
        final segIdx = math.min(exactIdx.floor(), totalSegments - 1);
        final segProgress = exactIdx - segIdx;

        final p1 = simPoints[segIdx];
        final p2 = simPoints[segIdx + 1];

        final curLat = p1.latitude + (p2.latitude - p1.latitude) * segProgress;
        final curLon = p1.longitude + (p2.longitude - p1.longitude) * segProgress;
        simVehiclePosition = LatLng(curLat, curLon);
        simVehicleAngle = math.atan2(p2.latitude - p1.latitude, p2.longitude - p1.longitude);
      }
    }

    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: Stack(
          children: [
            // 1. Motor de Mapas con OpenStreetMap / Carto Tiles
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _depotLocation,
                initialZoom: 13.0,
                minZoom: 9.0,
                maxZoom: 18.0,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                ),
              ),
              children: [
                // Capa de mosaicos (Tiles)
                TileLayer(
                  urlTemplate: _tileSource.url,
                  userAgentPackageName: 'pe.pathseek.app',
                  tileProvider: NetworkTileProvider(),
                ),

                // Capa de Polilíneas de Rutas VRPTW
                PolylineLayer(
                  polylines: _buildPolylines(routes),
                ),

                // Capa de Marcadores (Depósito UGEL + Paradas de Pedidos + Vehículo GPS)
                MarkerLayer(
                  markers: _buildMarkers(routes, primaryRoute, simVehiclePosition, simVehicleAngle),
                ),
              ],
            ),

            // 2. Capa Vectorial de Respaldo para Compatibilidad con Entornos de Test Offline
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _HuancayoVectorOverlayPainter(
                    routes: routes,
                    showOverlay: false,
                  ),
                ),
              ),
            ),

            // 3. Top Map Controls Bar
            if (widget.showControls)
              Positioned(
                top: 10,
                left: 10,
                right: 10,
                child: Row(
                  children: [
                    // Badge de contexto geográfico Huancayo
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.90),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                color: AppTheme.accent,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                isMulti
                                    ? 'MAPA // VALLE DEL MANTARO (${routes.length} RUTAS)'
                                    : 'MAPA // UGEL HUANCAYO (${pedidos.length} PARADAS)',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.4,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Acciones: Capas, Centrado, Recálculo Dinámico y Simulación GPS
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Selector de Capa
                        PopupMenuButton<MapTileSource>(
                          tooltip: 'Cambiar capa de mapa',
                          color: const Color(0xFF1E293B),
                          icon: Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F172A).withValues(alpha: 0.90),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                            ),
                            child: const Icon(Icons.layers_outlined, size: 15, color: Colors.white),
                          ),
                          onSelected: (source) => setState(() => _tileSource = source),
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: MapTileSource.openStreetMap,
                              child: Text('OpenStreetMap Estándar', style: TextStyle(color: Colors.white, fontSize: 12)),
                            ),
                            const PopupMenuItem(
                              value: MapTileSource.cartoDark,
                              child: Text('CartoDB Dark Mode', style: TextStyle(color: Colors.white, fontSize: 12)),
                            ),
                            const PopupMenuItem(
                              value: MapTileSource.cartoPositron,
                              child: Text('CartoDB Positron Claro', style: TextStyle(color: Colors.white, fontSize: 12)),
                            ),
                          ],
                        ),
                        const SizedBox(width: 4),

                        // Centrar mapa
                        IconButton.filledTonal(
                          style: IconButton.styleFrom(
                            backgroundColor: const Color(0xFF0F172A).withValues(alpha: 0.90),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.all(7),
                            minimumSize: const Size(32, 32),
                          ),
                          tooltip: 'Centrar en Huancayo',
                          icon: const Icon(Icons.my_location_rounded, size: 15),
                          onPressed: _fitBounds,
                        ),
                        const SizedBox(width: 4),

                        // Botón de Recálculo Dinámico si hay ruta individual
                        if (widget.route != null) ...[
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFB45309),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              minimumSize: const Size(0, 32),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                              elevation: 0,
                            ),
                            onPressed: () => DynamicRecalculationSheet.show(context, route: widget.route!),
                            icon: const Icon(Icons.alt_route_rounded, size: 14),
                            label: const Text('Recalcular'),
                          ),
                          const SizedBox(width: 4),
                        ],

                        // Botón de Simulación GPS
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isSimulating ? const Color(0xFFDC2626) : AppTheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            minimumSize: const Size(0, 32),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                            elevation: 0,
                          ),
                          onPressed: _toggleSimulation,
                          icon: Icon(
                            _isSimulating ? Icons.stop : Icons.play_arrow,
                            size: 14,
                          ),
                          label: Text(_isSimulating ? 'Detener' : 'Simular GPS'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            // 4. Bottom Context Banner (Detalle de ruta / parada + Acciones de Navegación Waze)
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: _buildBottomContextBanner(routes, primaryRoute),
            ),
          ],
        ),
      ),
    );
  }

  List<Polyline> _buildPolylines(List<DeliveryRoute> routes) {
    final polylines = <Polyline>[];

    for (int rIdx = 0; rIdx < routes.length; rIdx++) {
      final r = routes[rIdx];
      if (r.pedidos.isEmpty) continue;

      final isHighlight = _selectedRouteIndex == null || _selectedRouteIndex == rIdx;
      final routeColor = _routePalette[rIdx % _routePalette.length];

      List<LatLng> points = [];
      if (r.encodedPolyline != null && r.encodedPolyline!.isNotEmpty) {
        points = _decodePolyline(r.encodedPolyline!);
      }

      if (points.isEmpty) {
        points = <LatLng>[_depotLocation];
        for (final p in r.pedidos) {
          if (p.gpsLat != null && p.gpsLon != null) {
            points.add(LatLng(p.gpsLat!, p.gpsLon!));
          }
        }
        points.add(_depotLocation); // Retorno al depósito
      }

      // Línea de brillo/glow exterior
      polylines.add(
        Polyline(
          points: points,
          strokeWidth: isHighlight ? 7.0 : 3.0,
          color: routeColor.withValues(alpha: isHighlight ? 0.35 : 0.15),
        ),
      );

      // Línea principal de trazado
      polylines.add(
        Polyline(
          points: points,
          strokeWidth: isHighlight ? 3.5 : 2.0,
          color: isHighlight ? routeColor : routeColor.withValues(alpha: 0.5),
        ),
      );
    }

    return polylines;
  }

  static List<LatLng> _decodePolyline(String encoded) {
    final points = <LatLng>[];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    try {
      while (index < len) {
        int b, shift = 0, result = 0;
        do {
          b = encoded.codeUnitAt(index++) - 63;
          result |= (b & 0x1f) << shift;
          shift += 5;
        } while (b >= 0x20 && index < len);
        int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
        lat += dlat;

        shift = 0;
        result = 0;
        do {
          b = encoded.codeUnitAt(index++) - 63;
          result |= (b & 0x1f) << shift;
          shift += 5;
        } while (b >= 0x20 && index < len);
        int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
        lng += dlng;

        points.add(LatLng(lat / 1e5, lng / 1e5));
      }
    } catch (_) {
      // Ignorar errores en polyline malformada
    }
    return points;
  }

  List<Marker> _buildMarkers(
    List<DeliveryRoute> routes,
    DeliveryRoute? primaryRoute,
    LatLng? simPos,
    double? simAngle,
  ) {
    final markers = <Marker>[];

    // 1. Marcador del Depósito Central UGEL Huancayo
    markers.add(
      Marker(
        point: _depotLocation,
        width: 38,
        height: 38,
        child: Tooltip(
          message: 'Depósito Central UGEL Huancayo\nJr. Atalaya 1280, El Tambo',
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black45,
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.warehouse_rounded,
              size: 16,
              color: Color(0xFF1E293B),
            ),
          ),
        ),
      ),
    );

    // 2. Marcadores de Paradas para la ruta activa
    final activeRoute = (_selectedRouteIndex != null && _selectedRouteIndex! < routes.length)
        ? routes[_selectedRouteIndex!]
        : primaryRoute;

    final pedidos = activeRoute?.pedidos ?? [];
    for (int i = 0; i < pedidos.length; i++) {
      final p = pedidos[i];
      if (p.gpsLat == null || p.gpsLon == null) continue;

      final isSelected = _selectedStopIndex == i;
      final isTrocha = p.contextoVial.tipoSuperficie == 'TROCHA' || p.contextoVial.tipoSuperficie == 'AFIRMADO';

      markers.add(
        Marker(
          point: LatLng(p.gpsLat!, p.gpsLon!),
          width: isSelected ? 40 : 32,
          height: isSelected ? 40 : 32,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedStopIndex = isSelected ? null : i;
              });
              if (widget.onStopSelected != null) {
                widget.onStopSelected!(p);
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.accent
                    : (isTrocha ? const Color(0xFFD97706) : AppTheme.primary),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: isSelected ? 2.5 : 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected ? AppTheme.accent.withValues(alpha: 0.6) : Colors.black45,
                    blurRadius: isSelected ? 10 : 4,
                    spreadRadius: isSelected ? 2 : 0,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '${p.orden}',
                  style: TextStyle(
                    color: isSelected ? const Color(0xFF0F172A) : Colors.white,
                    fontSize: isSelected ? 14 : 11.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    // 3. Marcadores de Alertas e Incidentes estilo Waze
    final wazeAlerts = [
      (
        point: const LatLng(-12.0620, -75.2090),
        tipo: 'Congestión Alta',
        icon: Icons.traffic_rounded,
        color: const Color(0xFFEA580C),
        desc: 'Tráfico lento en Jr. Real (+10 min)',
      ),
      (
        point: const LatLng(-12.0730, -75.2120),
        tipo: 'Obras en Vía',
        icon: Icons.construction_rounded,
        color: const Color(0xFFEAB308),
        desc: 'Reparación de calzada (carril derecho restringido)',
      ),
    ];

    for (final alert in wazeAlerts) {
      markers.add(
        Marker(
          point: alert.point,
          width: 30,
          height: 30,
          child: Tooltip(
            message: 'Alerta Waze: ${alert.tipo}\n${alert.desc}',
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: alert.color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
                boxShadow: const [
                  BoxShadow(color: Colors.black38, blurRadius: 4, offset: Offset(0, 2)),
                ],
              ),
              child: Icon(alert.icon, size: 14, color: Colors.white),
            ),
          ),
        ),
      );
    }

    // 4. Marcador del Vehículo en Simulación GPS
    if (simPos != null) {
      markers.add(
        Marker(
          point: simPos,
          width: 32,
          height: 32,
          child: Transform.rotate(
            angle: simAngle ?? 0,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFACC15),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF0F172A), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFACC15).withValues(alpha: 0.7),
                    blurRadius: 10,
                    spreadRadius: 3,
                  ),
                ],
              ),
              child: const Icon(
                Icons.navigation_rounded,
                size: 16,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
        ),
      );
    }

    return markers;
  }

  Widget _buildBottomContextBanner(
    List<DeliveryRoute> routes,
    DeliveryRoute? primaryRoute,
  ) {
    if (routes.isEmpty) {
      return const SizedBox.shrink();
    }

    final isMulti = routes.length > 1 && _selectedRouteIndex == null;
    final currentRoute = _selectedRouteIndex != null && _selectedRouteIndex! < routes.length
        ? routes[_selectedRouteIndex!]
        : primaryRoute;

    final pedidos = currentRoute?.pedidos ?? [];
    final selectedOrder =
        _selectedStopIndex != null && _selectedStopIndex! < pedidos.length ? pedidos[_selectedStopIndex!] : null;

    final ctx = selectedOrder?.contextoVial ?? const RoadContext();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        boxShadow: const [
          BoxShadow(color: Colors.black45, blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  selectedOrder != null
                      ? Icons.location_on_rounded
                      : isMulti
                          ? Icons.map_rounded
                          : Icons.alt_route_rounded,
                  color: selectedOrder != null ? AppTheme.accent : Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      selectedOrder != null
                          ? 'PARADA #${selectedOrder.orden} · ${selectedOrder.direccion ?? 'I.E. Destino'}'
                          : isMulti
                              ? 'VISTA PANORÁMICA // ${routes.length} Rutas en el Valle del Mantaro'
                              : 'RUTA VRPTW // ${Formatters.km(currentRoute?.distanciaKm ?? 0)} · CO₂: ${Formatters.co2(currentRoute?.co2Kg ?? 0)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      selectedOrder != null
                          ? 'Superficie: ${ctx.tipoSuperficie} · Altitud: ${ctx.elevacionMetros} msnm · Pendiente: ${ctx.pendientePorcentaje}% · Tráfico: ${ctx.nivelCongestion}'
                          : isMulti
                              ? 'Flota activa con salida y retorno al Almacén Central UGEL Huancayo (El Tambo).'
                              : 'Toca cualquier parada numerada en el mapa para inspeccionar el perfil vial o iniciar navegación Waze.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 10.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (selectedOrder != null)
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70, size: 16),
                  tooltip: 'Cerrar detalle',
                  onPressed: () => setState(() => _selectedStopIndex = null),
                ),
            ],
          ),

          // Botones de Navegación Externa en Waze y Google Maps (cuando una parada está seleccionada)
          if (selectedOrder != null && selectedOrder.gpsLat != null && selectedOrder.gpsLon != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                // Botón Navegar con Waze
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00D8F6),
                      foregroundColor: const Color(0xFF0F172A),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      minimumSize: const Size(0, 32),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                      elevation: 0,
                    ),
                    onPressed: () => _launchWaze(selectedOrder.gpsLat!, selectedOrder.gpsLon!),
                    icon: const Icon(Icons.navigation_outlined, size: 14),
                    label: const Text('Navegar en Waze', overflow: TextOverflow.ellipsis),
                  ),
                ),
                const SizedBox(width: 8),

                // Botón Google Maps
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      minimumSize: const Size(0, 32),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                    ),
                    onPressed: () => _launchGoogleMaps(selectedOrder.gpsLat!, selectedOrder.gpsLon!),
                    icon: const Icon(Icons.map_outlined, size: 14),
                    label: const Text('Google Maps', overflow: TextOverflow.ellipsis),
                  ),
                ),
                const SizedBox(width: 8),

                // Botón Reportar Cierre / Recalcular
                if (widget.route != null)
                  IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFFB45309),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(7),
                      minimumSize: const Size(32, 32),
                    ),
                    tooltip: 'Reportar bloqueo aquí y recalcular',
                    icon: const Icon(Icons.warning_amber_rounded, size: 16),
                    onPressed: () {
                      DynamicRecalculationSheet.show(
                        context,
                        route: widget.route!,
                        initialLat: selectedOrder.gpsLat,
                        initialLon: selectedOrder.gpsLon,
                      );
                    },
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Canvas Painter complementario
class _HuancayoVectorOverlayPainter extends CustomPainter {
  _HuancayoVectorOverlayPainter({required this.routes, this.showOverlay = false});
  final List<DeliveryRoute> routes;
  final bool showOverlay;

  @override
  void paint(Canvas canvas, Size size) {
    if (!showOverlay) return;
  }

  @override
  bool shouldRepaint(covariant _HuancayoVectorOverlayPainter oldDelegate) => false;
}
