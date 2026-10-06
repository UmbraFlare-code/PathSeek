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

    test('empty summary hasData is false', () {
      const entity = DashboardSummary();
      expect(entity.hasData, isFalse);
      expect(entity.pedidosTotales, 0);
    });
  });
}
