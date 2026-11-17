import 'package:flutter_test/flutter_test.dart';
import 'package:pathseek/features/dashboard/data/models/dashboard_summary_model.dart';
import 'package:pathseek/features/dashboard/domain/entities/dashboard_summary.dart';

void main() {
  group('DashboardSummaryModel', () {
    const json = {
      'total_vehiculos': 15,
      'conductores_disponibles': 8,
      'pedidos_pendientes': 22,
      'pedidos_en_ruta': 5,
      'pedidos_entregados': 40,
      'pedidos_cancelados': 2,
      'rutas_planificadas': 6,
      'co2_total_kg': 125.5,
      'combustible_total_l': 300.25,
    };

    test('fromJson parses all fields', () {
      final model = DashboardSummaryModel.fromJson(json);

      expect(model.totalVehiculos, 15);
      expect(model.conductoresDisponibles, 8);
      expect(model.pedidosPendientes, 22);
      expect(model.pedidosEnRuta, 5);
      expect(model.pedidosEntregados, 40);
      expect(model.pedidosCancelados, 2);
      expect(model.rutasPlanificadas, 6);
      expect(model.co2TotalKg, 125.5);
      expect(model.combustibleTotalL, 300.25);
    });

    test('fromJson tolerates missing/null fields', () {
      final model = DashboardSummaryModel.fromJson({});
      expect(model.totalVehiculos, 0);
      expect(model.co2TotalKg, 0);
    });

    test('fromJson parses numeric strings', () {
      final model = DashboardSummaryModel.fromJson({
        ...json,
        'co2_total_kg': '125.5',
        'pedidos_pendientes': '22',
      });
      expect(model.co2TotalKg, 125.5);
      expect(model.pedidosPendientes, 22);
    });

    test('toEntity maps correctly', () {
      final entity = DashboardSummaryModel.fromJson(json).toEntity();
      expect(entity, isA<DashboardSummary>());
      expect(entity.hasData, isTrue);
      expect(entity.pedidosTotales, 69);
    });

    test('parses executed routes with a measured zero percent and unpriced savings', () {
      final response = {
        ...json,
        'rutas_ejecutadas': {
          'rutas_completadas': 2,
          'distancia_km': '14.75',
          'co2_kg': 2,
          'combustible_l': 3,
          'cumplimiento_ventanas_pct': 0,
          'comparacion_hoy': {
            'combustible_secuencial_l': 4,
            'ahorro_l': 1,
            'ahorro_pct': '25.0',
            'ahorro_pen': null,
          },
        },
      };
      final model = DashboardSummaryModel.fromJson(response);
      expect(model, DashboardSummaryModel.fromJson(response));
      expect(
        model.toEntity().executedRoutes,
        const ExecutedRoutesMetrics(
          completedRoutes: 2,
          distanceKm: 14.75,
          co2Kg: 2,
          fuelLiters: 3,
          onTimePercent: 0,
          dailyComparison: DailyFuelComparison(sequentialLiters: 4, savedLiters: 1, savedPercent: 25),
        ),
      );
      expect(DashboardSummaryModel.fromJson(json).toEntity().executedRoutes, isNull);
    });

    test('empty summary hasData is false', () {
      const entity = DashboardSummary();
      expect(entity.hasData, isFalse);
      expect(entity.pedidosTotales, 0);
    });
  });
}
