import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pathseek/core/di/injection.dart';
import 'package:pathseek/core/widgets/app_snack_bar.dart';
import 'package:pathseek/features/routes/domain/entities/route_plan.dart';
import 'package:pathseek/features/routes/presentation/bloc/route_bloc.dart';

/// Referencia secuencial ingenua para el KPI de la demo: ir y volver al
/// depósito por cada pedido (sin encadenar). Se etiqueta como estimada.
double _baselineKm(RoutePlan plan) {
  var total = 0.0;
  for (final r in plan.rutas) {
    for (final s in r.paradas) {
      total += 2 *
          _haversineKm(plan.depositoLat, plan.depositoLon, s.gpsLat, s.gpsLon);
    }
  }
  return total;
}

double _haversineKm(double lat1, double lon1, double lat2, double lon2) {
  const r = 6371.0;
  const toRad = math.pi / 180;
  final dLat = (lat2 - lat1) * toRad;
  final dLon = (lon2 - lon1) * toRad;
  final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(lat1 * toRad) *
          math.cos(lat2 * toRad) *
          math.sin(dLon / 2) *
          math.sin(dLon / 2);
  return r * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
}

class RouteGeneratePage extends StatefulWidget {
  const RouteGeneratePage({super.key});

  @override
  State<RouteGeneratePage> createState() => _RouteGeneratePageState();
}

class _RouteGeneratePageState extends State<RouteGeneratePage> {
  final _formKey = GlobalKey<FormState>();
  final _fechaController = TextEditingController(
    text: DateTime.now().toIso8601String().substring(0, 10),
  );
  // Depósito UGEL Huancayo (zona Atalaya — coincide con datos semilla
  // database/04_seed_data.sql para que las ventanas sean alcanzables).
  final _latController = TextEditingController(text: '-12.0654');
  final _lonController = TextEditingController(text: '-75.2048');
  final _velocidadController = TextEditingController(text: '40');
  String? _lastAnnouncedRutaId;
  String? _announcedNotice;

  @override
  void dispose() {
    _fechaController.dispose();
    _latController.dispose();
    _lonController.dispose();
    _velocidadController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RouteBloc>(
      create: (_) =>
          locator<RouteBloc>()..add(const RoutesPerformanceRequested()),      child: BlocConsumer<RouteBloc, RouteState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            showAppSnackBar(context, state.errorMessage!, isError: true);
          } else if (state.lastNotice != null &&
              state.lastNotice != _announcedNotice) {
            _announcedNotice = state.lastNotice;
            showAppSnackBar(context, state.lastNotice!);
          } else if (state.plan != null &&
              !state.isGenerating &&
              state.plan!.rutaId != _lastAnnouncedRutaId) {
            _lastAnnouncedRutaId = state.plan!.rutaId;
            final m = state.plan!.metricas;
            showAppSnackBar(
              context,
              '${state.plan!.rutas.length} rutas generadas. '
              '${m.totalNoAsignados} pedidos quedaron sin asignar',
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Generación de rutas',
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                const Text(
                  'Historia 1: asigna pedidos PENDIENTE respetando capacidad, '
                  'ventanas y restricción de placa. Historia 2: mide P95 < 45 s.',
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 18),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Depósito sugerido: UGEL Huancayo, Atalaya 1280 '
                        '(zona de los datos semilla de ciudad). '
                        'Si escribes otro depósito lejano, algunos pedidos '
                        'pueden salir como “ventana inalcanzable”.',
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        _latController.text = '-12.0654';
                        _lonController.text = '-75.2048';
                      },
                      child: const Text('Usar UGEL'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Form(
                  key: _formKey,
                  child: Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      SizedBox(
                        width: 200,
                        child: TextFormField(
                          controller: _fechaController,
                          decoration: const InputDecoration(
                            labelText: 'Fecha operación (YYYY-MM-DD)',
                          ),
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Requerido' : null,
                        ),
                      ),
                      SizedBox(
                        width: 160,
                        child: TextFormField(
                          controller: _latController,
                          decoration: const InputDecoration(
                            labelText: 'Depósito latitud',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      SizedBox(
                        width: 160,
                        child: TextFormField(
                          controller: _lonController,
                          decoration: const InputDecoration(
                            labelText: 'Depósito longitud',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      SizedBox(
                        width: 160,
                        child: TextFormField(
                          controller: _velocidadController,
                          decoration: const InputDecoration(
                            labelText: 'Velocidad km/h',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: state.isGenerating
                            ? null
                            : () => _generate(context),
                        icon: state.isGenerating
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.route),
                        label: const Text('Generar rutas'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _PerformanceCard(state: state),
                const SizedBox(height: 16),
                if (state.isGenerating) const _OptimizingBanner(),
                if (state.plan != null) _PlanView(state: state),
              ],
            ),
          );
        },
      ),
    );
  }

  void _generate(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    context.read<RouteBloc>().add(RoutesGenerateRequested(
          fechaOperacion: _fechaController.text.trim(),
          depositoLat: double.tryParse(_latController.text) ?? -12.0654,
          depositoLon: double.tryParse(_lonController.text) ?? -75.2048,
          velocidadKmh: double.tryParse(_velocidadController.text) ?? 40,
        ));
  }
}

class _PerformanceCard extends StatelessWidget {
  const _PerformanceCard({required this.state});

  final RouteState state;

  @override
  Widget build(BuildContext context) {
    final p = state.performance;
    if (p == null) return const SizedBox.shrink();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 24,
          children: [
            _metric('Solicitudes', '${p.totalSolicitudes}'),
            _metric('P50', '${p.p50Ms} ms'),
            _metric('P95', '${p.p95Ms} ms'),
            _metric('Media', '${p.mediaMs.toStringAsFixed(1)} ms'),
            _metric('Última', '${p.ultimaMs} ms'),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  p.slaCumplido ? Icons.check_circle : Icons.warning,
                  color: p.slaCumplido ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 8),
                Text(p.slaCumplido ? 'SLA 45 s OK' : 'SLA 45 s en riesgo'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _metric(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(value),
      ],
    );
  }
}

/// Banner de la demo: visible durante la generación, mide el tiempo real
/// contra el SLA RNF-001 (≤ 45 s).
class _OptimizingBanner extends StatefulWidget {
  const _OptimizingBanner();

  @override
  State<_OptimizingBanner> createState() => _OptimizingBannerState();
}

class _OptimizingBannerState extends State<_OptimizingBanner> {
  late final Stopwatch _stopwatch;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch()..start();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _stopwatch.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final seconds = _stopwatch.elapsed.inSeconds;
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Optimizando rutas… ${seconds}s (límite 45s · SLA RNF-001)',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const LinearProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

class _PlanView extends StatelessWidget {
  const _PlanView({required this.state});

  final RouteState state;

  @override
  Widget build(BuildContext context) {
    final plan = state.plan!;
    final baseline = _baselineKm(plan);
    final ahorro = baseline > 0
        ? (1 - plan.metricas.distanciaKm / baseline) * 100
        : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Plan ${plan.rutaId.substring(0, 8)}… · ${plan.duracionMs} ms · '
                'cumplimiento ${plan.metricas.cumplimientoPct.toStringAsFixed(1)}% · '
                '${plan.metricas.distanciaKm} km · ${plan.metricas.combustibleL} L · '
                '${plan.metricas.co2Kg} kg CO₂',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(width: 12),
            FilledButton.icon(
              onPressed: state.isGenerating
                  ? null
                  : () => context
                      .read<RouteBloc>()
                      .add(const RoutesConfirmRequested()),
              icon: const Icon(Icons.check_circle_outline),
              label: Text(
                  'Confirmar (${plan.metricas.totalAsignados} → EN_RUTA)'),
            ),
            const SizedBox(width: 12),
            FilledButton.icon(
              onPressed: () => context.go('/map', extra: plan),
              icon: const Icon(Icons.map),
              label: const Text('Ver en mapa'),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Ahorro estimado −${ahorro.toStringAsFixed(1)}% vs referencia '
          'secuencial ingenua (${baseline.toStringAsFixed(1)} km ida-vuelta '
          'por pedido) · KPI objetivo ≥15% · cálculo estimado',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        for (final r in plan.rutas)
          Card(
            child: ExpansionTile(
              leading: const Icon(Icons.local_shipping),
              title: Text('${r.placa} · ${plan.fechaOperacion}'),
              subtitle: Text(
                '${r.distanciaKm} km · ${r.co2Kg} kg CO₂ · '
                '${r.combustibleL} L · Estado: Planificada',
              ),
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Icon(Icons.person_outline, size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Conductor: por asignar (asignación de conductores: Sprint 3+)',
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ),
                    ],
                  ),
                ),
                for (final s in r.paradas)
                  ListTile(
                    dense: true,
                    leading: CircleAvatar(child: Text('${s.orden}')),
                    title: Text(s.direccion ?? s.clienteId ?? s.pedidoId),
                    subtitle: Text(
                      'Llega ${s.llegadaEstimada} · ventana '
                      '${s.ventanaInicio ?? '—'}–${s.ventanaFin ?? '—'} · '
                      '${s.peso} kg · tramo ${s.distanciaTramoKm} km',
                    ),
                    trailing: s.prioridad.isNotEmpty
                        ? Chip(
                            label: Text(
                              s.prioridad,
                              style: const TextStyle(fontSize: 11),
                            ),
                            backgroundColor: s.prioridad == 'EXPRESS'
                                ? Colors.red.withValues(alpha: 0.15)
                                : null,
                          )
                        : null,
                  ),
              ],
            ),
          ),
        if (plan.noAsignados.isNotEmpty)
          Card(
            color: Theme.of(context).colorScheme.errorContainer,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'No asignados (${plan.noAsignados.length}): pendientes de reprogramación',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  for (final e in plan.noAsignados)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        '• ${e.direccion ?? e.pedidoId.substring(0, 8)}'
                        '${e.clienteId != null ? ' (${e.clienteId})' : ''}'
                        '${e.ventanaInicio != null ? ' · ventana ${e.ventanaInicio}–${e.ventanaFin}' : ''}\n'
                        '  Motivo: ${e.motivoLegible}'
                        '${e.sugerencia != null ? '\n  Sugerencia: ${e.sugerencia}' : ''}',
                      ),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
