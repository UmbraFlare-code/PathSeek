import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pathseek/core/di/injection.dart';
import 'package:pathseek/core/errors/failures.dart';
import 'package:pathseek/core/widgets/empty_view.dart';
import 'package:pathseek/core/widgets/page_header.dart';
import 'package:pathseek/features/reports/domain/repositories/reports_repository.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  DateTime? _desde;
  DateTime? _hasta;
  bool _downloading = false;
  String? _message;
  bool _isError = false;

  Future<void> _pickDate({required bool desde}) async {
    final now = DateTime.now();
    final initial = desde ? (_desde ?? now.subtract(const Duration(days: 30))) : (_hasta ?? now);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2024),
      lastDate: now,
    );
    if (picked == null) return;
    setState(() {
      if (desde) {
        _desde = picked;
        if (_hasta != null && _hasta!.isBefore(picked)) _hasta = picked;
      } else {
        _hasta = picked;
        if (_desde != null && _desde!.isAfter(picked)) _desde = picked;
      }
      _message = null;
    });
  }

  Future<void> _download() async {
    setState(() {
      _downloading = true;
      _message = null;
      _isError = false;
    });
    try {
      final saved = await locator<ReportsRepository>()
          .downloadSustainabilityReport(
            desde: _desde != null ? DateFormat('yyyy-MM-dd').format(_desde!) : null,
            hasta: _hasta != null ? DateFormat('yyyy-MM-dd').format(_hasta!) : null,
          );
      setState(() {
        _downloading = false;
        _message = kIsWeb
            ? 'PDF descargado: ${saved.fileName}'
            : 'PDF guardado en ${saved.location}';
      });
    } on Failure catch (failure) {
      setState(() {
        _downloading = false;
        _message = failure.message;
        _isError = true;
      });
    } catch (error) {
      setState(() {
        _downloading = false;
        _message = 'No se pudo generar el reporte: $error';
        _isError = true;
      });
    }
  }

  String get _rangeLabel {
    final formatter = DateFormat.yMMMd('es');
    final desde = _desde != null ? formatter.format(_desde!) : '—';
    final hasta = _hasta != null ? formatter.format(_hasta!) : '—';
    return '$desde a $hasta';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeader(
            title: 'Reportes de sostenibilidad',
            description:
                'Genera un PDF con emisiones, distancia, combustible y cumplimiento de ventanas por ruta.',
            icon: Icons.picture_as_pdf_outlined,
            actions: [
              FilledButton.icon(
                onPressed: _downloading ? null : _download,
                icon: _downloading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.download),
                label: Text(_downloading ? 'Generando…' : 'Descargar PDF'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Rango de fechas', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    'Opcional: sin rango se incluyen todos los datos registrados.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => _pickDate(desde: true),
                        icon: const Icon(Icons.event_outlined),
                        label: Text(
                          _desde != null
                              ? 'Desde: ${DateFormat.yMMMd('es').format(_desde!)}'
                              : 'Fecha desde',
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _pickDate(desde: false),
                        icon: const Icon(Icons.event_outlined),
                        label: Text(
                          _hasta != null
                              ? 'Hasta: ${DateFormat.yMMMd('es').format(_hasta!)}'
                              : 'Fecha hasta',
                        ),
                      ),
                      TextButton(
                        onPressed: (_desde == null && _hasta == null)
                            ? null
                            : () => setState(() {
                                _desde = null;
                                _hasta = null;
                                _message = null;
                              }),
                        child: const Text('Limpiar fechas'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Período seleccionado: $_rangeLabel',
                    style: theme.textTheme.labelLarge,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Contenido del reporte', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 12),
                  const _ReportItem('Resumen del período: rutas, distancia, CO₂ y combustible'),
                  const _ReportItem('Cumplimiento de ventanas de entrega'),
                  const _ReportItem('Detalle por ruta con vehículo y conductor'),
                  const _ReportItem('Nota de valores estimados (sin red vial ni tráfico real)'),
                ],
              ),
            ),
          ),
          if (_message != null) ...[
            const SizedBox(height: 16),
            Card(
              margin: EdgeInsets.zero,
              color: _isError
                  ? theme.colorScheme.errorContainer
                  : theme.colorScheme.secondaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  _message!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: _isError
                        ? theme.colorScheme.onErrorContainer
                        : theme.colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          const EmptyView(
            message:
                'El reporte se genera con los datos de rutas registradas en la base de datos.',
            icon: Icons.insights_outlined,
          ),
        ],
      ),
    );
  }
}

class _ReportItem extends StatelessWidget {
  const _ReportItem(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.check_circle_outline, size: 20),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
    ),
  );
}
