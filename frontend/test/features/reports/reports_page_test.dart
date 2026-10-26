import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pathseek/features/reports/presentation/pages/reports_page.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es');
  });

  testWidgets('reports page renders the download controls', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: ReportsPage())),
    );

    expect(find.text('Reportes de sostenibilidad'), findsOneWidget);
    expect(find.text('Descargar PDF'), findsOneWidget);
    expect(find.text('Rango de fechas'), findsOneWidget);
    expect(find.text('Contenido del reporte'), findsOneWidget);
  });
}
