import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pathseek/core/errors/failures.dart';
import 'package:pathseek/features/fleet/domain/entities/vehicle.dart';
import 'package:pathseek/features/fleet/domain/repositories/fleet_repository.dart';
import 'package:pathseek/features/fleet/presentation/bloc/fleet_bloc.dart';

class MockFleetRepository extends Mock implements FleetRepository {}

void main() {
  late MockFleetRepository repository;
  late FleetBloc bloc;

  const vehicle = Vehicle(
    id: 'v1',
    placa: 'ABC123',
    tipo: 'CAMIONETA',
    capacidadKg: 500,
    capacidadM3: 3,
    consumoKmL: 12,
    factorEmision: 0.25,
    anio: 2020,
  );

  setUp(() {
    repository = MockFleetRepository();
    bloc = FleetBloc(repository: repository);
  });

  tearDown(() => bloc.close());

  group('FleetBloc', () {
    test('initial state is initial', () {
      expect(bloc.state, const FleetState.initial());
    });

    blocTest<FleetBloc, FleetState>(
      'loads vehicles successfully',
      build: () {
        when(() => repository.getVehicles())
            .thenAnswer((_) async => [vehicle]);
        return bloc;
      },
      act: (bloc) => bloc.add(const FleetLoaded()),
      expect: () => [
        isA<FleetState>()
            .having((s) => s.isLoading, 'isLoading', true),
        isA<FleetState>()
            .having((s) => s.vehicles, 'vehicles', [vehicle])
            .having((s) => s.isLoading, 'isLoading', false),
      ],
    );

    blocTest<FleetBloc, FleetState>(
      'sets error message when load fails',
      build: () {
        when(() => repository.getVehicles())
            .thenThrow(const ServerFailure('Error del servidor'));
        return bloc;
      },
      act: (bloc) => bloc.add(const FleetLoaded()),
      expect: () => [
        isA<FleetState>().having((s) => s.isLoading, 'isLoading', true),
        isA<FleetState>()
            .having((s) => s.errorMessage, 'error', 'Error del servidor'),
      ],
    );

    blocTest<FleetBloc, FleetState>(
      'creates vehicle and appends to list',
      build: () {
        when(() => repository.createVehicle(vehicle))
            .thenAnswer((_) async => vehicle);
        return bloc;
      },
      act: (bloc) => bloc.add(const FleetVehicleCreated(vehicle)),
      expect: () => [
        isA<FleetState>()
            .having((s) => s.isSaving, 'isSaving', true),
        isA<FleetState>()
            .having((s) => s.saveSuccess, 'saveSuccess', true)
            .having((s) => s.vehicles, 'vehicles', [vehicle]),
      ],
    );

    blocTest<FleetBloc, FleetState>(
      'sets save error on duplicate plate (validation failure)',
      build: () {
        when(() => repository.createVehicle(vehicle))
            .thenThrow(const ValidationFailure('La placa ya existe'));
        return bloc;
      },
      act: (bloc) => bloc.add(const FleetVehicleCreated(vehicle)),
      expect: () => [
        isA<FleetState>().having((s) => s.isSaving, 'isSaving', true),
        isA<FleetState>()
            .having((s) => s.saveErrorMessage, 'saveError', 'La placa ya existe'),
      ],
    );

    blocTest<FleetBloc, FleetState>(
      'updates existing vehicle',
      build: () {
        when(() => repository.updateVehicle(vehicle))
            .thenAnswer((_) async => vehicle);
        return bloc;
      },
      seed: () => const FleetState(vehicles: [vehicle]),
      act: (bloc) => bloc.add(const FleetVehicleUpdated(vehicle)),
      expect: () => [
        isA<FleetState>().having((s) => s.isSaving, 'isSaving', true),
        isA<FleetState>()
            .having((s) => s.saveSuccess, 'saveSuccess', true)
            .having((s) => s.vehicles, 'vehicles', [vehicle]),
      ],
    );

    blocTest<FleetBloc, FleetState>(
      'deletes vehicle from list',
      build: () {
        when(() => repository.deleteVehicle('v1'))
            .thenAnswer((_) async {});
        return bloc;
      },
      seed: () => const FleetState(vehicles: [vehicle]),
      act: (bloc) => bloc.add(const FleetVehicleDeleted('v1')),
      expect: () => [
        isA<FleetState>().having((s) => s.isSaving, 'isSaving', true),
        isA<FleetState>().having((s) => s.vehicles, 'vehicles', isEmpty),
      ],
    );
  });
}
