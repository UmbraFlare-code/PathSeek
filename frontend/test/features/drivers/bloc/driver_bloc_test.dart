import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pathseek/core/errors/failures.dart';
import 'package:pathseek/features/drivers/domain/entities/driver.dart';
import 'package:pathseek/features/drivers/domain/repositories/driver_repository.dart';
import 'package:pathseek/features/drivers/presentation/bloc/driver_bloc.dart';

class MockDriverRepository extends Mock implements DriverRepository {}

void main() {
  late MockDriverRepository repository;
  late DriverBloc bloc;

  const driver = Driver(
    id: 'd1',
    usuarioId: 'u1',
    dni: '12345678',
    nombre: 'Carlos Gomez',
    licencia: 'Q12345678',
    categoria: 'AII',
    experiencia: 5,
    disponible: true,
    contacto: '999888777',
  );

  setUp(() {
    repository = MockDriverRepository();
    bloc = DriverBloc(repository: repository);
  });

  tearDown(() => bloc.close());

  group('DriverBloc', () {
    test('initial state is initial', () {
      expect(bloc.state, const DriverState.initial());
    });

    blocTest<DriverBloc, DriverState>(
      'loads drivers successfully',
      build: () {
        when(() => repository.getDrivers())
            .thenAnswer((_) async => [driver]);
        return bloc;
      },
      act: (bloc) => bloc.add(const DriversLoaded()),
      expect: () => [
        isA<DriverState>().having((s) => s.isLoading, 'isLoading', true),
        isA<DriverState>()
            .having((s) => s.drivers, 'drivers', [driver])
            .having((s) => s.isLoading, 'isLoading', false),
      ],
    );

    blocTest<DriverBloc, DriverState>(
      'creates driver successfully',
      build: () {
        when(() => repository.createDriver(driver))
            .thenAnswer((_) async => driver);
        return bloc;
      },
      act: (bloc) => bloc.add(const DriverCreated(driver)),
      expect: () => [
        isA<DriverState>().having((s) => s.isSaving, 'isSaving', true),
        isA<DriverState>()
            .having((s) => s.saveSuccess, 'saveSuccess', true)
            .having((s) => s.drivers, 'drivers', [driver]),
      ],
    );

    blocTest<DriverBloc, DriverState>(
      'updates driver in list',
      build: () {
        when(() => repository.updateDriver(driver))
            .thenAnswer((_) async => driver);
        return bloc;
      },
      seed: () => const DriverState(drivers: [driver]),
      act: (bloc) => bloc.add(const DriverUpdated(driver)),
      expect: () => [
        isA<DriverState>().having((s) => s.isSaving, 'isSaving', true),
        isA<DriverState>()
            .having((s) => s.saveSuccess, 'saveSuccess', true)
            .having((s) => s.drivers, 'drivers', [driver]),
      ],
    );

    blocTest<DriverBloc, DriverState>(
      'deletes driver from list',
      build: () {
        when(() => repository.deleteDriver('d1')).thenAnswer((_) async {});
        return bloc;
      },
      seed: () => const DriverState(drivers: [driver]),
      act: (bloc) => bloc.add(const DriverDeleted('d1')),
      expect: () => [
        isA<DriverState>().having((s) => s.isSaving, 'isSaving', true),
        isA<DriverState>().having((s) => s.drivers, 'drivers', isEmpty),
      ],
    );

    blocTest<DriverBloc, DriverState>(
      'sets save error message on failure',
      build: () {
        when(() => repository.createDriver(driver))
            .thenThrow(const ServerFailure('Error interno'));
        return bloc;
      },
      act: (bloc) => bloc.add(const DriverCreated(driver)),
      expect: () => [
        isA<DriverState>().having((s) => s.isSaving, 'isSaving', true),
        isA<DriverState>()
            .having((s) => s.saveErrorMessage, 'saveError', 'Error interno'),
      ],
    );
  });
}
