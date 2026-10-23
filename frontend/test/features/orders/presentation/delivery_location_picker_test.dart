import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:pathseek/features/orders/presentation/widgets/delivery_location_picker.dart';

void main() {
  testWidgets('destination requires a map selection and returns GPS coordinates', (tester) async {
    LatLng? result;
    await tester.pumpWidget(MaterialApp(home: Builder(builder: (context) => Scaffold(
      body: TextButton(onPressed: () async {
        result = await showDialog<LatLng>(context: context, builder: (_) => const DeliveryLocationPicker(showBaseMap: false));
      }, child: const Text('Seleccionar'))))));
    await tester.tap(find.text('Seleccionar'));
    await tester.pumpAndSettle();
    expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed, isNull);
    await tester.tapAt(tester.getCenter(find.byType(FlutterMap)));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed, isNotNull);
    await tester.tap(find.text('Usar destino'));
    await tester.pumpAndSettle();
    expect(result, isNotNull);
    expect(result!.latitude, closeTo(-12.0683, .01));
    expect(result!.longitude, closeTo(-75.21, .01));
  });
}
