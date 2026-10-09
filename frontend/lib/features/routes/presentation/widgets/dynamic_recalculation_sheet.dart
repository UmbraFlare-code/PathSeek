import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/delivery_route.dart';
import '../bloc/route_bloc.dart';

/// Modal bottom sheet para configurar incidentes viales en Huancayo y re-optimizar la ruta dinámicamente.
class DynamicRecalculationSheet extends StatefulWidget {
  const DynamicRecalculationSheet({
    super.key,
    required this.route,
    this.initialLat,
    this.initialLon,
  });

  final DeliveryRoute route;
  final double? initialLat;
  final double? initialLon;

  static Future<void> show(
    BuildContext context, {
    required DeliveryRoute route,
    double? initialLat,
    double? initialLon,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BlocProvider.value(
        value: context.read<RouteBloc>(),
        child: DynamicRecalculationSheet(
          route: route,
          initialLat: initialLat,
          initialLon: initialLon,
        ),
      ),
    );
  }

  @override
  State<DynamicRecalculationSheet> createState() => _DynamicRecalculationSheetState();
}

class _DynamicRecalculationSheetState extends State<DynamicRecalculationSheet> {
  late final TextEditingController _motivoCtrl;
  late double _lat;
  late double _lon;
  int _radioMetros = 250;
  final Set<String> _cancelados = {};

  static const List<Map<String, dynamic>> _incidentPresets = [
    {
      'nombre': 'Congestión Severa Jr. Real (Centro)',
      'lat': -12.0680,
      'lon': -75.2100,
      'radio': 300,
    },
    {
      'nombre': 'Obras Viales Av. Mariscal Castilla (El Tambo)',
      'lat': -12.0520,
      'lon': -75.2180,
      'radio': 250,
    },
    {
      'nombre': 'Bloqueo Puente Comuneros (Chilca)',
      'lat': -12.0950,
      'lon': -75.2150,
      'radio': 400,
    },
    {
      'nombre': 'Manifestación Plaza Huamanmarca',
      'lat': -12.0715,
      'lon': -75.2070,
      'radio': 200,
    },
    {
      'nombre': 'Lluvia Intensa / Trocha Resbaladiza (Pilcomayo)',
      'lat': -12.0620,
      'lon': -75.2340,
      'radio': 500,
    },
  ];

  @override
  void initState() {
    super.initState();
    _lat = widget.initialLat ?? -12.0680;
    _lon = widget.initialLon ?? -75.2100;
    _motivoCtrl = TextEditingController(text: 'Congestión / Incidente vial en ruta');
  }

  @override
  void dispose() {
    _motivoCtrl.dispose();
    super.dispose();
  }

  void _applyPreset(Map<String, dynamic> preset) {
    setState(() {
      _motivoCtrl.text = preset['nombre'] as String;
      _lat = preset['lat'] as double;
      _lon = preset['lon'] as double;
      _radioMetros = preset['radio'] as int;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pedidos = widget.route.pedidos;

    return BlocConsumer<RouteBloc, RouteState>(
      listener: (context, state) {
        if (state.reoptimizeSuccess) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(
                content: Text(
                  '¡Ruta re-optimizada con éxito! Se ajustó la secuencia para esquivar el incidente.',
                ),
                backgroundColor: Color(0xFF15803D),
              ),
            );
        } else if (state.hasReoptimizeError) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.reoptimizeErrorMessage!),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
        }
      },
      builder: (context, state) {
        return Container(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.88,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFBEB),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFFDE68A)),
                          ),
                          child: const Icon(
                            Icons.alt_route_rounded,
                            color: Color(0xFFB45309),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Recálculo Dinámico de Ruta',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textHighContrast,
                              ),
                            ),
                            Text(
                              'Evasión de incidentes y contexto vial de Huancayo',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const Divider(height: 24),

                // Presets rápidos
                const Text(
                  'ESCENARIOS VIALES FRECUENTES EN HUANCAYO',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textMuted,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _incidentPresets.map((p) {
                    final isSelected = _motivoCtrl.text == p['nombre'];
                    return ChoiceChip(
                      label: Text(
                        p['nombre'] as String,
                        style: TextStyle(
                          fontSize: 11,
                          color: isSelected ? Colors.white : AppTheme.textHighContrast,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: AppTheme.primary,
                      backgroundColor: AppTheme.surface,
                      onSelected: (_) => _applyPreset(p),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Motivo del incidente
                TextField(
                  controller: _motivoCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Motivo del incidente / Cierre vial',
                    hintText: 'Ej. Cierre por desfile escolar en Calle Real',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 12),

                // Coordenadas y Radio de afectación
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Punto de Incidente (GPS)',
                              style: TextStyle(fontSize: 10, color: AppTheme.textMuted),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Lat: ${_lat.toStringAsFixed(4)}, Lon: ${_lon.toStringAsFixed(4)}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textHighContrast,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Radio de bloqueo',
                              style: TextStyle(fontSize: 10, color: AppTheme.textMuted),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '$_radioMetros metros',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textHighContrast,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Selector de Radio
                Slider(
                  value: _radioMetros.toDouble(),
                  min: 100,
                  max: 1000,
                  divisions: 9,
                  label: '$_radioMetros m',
                  onChanged: (val) => setState(() => _radioMetros = val.toInt()),
                ),

                // Paradas canceladas opcionalmente
                if (pedidos.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Text(
                    'PARADAS A EXCLUIR / CANCELAR (OPCIONAL)',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textMuted,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 130),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: pedidos.length,
                      itemBuilder: (context, i) {
                        final p = pedidos[i];
                        final isCancelled = _cancelados.contains(p.pedidoId);
                        return CheckboxListTile(
                          dense: true,
                          visualDensity: VisualDensity.compact,
                          title: Text(
                            '#${p.orden} - ${p.direccion ?? "I.E. Destino"}',
                            style: TextStyle(
                              fontSize: 11.5,
                              decoration: isCancelled ? TextDecoration.lineThrough : null,
                            ),
                          ),
                          subtitle: Text(
                            '${p.contextoVial.tipoSuperficie} · ${p.contextoVial.elevacionMetros} msnm',
                            style: const TextStyle(fontSize: 9.5),
                          ),
                          value: isCancelled,
                          onChanged: (checked) {
                            setState(() {
                              if (checked == true) {
                                _cancelados.add(p.pedidoId);
                              } else {
                                _cancelados.remove(p.pedidoId);
                              }
                            });
                          },
                        );
                      },
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                // Botón de Ejecución de Recálculo
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: FilledButton.icon(
                    onPressed: state.isReoptimizing
                        ? null
                        : () {
                            if (_motivoCtrl.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Por favor indique el motivo del incidente')),
                              );
                              return;
                            }
                            context.read<RouteBloc>().add(
                                  RouteReoptimized(
                                    id: widget.route.id,
                                    motivo: _motivoCtrl.text.trim(),
                                    latitudIncidente: _lat,
                                    longitudIncidente: _lon,
                                    radioBloqueoMetros: _radioMetros,
                                    pedidosCancelados: _cancelados.toList(),
                                  ),
                                );
                          },
                    icon: state.isReoptimizing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.flash_on_rounded, size: 18),
                    label: Text(
                      state.isReoptimizing
                          ? 'Recalculando ruta en tiempo real...'
                          : 'Re-optimizar Ruta Dinámicamente',
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
