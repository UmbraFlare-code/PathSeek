import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/delivery_route.dart';

class ElevationProfileWidget extends StatelessWidget {
  const ElevationProfileWidget({super.key, required this.route});

  final DeliveryRoute route;

  @override
  Widget build(BuildContext context) {
    final pedidos = route.pedidos;
    if (pedidos.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.terrain_rounded, color: AppTheme.primary, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'PERFIL ALTIMÉTRICO Y CALZADA // VALLE DEL MANTARO',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 90,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: pedidos.length,
                separatorBuilder: (_, __) => const VerticalDivider(width: 16),
                itemBuilder: (context, index) {
                  final p = pedidos[index];
                  final ctx = p.contextoVial;
                  final isTrocha = ctx.tipoSuperficie == 'TROCHA' || ctx.tipoSuperficie == 'AFIRMADO';

                  return Container(
                    width: 140,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isTrocha
                          ? Colors.orange.withValues(alpha: 0.08)
                          : AppTheme.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isTrocha ? Colors.orange.shade300 : AppTheme.border,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Parada #${p.orden}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: AppTheme.primaryDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.height, size: 14, color: Colors.blueGrey),
                            const SizedBox(width: 4),
                            Text(
                              '${ctx.elevacionMetros} m',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              isTrocha ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                              size: 14,
                              color: isTrocha ? Colors.orange : Colors.green,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              ctx.tipoSuperficie,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: isTrocha ? Colors.orange.shade900 : Colors.green.shade800,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
