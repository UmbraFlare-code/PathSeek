import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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

    testWidgets('InteractiveRouteMap renders stops and simulation button',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: InteractiveRouteMap(route: route),
          ),
        ),
      );

      expect(find.textContaining('MAPA // UGEL HUANCAYO'), findsOneWidget);
      expect(find.text('Simular GPS'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);

      // Tocar botón de simulación
      await tester.tap(find.text('Simular GPS'));
      await tester.pump();
      expect(find.text('Detener'), findsOneWidget);
    });

    testWidgets('ElevationProfileWidget renders altitude metrics for stops',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ElevationProfileWidget(route: route),
          ),
        ),
      );

      expect(find.textContaining('PERFIL ALTIMÉTRICO'), findsOneWidget);
      expect(find.text('Parada #1'), findsOneWidget);
      expect(find.text('3260 m'), findsOneWidget);
      expect(find.text('Parada #2'), findsOneWidget);
      expect(find.text('3450 m'), findsOneWidget);
      expect(find.text('AFIRMADO'), findsOneWidget);
    });
  });
}
