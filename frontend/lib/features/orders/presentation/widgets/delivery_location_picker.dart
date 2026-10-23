import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/responsive_field_row.dart';

/// Select a delivery destination; the logistics depot remains unchanged.
class DeliveryLocationPicker extends StatefulWidget {
  const DeliveryLocationPicker({
    super.key,
    this.initial,
    this.showBaseMap = true,
  });
  final LatLng? initial;
  final bool showBaseMap;
  @override
  State<DeliveryLocationPicker> createState() => _DeliveryLocationPickerState();
}

class _DeliveryLocationPickerState extends State<DeliveryLocationPicker> {
  static const depot = LatLng(-12.0683, -75.21);
  final _map = MapController();
  final _coordinates = GlobalKey<FormState>();
  late final TextEditingController _latitude, _longitude;
  LatLng? selected;
  bool tileError = false;
  int tileAttempt = 0;
  @override
  void initState() {
    super.initState();
    selected = widget.initial;
    _latitude = TextEditingController(
      text: selected?.latitude.toStringAsFixed(6) ?? '',
    );
    _longitude = TextEditingController(
      text: selected?.longitude.toStringAsFixed(6) ?? '',
    );
  }

  @override
  void dispose() {
    _map.dispose();
    _latitude.dispose();
    _longitude.dispose();
    super.dispose();
  }

  void select(LatLng point) {
    _coordinates.currentState?.reset();
    setState(() {
      selected = point;
      _latitude.text = point.latitude.toStringAsFixed(6);
      _longitude.text = point.longitude.toStringAsFixed(6);
    });
  }

  void applyCoordinates() {
    if (!_coordinates.currentState!.validate()) return;
    final point = LatLng(
      double.parse(_latitude.text.trim()),
      double.parse(_longitude.text.trim()),
    );
    select(point);
    _map.move(point, 15);
    FocusScope.of(context).unfocus();
  }

  String? validateCoordinate(
    String? value,
    double min,
    double max,
    String label,
  ) {
    final parsed = double.tryParse(value?.trim() ?? '');
    if (parsed != null && !parsed.isFinite) {
      return '$label debe ser un número finito';
    }
    return Validators.range(value, min, max, label);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final colors = Theme.of(context).colorScheme;
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 840,
          maxHeight:
              (size.height - MediaQuery.viewInsetsOf(context).bottom - 48)
                  .clamp(200, 900),
        ),
        child: SizedBox(
          width: 840,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Semantics(
                        header: true,
                        child: Text(
                          'Selecciona el destino de entrega',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'El origen es el depósito UGEL, Atalaya 1280. Selecciona el destino en el mapa o utiliza sus coordenadas.',
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () => _map.move(depot, 13),
                            icon: const Icon(Icons.warehouse_outlined),
                            label: const Text('Ver depósito'),
                          ),
                          IconButton.outlined(
                            tooltip: 'Acercar',
                            onPressed: () => _map.move(
                              _map.camera.center,
                              (_map.camera.zoom + 1).clamp(3, 19).toDouble(),
                            ),
                            icon: const Icon(Icons.add),
                          ),
                          IconButton.outlined(
                            tooltip: 'Alejar',
                            onPressed: () => _map.move(
                              _map.camera.center,
                              (_map.camera.zoom - 1).clamp(3, 19).toDouble(),
                            ),
                            icon: const Icon(Icons.remove),
                          ),
                        ],
                      ),
                      if (tileError)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Semantics(
                            liveRegion: true,
                            child: Text(
                              'No se pudo cargar el mapa base. Puedes introducir las coordenadas del destino.',
                              style: TextStyle(color: colors.error),
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: size.height < 500 ? 200 : 300,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: FlutterMap(
                            mapController: _map,
                            options: MapOptions(
                              initialCenter: selected ?? depot,
                              initialZoom: 13,
                              onTap: (_, point) => select(point),
                            ),
                            children: [
                              if (widget.showBaseMap)
                                TileLayer(
                                  key: ValueKey(tileAttempt),
                                  urlTemplate:
                                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  userAgentPackageName:
                                      'pe.edu.ugelhuancayo.pathseek',
                                  errorTileCallback: (_, error, stack) {
                                    if (!tileError) {
                                      WidgetsBinding.instance
                                          .addPostFrameCallback((_) {
                                            if (mounted && !tileError) {
                                              setState(() => tileError = true);
                                            }
                                          });
                                    }
                                  },
                                ),
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    point: depot,
                                    width: 48,
                                    height: 48,
                                    child: Tooltip(
                                      message: 'Origen: depósito UGEL',
                                      child: Material(
                                        color: colors.surface,
                                        shape: CircleBorder(
                                          side: BorderSide(
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
                                  if (selected case final point?)
                                    Marker(
                                      point: point,
                                      width: 48,
                                      height: 48,
                                      child: Semantics(
                                        label:
                                            'Destino de entrega seleccionado',
                                        child: Icon(
                                          Icons.location_on,
                                          color: colors.primary,
                                          size: 48,
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
                                    child: const Text(
                                      '© OpenStreetMap contributors',
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Semantics(
                        liveRegion: true,
                        child: Text(
                          selected == null
                              ? 'Selecciona un destino antes de confirmar.'
                              : 'Destino seleccionado. Puedes confirmarlo o ajustar sus coordenadas.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppTheme.mutedText),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Form(
                        key: _coordinates,
                        child: ResponsiveFieldRow(
                          children: [
                            TextFormField(
                              controller: _latitude,
                              decoration: const InputDecoration(
                                labelText: 'Latitud del destino',
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                    signed: true,
                                  ),
                              onChanged: (_) => setState(() => selected = null),
                              validator: (value) => validateCoordinate(
                                value,
                                -90,
                                90,
                                'La latitud',
                              ),
                            ),
                            TextFormField(
                              controller: _longitude,
                              decoration: const InputDecoration(
                                labelText: 'Longitud del destino',
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                    signed: true,
                                  ),
                              onChanged: (_) => setState(() => selected = null),
                              validator: (value) => validateCoordinate(
                                value,
                                -180,
                                180,
                                'La longitud',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: OutlinedButton.icon(
                          onPressed: applyCoordinates,
                          icon: const Icon(Icons.my_location_outlined),
                          label: const Text('Ubicar coordenadas'),
                        ),
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
                    ],
                  ),
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancelar'),
                      ),
                      FilledButton(
                        onPressed: selected == null
                            ? null
                            : () => Navigator.pop(context, selected),
                        child: const Text('Usar destino'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
