import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pathseek/core/di/injection.dart';
import 'package:pathseek/core/utils/formatters.dart';
import 'package:pathseek/core/widgets/catalog_layout.dart';
import 'package:pathseek/features/carbon/domain/entities/carbon_plan.dart';
import 'package:pathseek/features/carbon/presentation/bloc/carbon_bloc.dart';

class CarbonPage extends StatelessWidget {
  const CarbonPage({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocProvider<CarbonBloc>(
        create: (_) => locator<CarbonBloc>()..add(const CarbonPlanRequested()),
        child: const CarbonView(),
      );
}

class CarbonView extends StatelessWidget {
  const CarbonView({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<CarbonBloc, CarbonState>(
    builder: (context, state) {
      final plan = state.plan;
      return CatalogLayout(
        title: 'Compensación de carbono',
        description:
            'Huella anual estimada de las rutas completadas y proyectos locales para compensarla.',
        icon: Icons.forest_outlined,
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed: () =>
                context.read<CarbonBloc>().add(const CarbonPlanRequested()),
            icon: const Icon(Icons.refresh),
          ),
        ],
        isLoading: state.isLoading,
        loadingMessage: 'Calculando huella de carbono…',
        emptyMessage: 'El plan de compensación no está disponible.',
        errorMessage: state.errorMessage,
        onRetry: () =>
            context.read<CarbonBloc>().add(const CarbonPlanRequested()),
        itemCount: plan == null ? 0 : plan.proyectos.length + 1,
        totalCount: plan == null ? 0 : plan.proyectos.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) return _SummaryCard(plan: plan!);
          return _ProjectCard(option: plan!.proyectos[index - 1]);
        },
      );
    },
  );
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.plan});
  final CarbonPlan plan;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    String formatDate(String iso) {
      final date = DateTime.tryParse(iso);
      return date == null ? iso : DateFormat.yMMMd('es').format(date);
    }

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Plan anual de compensación', style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              'Período: ${formatDate(plan.periodoDesde)} a ${formatDate(plan.periodoHasta)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 36,
              runSpacing: 20,
              children: [
                _SummaryMetric(
                  label: 'Emisiones anuales',
                  value: Formatters.co2(plan.emisionesAnualesKg),
                  icon: Icons.co2_outlined,
                ),
                _SummaryMetric(
                  label: 'Toneladas de CO₂',
                  value: '${plan.emisionesAnualesT} t',
                  icon: Icons.scale_outlined,
                ),
                _SummaryMetric(
                  label: 'Árboles equivalentes',
                  value: '${plan.arbolesEquivalentes}',
                  icon: Icons.forest_outlined,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Estimación con 1 árbol ≈ 0.02 t CO₂/año. Sin datos completados '
              'el plan muestra cero.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({
    required this.label,
    required this.value,
    required this.icon,
  });
  final String label;
  final String value;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, color: Theme.of(context).colorScheme.primary),
      const SizedBox(height: 8),
      Text(label, style: Theme.of(context).textTheme.bodyMedium),
      const SizedBox(height: 4),
      Text(
        value,
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
      ),
    ],
  );
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({required this.option});
  final CarbonProjectOption option;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.forest, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(option.nombre, style: theme.textTheme.titleMedium),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Tipo: ${option.tipo}'),
            if (option.descripcion != null) ...[
              const SizedBox(height: 8),
              Text(
                option.descripcion!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Wrap(
              spacing: 24,
              children: [
                Text(
                  'Costo por tonelada: S/ ${option.costoTonelada.toStringAsFixed(2)}',
                ),
                Text(
                  'Costo estimado del plan: S/ ${option.costeEstimado.toStringAsFixed(2)}',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
