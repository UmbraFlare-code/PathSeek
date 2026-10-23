import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:pathseek/features/routes/domain/entities/delivery_route.dart';
import 'package:pathseek/features/routes/presentation/widgets/elevation_profile_widget.dart';
import 'package:pathseek/features/routes/presentation/widgets/interactive_route_map.dart';

void main() {
  group('InteractiveRouteMap & ElevationProfileWidget', () {
    const route = DeliveryRoute(
      id: 'r-101',
      fecha: '2026-10-06',
      conductorNombre: 'Juan Perez',
      placa: 'EGB-101',
      distanciaKm: 34.5,
      co2Kg: 8.2,
      combustibleL: 3.5,
      pedidos: [
        RouteOrder(
          pedidoId: 'p-1',
          orden: 1,
          horaEstimada: '08:45',
          direccion: 'I.E. Santa Isabel',
          gpsLat: -12.062000,
          gpsLon: -75.205000,
          peso: 50.0,
          contextoVial: RoadContext(
            tipoSuperficie: 'ASFALTO',
            elevacionMetros: 3260,
            pendientePorcentaje: 2.1,
            nivelCongestion: 'FLUIDO',
          ),
        ),
        RouteOrder(
          pedidoId: 'p-2',
          orden: 2,
          horaEstimada: '09:30',
          direccion: 'I.E. Enma Luzmila',
          gpsLat: -12.055000,
          gpsLon: -75.215000,
          peso: 40.0,
          contextoVial: RoadContext(
            tipoSuperficie: 'AFIRMADO',
            elevacionMetros: 3450,
            pendientePorcentaje: 6.5,
            nivelCongestion: 'MODERADO',
          ),
        ),
      ],
    );

    testWidgets('Geographic map selects deliveries and supports recentering', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: InteractiveRouteMap(route: route, showBaseMap: false),
            ),
          ),
        ),
      );

      expect(
        find.textContaining('Recorrido vial no disponible'),
        findsOneWidget,
      );
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.byType(PolylineLayer), findsNothing);

      await tester.tap(find.byKey(const ValueKey('stop-p-1')));
      await tester.pump();
      expect(
        find.textContaining('Parada #1: I.E. Santa Isabel'),
        findsOneWidget,
      );
      await tester.ensureVisible(find.text('Ver ruta completa'));
      await tester.tap(find.text('Ver ruta completa'));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('street geometry is distinguished from schematic fallback', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: InteractiveRouteMap(
                showBaseMap: false,
                route: DeliveryRoute(
                  id: 'street',
                  fecha: '2026-10-22',
                  geometrySource: 'OSRM',
                  encodedPolyline: '_p~iF~ps|U_ulLnnqC_mqNvxq`@',
                  roadDistanceKm: 1.25,
                  roadTravelMinutes: 3,
                ),
              ),
            ),
          ),
        ),
      );
      expect(find.textContaining('Por calles (OSRM)'), findsOneWidget);
      expect(find.textContaining('1.25 km por calles'), findsOneWidget);
      expect(find.byType(PolylineLayer), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('legacy straight geometry is hidden and retry is accessible', (
      tester,
    ) async {
      var retries = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: InteractiveRouteMap(
                showBaseMap: false,
                onRetryGeometry: () => retries++,
                route: const DeliveryRoute(
                  id: 'legacy',
                  fecha: '2026-10-22',
                  geometrySource: 'SCHEMATIC',
                  encodedPolyline: '_p~iF~ps|U_ulLnnqC_mqNvxq`@',
                ),
              ),
            ),
          ),
        ),
      );
      expect(find.byType(PolylineLayer), findsNothing);
      await tester.ensureVisible(find.text('Reintentar recorrido por calles'));
      await tester.tap(find.text('Reintentar recorrido por calles'));
      expect(retries, 1);
      expect(tester.takeException(), isNull);
    });

    testWidgets('ElevationProfileWidget renders altitude metrics for stops', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ElevationProfileWidget(route: route)),
        ),
      );

      expect(find.text('Altitud y calzada estimadas'), findsOneWidget);
      expect(find.text('Parada #1'), findsOneWidget);
      expect(find.text('3260 m'), findsOneWidget);
      expect(find.text('Parada #2'), findsOneWidget);
      expect(find.text('3450 m'), findsOneWidget);
      expect(find.text('AFIRMADO'), findsOneWidget);
    });
  });
}
