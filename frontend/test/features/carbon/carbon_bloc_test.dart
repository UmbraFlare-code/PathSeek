import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pathseek/core/errors/failures.dart';
import 'package:pathseek/features/carbon/data/models/carbon_plan_model.dart';
import 'package:pathseek/features/carbon/domain/entities/carbon_plan.dart';
import 'package:pathseek/features/carbon/domain/repositories/carbon_repository.dart';
import 'package:pathseek/features/carbon/presentation/bloc/carbon_bloc.dart';

class MockCarbonRepository extends Mock implements CarbonRepository {}

void main() {
  late MockCarbonRepository repository;
  late CarbonBloc bloc;

  const plan = CarbonPlan(
    emisionesAnualesKg: 42.0,
    emisionesAnualesT: 0.042,
    arbolesEquivalentes: 3,
    periodoDesde: '2025-10-25',
    periodoHasta: '2026-10-25',
    proyectos: [],
  );

  setUp(() {
    repository = MockCarbonRepository();
    bloc = CarbonBloc(repository: repository);
  });

  tearDown(() => bloc.close());

  test('model parses the backend contract', () {
    final model = CarbonPlanModel.fromJson({
      'emisiones_anuales_kg': 42000,
      'emisiones_anuales_t': 42.0,
      'arboles_equivalentes': 2100,
      'periodo_desde': '2025-10-25',
      'periodo_hasta': '2026-10-25',
      'proyectos': [
        {
          'proyecto_id': 'p1',
          'nombre': 'Reforestación Valle del Mantaro',
          'tipo': 'REFORESTACION',
          'costo_tonelada': 35.0,
          'coste_compensacion_estimado': 1470.0,
          'descripcion': 'Plantación de árboles nativos',
        },
      ],
    });
    final entity = model.toEntity();
    expect(entity.arbolesEquivalentes, 2100);
    expect(entity.proyectos.single.nombre, 'Reforestación Valle del Mantaro');
  });

  blocTest<CarbonBloc, CarbonState>(
    'loads the carbon plan',
    build: () {
      when(() => repository.getPlan()).thenAnswer((_) async => plan);
      return bloc;
    },
    act: (bloc) => bloc.add(const CarbonPlanRequested()),
    expect: () => [
      isA<CarbonState>().having((s) => s.isLoading, 'isLoading', true),
      isA<CarbonState>()
          .having((s) => s.plan, 'plan', plan)
          .having((s) => s.isLoading, 'isLoading', false),
    ],
  );

  blocTest<CarbonBloc, CarbonState>(
    'sets error message on failure',
    build: () {
      when(() => repository.getPlan())
          .thenThrow(const NetworkFailure('Sin conexión'));
      return bloc;
    },
    act: (bloc) => bloc.add(const CarbonPlanRequested()),
    expect: () => [
      isA<CarbonState>().having((s) => s.isLoading, 'isLoading', true),
      isA<CarbonState>()
          .having((s) => s.errorMessage, 'error', 'Sin conexión'),
    ],
  );
}
