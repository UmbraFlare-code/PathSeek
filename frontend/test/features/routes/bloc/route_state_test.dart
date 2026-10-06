import 'package:flutter_test/flutter_test.dart';
import 'package:pathseek/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:pathseek/features/routes/domain/entities/delivery_route.dart';
import 'package:pathseek/features/routes/presentation/bloc/route_bloc.dart';

void main() {
  const route = DeliveryRoute(
    id: 'r1',
    fecha: '2026-10-05',
    placa: 'ABC123',
    distanciaKm: 45.2,
  );

  group('RouteState', () {
    test('initial state', () {
      const state = RouteState.initial();
      expect(state.routes, isEmpty);
      expect(state.isLoading, isFalse);
      expect(state.isGenerating, isFalse);
      expect(state.hasError, isFalse);
      expect(state.hasGenerateError, isFalse);
      expect(state.hasSaveError, isFalse);
      expect(state.hasDetailError, isFalse);
      expect(state.isEmpty, isTrue);
    });

    test('copyWith preserves untouched fields', () {
      const state = RouteState(routes: [route]);
      final updated = state.copyWith(isGenerating: true);
      expect(updated.routes, [route]);
      expect(updated.isGenerating, isTrue);
    });

    test('helpers detect errors', () {
      const withError = RouteState(generateErrorMessage: 'x');
      expect(withError.hasGenerateError, isTrue);
      const withDetail = RouteState(detailError: 'y');
      expect(withDetail.hasDetailError, isTrue);
    });
  });

  group('RouteEvent props', () {
    test('events expose their fields', () {
      expect(const RoutesLoaded(fecha: '2026-10-05').props, ['2026-10-05']);
      expect(const RoutesGenerated().props, isEmpty);
      expect(const RouteDetailRequested('r1').props, ['r1']);
      expect(const RouteDeleted('r1').props, ['r1']);
    });
  });

  group('DashboardState', () {
    test('initial state', () {
      const state = DashboardState.initial();
      expect(state.summary, isNull);
      expect(state.isLoading, isFalse);
      expect(state.hasError, isFalse);
    });

    test('copyWith preserves summary', () {
      const state = DashboardState();
      final updated = state.copyWith(isLoading: true);
      expect(updated.isLoading, isTrue);
      expect(updated.summary, isNull);
    });

    test('error helper', () {
      const withError = DashboardState(errorMessage: 'x');
      expect(withError.hasError, isTrue);
    });
  });

  group('DashboardEvent props', () {
    test('DashboardLoaded has no fields', () {
      expect(const DashboardLoaded().props, isEmpty);
    });
  });
}
