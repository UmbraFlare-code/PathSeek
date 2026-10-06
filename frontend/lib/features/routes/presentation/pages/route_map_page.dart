import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:pathseek/features/routes/domain/entities/route_plan.dart';

/// RF-004: visualización de rutas en mapa interactivo (flutter_map + OSM).
/// Recibe el plan por navegación (`extra`), igual que los form-pages.
class RouteMapPage extends StatelessWidget {
  const RouteMapPage({super.key, this.plan});

  final RoutePlan? plan;

  @override
  Widget build(BuildContext context) {
    return RouteMapView(plan: plan);
  }
}

class RouteMapView extends StatefulWidget {
  const RouteMapView({super.key, this.plan});

  final RoutePlan? plan;

  @override
  State<RouteMapView> createState() => _RouteMapViewState();
}

class _RouteMapViewState extends State<RouteMapView> {
  /// Placas ocultas con los chips de filtro (todas visibles por defecto).
  final Set<String> _hiddenPlacas = {};

  static const List<Color> _routeColors = [
    Colors.blue,
    Colors.green,
    Colors.deepOrange,
    Colors.purple,
    Colors.teal,
    Colors.brown,
  ];

  static Color congestionColor(String nivel) {
    return switch (nivel) {
      'alta' => Colors.red,
      'media' => Colors.orange,
      _ => Colors.green,
    };
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.plan;
    if (p == null || p.rutas.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.map_outlined, size: 64),
            const SizedBox(height: 12),
            const Text('Aún no hay rutas generadas'),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => context.go('/routes'),
              child: const Text('Generar rutas'),
            ),
          ],
        ),
      );
    }

    final depot = LatLng(p.depositoLat, p.depositoLon);
    final polylines = <Polyline>[];
    final markers = <Marker>[
      Marker(
        point: depot,
        width: 90,
        height: 60,
        child: const Column(
          children: [
            Icon(Icons.home, color: Colors.black87, size: 30),
            Text(
              'UGEL',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                backgroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    ];

    for (var i = 0; i < p.rutas.length; i++) {
      final route = p.rutas[i];
      if (_hiddenPlacas.contains(route.placa)) continue;
      final base = _routeColors[i % _routeColors.length];
      var from = depot;
      for (final stop in route.paradas) {
        final to = LatLng(stop.gpsLat, stop.gpsLon);
        polylines.add(
          Polyline(
            points: [from, to],
            color: congestionColor(stop.congestion),
            strokeWidth: stop.congestion == 'alta' ? 5 : 3.5,
          ),
        );
        from = to;
        markers.add(
          Marker(
            point: to,
            width: 72,
            height: 56,
            child: GestureDetector(
              onTap: () => _showStopDetail(context, route, stop, base),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: base,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: stop.congestion == 'alta'
                            ? Colors.red
                            : Colors.white,
                        width: 2,
                      ),
                    ),
                    child: Text(
                      '#${stop.orden} ${stop.llegadaEstimada}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: base, width: 1),
                    ),
                    child: Text(
                      (stop.clienteId != null &&
                              stop.clienteId!.length > 14)
                          ? '${stop.clienteId!.substring(0, 14)}…'
                          : (stop.clienteId ?? ''),
                      style: const TextStyle(
                          fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Mapa de rutas · ${p.rutas.length} rutas · '
                  '${p.metricas.cumplimientoPct.toStringAsFixed(0)}% cumplimiento',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => context.go('/routes'),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Volver'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Wrap(
            spacing: 16,
            children: [
              _Legend(color: Colors.green, label: 'Congestión baja'),
              _Legend(color: Colors.orange, label: 'Congestión media'),
              _Legend(color: Colors.red, label: 'Congestión alta'),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text('Ver vehículos:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              for (var i = 0; i < p.rutas.length; i++)
                FilterChip(
                  label: Text(p.rutas[i].placa),
                  selected:
                      !_hiddenPlacas.contains(p.rutas[i].placa),
                  selectedColor: _routeColors[i % _routeColors.length]
                      .withValues(alpha: 0.3),
                  avatar: CircleAvatar(
                    backgroundColor:
                        _routeColors[i % _routeColors.length],
                    child: Text(
                      '${p.rutas[i].paradas.length}',
                      style: const TextStyle(
                          color: Colors.white, fontSize: 12),
                    ),
                  ),
                  onSelected: (visible) {
                    setState(() {
                      if (visible) {
                        _hiddenPlacas.remove(p.rutas[i].placa);
                      } else {
                        _hiddenPlacas.add(p.rutas[i].placa);
                      }
                    });
                  },
                ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 420,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: FlutterMap(
                options: MapOptions(initialCenter: depot, initialZoom: 14),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'pe.pathseek.app',
                  ),
                  PolylineLayer(polylines: polylines),
                  MarkerLayer(markers: markers),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Congestión MVP por hora de llegada (hora punta Huancayo 7–9, 12–14, 18–20). '
            'Tiempos por tramo de referencia a 40 km/h; el backend calculará con velocidad real.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < p.rutas.length; i++)
            _RouteSegments(
              route: p.rutas[i],
              color: _routeColors[i % _routeColors.length],
            ),
        ],
      ),
    );
  }

  void _showStopDetail(
    BuildContext context,
    VehicleRoute route,
    RouteStop stop,
    Color color,
  ) {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_pin, color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Parada ${stop.orden} · ${route.placa}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                _CongestionChip(nivel: stop.congestion),
              ],
            ),
            const SizedBox(height: 12),
            _row('Cliente', stop.clienteId ?? '—'),
            _row('Ventana', '${stop.ventanaInicio ?? '—'} – ${stop.ventanaFin ?? '—'}'),
            _row('Peso', '${stop.peso} kg'),
            _row('Llegada estimada', stop.llegadaEstimada),
            _row('Tramo', '${stop.distanciaTramoKm} km'),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 150,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 24, height: 6, color: color),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class _CongestionChip extends StatelessWidget {
  const _CongestionChip({required this.nivel});

  final String nivel;

  @override
  Widget build(BuildContext context) {
    final color = _RouteMapViewState.congestionColor(nivel);
    return Chip(
      label: Text('Congestión $nivel', style: const TextStyle(fontSize: 12)),
      backgroundColor: color.withValues(alpha: 0.2),
      side: BorderSide(color: color),
    );
  }
}

class _RouteSegments extends StatelessWidget {
  const _RouteSegments({required this.route, required this.color});

  final VehicleRoute route;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        leading: Icon(Icons.local_shipping, color: color),
        title: Text('${route.placa} · ${route.distanciaKm} km'),
        subtitle: Text('${route.paradas.length} entregas'),
        children: [
          for (final s in route.paradas)
            ListTile(
              dense: true,
              leading: CircleAvatar(
                backgroundColor: color,
                child: Text('${s.orden}',
                    style: const TextStyle(color: Colors.white)),
              ),
              title: Text(
                '${s.clienteId ?? s.pedidoId.substring(0, 8)} · llegada ${s.llegadaEstimada}',
              ),
              subtitle: Text(
                'Tramo ${s.distanciaTramoKm} km · ≈${(s.distanciaTramoKm / 40 * 60).round()} min (ref. 40 km/h)',
              ),
              trailing: _CongestionChip(nivel: s.congestion),
            ),
        ],
      ),
    );
  }
}
