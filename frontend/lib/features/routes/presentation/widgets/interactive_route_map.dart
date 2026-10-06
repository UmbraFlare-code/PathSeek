import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/delivery_route.dart';

class InteractiveRouteMap extends StatefulWidget {
  const InteractiveRouteMap({
    super.key,
    required this.route,
    this.height = 340,
    this.onStopSelected,
  });

  final DeliveryRoute route;
  final double height;
  final ValueChanged<RouteOrder>? onStopSelected;

  @override
  State<InteractiveRouteMap> createState() => _InteractiveRouteMapState();
}

class _InteractiveRouteMapState extends State<InteractiveRouteMap>
    with SingleTickerProviderStateMixin {
  int? _selectedStopIndex;
  bool _isSimulating = false;
  late AnimationController _simController;

  @override
  void initState() {
    super.initState();
    _simController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..addListener(() {
        if (mounted) setState(() {});
      });
  }

  @override
  void dispose() {
    _simController.dispose();
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

  @override
  Widget build(BuildContext context) {
    final pedidos = widget.route.pedidos;

    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B), // Dark slate map background
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // 1. Grid & Road Path Canvas
            Positioned.fill(
              child: CustomPaint(
                painter: _RouteMapCanvasPainter(
                  pedidos: pedidos,
                  selectedIndex: _selectedStopIndex,
                  simProgress: _isSimulating ? _simController.value : null,
                ),
              ),
            ),

            // 2. Interactive Touch Layer over Stops
            Positioned.fill(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: _buildStopPins(constraints, pedidos),
                  );
                },
              ),
            ),

            // 3. Top Map Controls (Leyenda, Simulación, Zoom)
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.map_outlined, color: AppTheme.accent, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'MAPA // UGEL HUANCAYO (${pedidos.length} PARADAS)',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isSimulating ? Colors.redAccent : AppTheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    onPressed: _toggleSimulation,
                    icon: Icon(_isSimulating ? Icons.stop : Icons.play_arrow, size: 16),
                    label: Text(_isSimulating ? 'Detener' : 'Simular GPS'),
                  ),
                ],
              ),
            ),

            // 4. Bottom Context Panel (Detalle de la parada seleccionada)
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: _buildBottomContextBanner(pedidos),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildStopPins(BoxConstraints constraints, List<RouteOrder> pedidos) {
    if (pedidos.isEmpty) return [];

    final width = constraints.maxWidth;
    final height = constraints.maxHeight;
    final padding = 40.0;

    // Calcular límites normalizados
    double minLat = -12.0683;
    double maxLat = -12.0683;
    double minLon = -75.2100;
    double maxLon = -75.2100;

    for (final p in pedidos) {
      if (p.gpsLat != null && p.gpsLon != null) {
        minLat = math.min(minLat, p.gpsLat!);
        maxLat = math.max(maxLat, p.gpsLat!);
        minLon = math.min(minLon, p.gpsLon!);
        maxLon = math.max(maxLon, p.gpsLon!);
      }
    }

    final latSpan = math.max(0.01, maxLat - minLat);
    final lonSpan = math.max(0.01, maxLon - minLon);

    final widgets = <Widget>[];

    // Almacén Central (Depósito)
    final depotX = padding + ((-75.2100 - minLon) / lonSpan) * (width - 2 * padding);
    final depotY = height - padding - ((-12.0683 - minLat) / latSpan) * (height - 2 * padding);

    widgets.add(
      Positioned(
        left: depotX - 14,
        top: depotY - 14,
        child: Tooltip(
          message: 'Depósito Central UGEL Huancayo (Atalaya 1280)',
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: Colors.amber,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 6)],
            ),
            child: const Icon(Icons.warehouse_rounded, size: 16, color: Colors.black87),
          ),
        ),
      ),
    );

    // Paradas de entrega
    for (int i = 0; i < pedidos.length; i++) {
      final p = pedidos[i];
      final lat = p.gpsLat ?? -12.0683;
      final lon = p.gpsLon ?? -75.2100;

      final x = padding + ((lon - minLon) / lonSpan) * (width - 2 * padding);
      final y = height - padding - ((lat - minLat) / latSpan) * (height - 2 * padding);
      final isSelected = _selectedStopIndex == i;

      widgets.add(
        Positioned(
          left: x - 15,
          top: y - 15,
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
              width: isSelected ? 34 : 26,
              height: isSelected ? 34 : 26,
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.accent : AppTheme.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? AppTheme.accent.withValues(alpha: 0.6)
                        : Colors.black45,
                    blurRadius: isSelected ? 10 : 4,
                    spreadRadius: isSelected ? 2 : 0,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '${p.orden}',
                  style: TextStyle(
                    color: isSelected ? Colors.black : Colors.white,
                    fontSize: isSelected ? 13 : 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return widgets;
  }

  Widget _buildBottomContextBanner(List<RouteOrder> pedidos) {
    if (pedidos.isEmpty) {
      return const SizedBox.shrink();
    }

    final p = _selectedStopIndex != null && _selectedStopIndex! < pedidos.length
        ? pedidos[_selectedStopIndex!]
        : null;

    final ctx = p?.contextoVial ?? const RoadContext();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        children: [
          Icon(
            p != null ? Icons.location_on : Icons.alt_route,
            color: p != null ? AppTheme.accent : Colors.white70,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  p != null
                      ? 'PARADA #${p.orden} · ${p.direccion ?? 'I.E. Destino'}'
                      : 'RUTA COMPLETA // Distancia: ${Formatters.km(widget.route.distanciaKm)} · CO₂: ${Formatters.co2(widget.route.co2Kg)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  p != null
                      ? 'Calzada: ${ctx.tipoSuperficie} · Altitud: ${ctx.elevacionMetros} m.s.n.m. · Pendiente: ${ctx.pendientePorcentaje}% · Estado: ${ctx.nivelCongestion}'
                      : 'Toca cualquier parada numerada en el mapa para ver el contexto vial y la altimetría.',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          if (p != null)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white54, size: 16),
              onPressed: () => setState(() => _selectedStopIndex = null),
            ),
        ],
      ),
    );
  }
}

class _RouteMapCanvasPainter extends CustomPainter {
  _RouteMapCanvasPainter({
    required this.pedidos,
    this.selectedIndex,
    this.simProgress,
  });

  final List<RouteOrder> pedidos;
  final int? selectedIndex;
  final double? simProgress;

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    final padding = 40.0;

    // 1. Dibujar rejilla de fondo estilo mapa topográfico
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 1.0;

    for (double x = 0; x < width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, height), gridPaint);
    }
    for (double y = 0; y < height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(width, y), gridPaint);
    }

    if (pedidos.isEmpty) return;

    // 2. Calcular límites
    double minLat = -12.0683;
    double maxLat = -12.0683;
    double minLon = -75.2100;
    double maxLon = -75.2100;

    for (final p in pedidos) {
      if (p.gpsLat != null && p.gpsLon != null) {
        minLat = math.min(minLat, p.gpsLat!);
        maxLat = math.max(maxLat, p.gpsLat!);
        minLon = math.min(minLon, p.gpsLon!);
        maxLon = math.max(maxLon, p.gpsLon!);
      }
    }

    final latSpan = math.max(0.01, maxLat - minLat);
    final lonSpan = math.max(0.01, maxLon - minLon);

    Offset toScreen(double lat, double lon) {
      final x = padding + ((lon - minLon) / lonSpan) * (width - 2 * padding);
      final y = height - padding - ((lat - minLat) / latSpan) * (height - 2 * padding);
      return Offset(x, y);
    }

    final depot = toScreen(-12.0683, -75.2100);
    final points = <Offset>[depot];

    for (final p in pedidos) {
      final lat = p.gpsLat ?? -12.0683;
      final lon = p.gpsLon ?? -75.2100;
      points.add(toScreen(lat, lon));
    }
    points.add(depot); // Regreso al almacén

    // 3. Trazar líneas de ruta
    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    // Glow de la ruta
    final glowPaint = Paint()
      ..color = AppTheme.primary.withValues(alpha: 0.3)
      ..strokeWidth = 8.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, glowPaint);

    // Trazo principal de la ruta
    final linePaint = Paint()
      ..color = AppTheme.primary
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, linePaint);

    // 4. Animación del vehículo en simulación
    if (simProgress != null && points.length > 1) {
      final metrics = path.computeMetrics().toList();
      if (metrics.isNotEmpty) {
        final metric = metrics.first;
        final totalLength = metric.length;
        final currentDistance = totalLength * simProgress!;
        final tangent = metric.getTangentForOffset(currentDistance);

        if (tangent != null) {
          final pos = tangent.position;
          final angle = -tangent.angle;

          final vehiclePaint = Paint()
            ..color = Colors.yellowAccent
            ..style = PaintingStyle.fill;

          final vehicleGlow = Paint()
            ..color = Colors.yellowAccent.withValues(alpha: 0.5)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

          canvas.drawCircle(pos, 9, vehicleGlow);
          canvas.drawCircle(pos, 6, vehiclePaint);

          // Flecha de orientación
          canvas.save();
          canvas.translate(pos.dx, pos.dy);
          canvas.rotate(angle);
          final arrowPath = Path()
            ..moveTo(0, -7)
            ..lineTo(5, 5)
            ..lineTo(0, 3)
            ..lineTo(-5, 5)
            ..close();
          canvas.drawPath(arrowPath, Paint()..color = Colors.black);
          canvas.restore();
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _RouteMapCanvasPainter oldDelegate) {
    return oldDelegate.pedidos != pedidos ||
        oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.simProgress != simProgress;
  }
}
