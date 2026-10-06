import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pathseek/core/errors/exceptions.dart';
import 'package:pathseek/core/errors/failures.dart';
import 'package:pathseek/features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'package:pathseek/features/dashboard/data/models/dashboard_summary_model.dart';
import 'package:pathseek/features/dashboard/data/repositories/dashboard_repository_impl.dart';

class MockDashboardRemoteDataSource extends Mock
    implements DashboardRemoteDataSource {}

void main() {
  late MockDashboardRemoteDataSource remoteDataSource;
  late DashboardRepositoryImpl repository;

  const model = DashboardSummaryModel(
    totalVehiculos: 15,
    pedidosPendientes: 22,
    co2TotalKg: 125.5,
  );

  setUp(() {
    remoteDataSource = MockDashboardRemoteDataSource();
    repository =
        DashboardRepositoryImpl(remoteDataSource: remoteDataSource);
  });

  group('DashboardRepositoryImpl', () {
    test('getSummary returns entity on success', () async {
      when(() => remoteDataSource.getSummary())
          .thenAnswer((_) async => model);

      final summary = await repository.getSummary();

      expect(summary.totalVehiculos, 15);
      expect(summary.pedidosPendientes, 22);
      expect(summary.co2TotalKg, 125.5);
    });

    test('maps 401 to UnauthorizedFailure', () async {
      when(() => remoteDataSource.getSummary()).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/api/v1/dashboard/resumen'),
          response: Response(
            requestOptions:
                RequestOptions(path: '/api/v1/dashboard/resumen'),
            statusCode: 401,
            data: {'message': 'Sesion expirada'},
          ),
        ),
      );

      expect(
        () => repository.getSummary(),
        throwsA(isA<UnauthorizedFailure>()),
      );
    });

    test('maps connection errors to NetworkFailure', () async {
      when(() => remoteDataSource.getSummary()).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/api/v1/dashboard/resumen'),
          error: const NoConnectionException(),
        ),
      );

      expect(
        () => repository.getSummary(),
        throwsA(isA<NetworkFailure>()),
      );
    });
  });
}
