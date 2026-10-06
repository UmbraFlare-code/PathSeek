import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pathseek/core/errors/failures.dart';
import 'package:pathseek/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:pathseek/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:pathseek/features/dashboard/presentation/bloc/dashboard_bloc.dart';

class MockDashboardRepository extends Mock implements DashboardRepository {}

void main() {
  late MockDashboardRepository repository;
  late DashboardBloc bloc;

  const summary = DashboardSummary(
    totalVehiculos: 15,
    conductoresDisponibles: 8,
    pedidosPendientes: 22,
    rutasPlanificadas: 6,
    co2TotalKg: 125.5,
    combustibleTotalL: 300.25,
  );

  setUp(() {
    repository = MockDashboardRepository();
    bloc = DashboardBloc(repository: repository);
  });

  tearDown(() => bloc.close());

  group('DashboardBloc', () {
    test('initial state is initial', () {
      expect(bloc.state, const DashboardState.initial());
    });

    blocTest<DashboardBloc, DashboardState>(
      'loads summary successfully',
      build: () {
        when(() => repository.getSummary()).thenAnswer((_) async => summary);
        return bloc;
      },
      act: (bloc) => bloc.add(const DashboardLoaded()),
      expect: () => [
        isA<DashboardState>().having((s) => s.isLoading, 'isLoading', true),
        isA<DashboardState>()
            .having((s) => s.summary, 'summary', summary)
            .having((s) => s.isLoading, 'isLoading', false),
      ],
    );

    blocTest<DashboardBloc, DashboardState>(
      'sets error message on failure',
      build: () {
        when(() => repository.getSummary())
            .thenThrow(const ServerFailure('Error del servidor'));
        return bloc;
      },
      act: (bloc) => bloc.add(const DashboardLoaded()),
      expect: () => [
        isA<DashboardState>().having((s) => s.isLoading, 'isLoading', true),
        isA<DashboardState>()
            .having((s) => s.errorMessage, 'error', 'Error del servidor')
            .having((s) => s.hasError, 'hasError', true),
      ],
    );
  });
}
