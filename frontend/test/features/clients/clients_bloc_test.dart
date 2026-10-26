import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pathseek/core/errors/failures.dart';
import 'package:pathseek/features/clients/data/models/client_profile_model.dart';
import 'package:pathseek/features/clients/domain/entities/client_profile.dart';
import 'package:pathseek/features/clients/domain/repositories/clients_repository.dart';
import 'package:pathseek/features/clients/presentation/bloc/clients_bloc.dart';

class MockClientsRepository extends Mock implements ClientsRepository {}

void main() {
  late MockClientsRepository repository;
  late ClientsBloc bloc;

  const client = ClientProfile(
    id: 'c1',
    usuarioId: 'u1',
    nombre: 'Bodega El Ahorro',
    direccion: 'Jr. Real 450',
    horarioAtencionInicio: '06:00',
    horarioAtencionFin: '21:00',
  );

  setUp(() {
    repository = MockClientsRepository();
    bloc = ClientsBloc(repository: repository);
  });

  tearDown(() => bloc.close());

  test('model parses the backend contract', () {
    final model = ClientProfileModel.fromJson({
      'cliente_id': 'c1',
      'usuario_id': 'u1',
      'nombre': 'Bodega El Ahorro',
      'direccion': 'Jr. Real 450',
      'punto_referencia': 'Frente a la plazuela',
      'telefono': '964123456',
      'horario_atencion_inicio': '06:00',
      'horario_atencion_fin': '21:00',
      'restricciones_acceso': 'Sin camiones después de las 14:00',
    });
    final entity = model.toEntity();
    expect(entity.nombre, 'Bodega El Ahorro');
    expect(entity.horarioLabel, '06:00 – 21:00');
    expect(entity.puntoReferencia, 'Frente a la plazuela');
  });

  blocTest<ClientsBloc, ClientsState>(
    'loads clients',
    build: () {
      when(() => repository.getClients()).thenAnswer((_) async => const [client]);
      return bloc;
    },
    act: (bloc) => bloc.add(const ClientsLoaded()),
    expect: () => [
      isA<ClientsState>().having((s) => s.isLoading, 'isLoading', true),
      isA<ClientsState>()
          .having((s) => s.clients, 'clients', const [client])
          .having((s) => s.isLoading, 'isLoading', false),
    ],
  );

  blocTest<ClientsBloc, ClientsState>(
    'creates a client and appends it to the list',
    build: () {
      when(() => repository.createClient(any()))
          .thenAnswer((_) async => client);
      return bloc;
    },
    act: (bloc) => bloc.add(
      const ClientSaved(payload: {'nombre': 'Bodega El Ahorro'}),
    ),
    expect: () => [
      isA<ClientsState>().having((s) => s.isSaving, 'isSaving', true),
      isA<ClientsState>()
          .having((s) => s.clients, 'clients', const [client])
          .having((s) => s.lastSavedId, 'savedId', 'c1'),
    ],
  );

  blocTest<ClientsBloc, ClientsState>(
    'deletes a client',
    build: () {
      when(() => repository.deleteClient('c1')).thenAnswer((_) async {});
      return bloc;
    },
    seed: () => const ClientsState(clients: [client]),
    act: (bloc) => bloc.add(const ClientDeleted('c1')),
    expect: () => [
      isA<ClientsState>().having((s) => s.isSaving, 'isSaving', true),
      isA<ClientsState>().having((s) => s.clients, 'clients', isEmpty),
    ],
  );

  blocTest<ClientsBloc, ClientsState>(
    'sets save error on failure',
    build: () {
      when(() => repository.createClient(any()))
          .thenThrow(const ValidationFailure('Horario inválido'));
      return bloc;
    },
    act: (bloc) => bloc.add(const ClientSaved(payload: {'nombre': 'X'})),
    expect: () => [
      isA<ClientsState>().having((s) => s.isSaving, 'isSaving', true),
      isA<ClientsState>().having(
        (s) => s.saveErrorMessage,
        'error',
        'Horario inválido',
      ),
    ],
  );
}
