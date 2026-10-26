import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pathseek/core/errors/failures.dart';
import 'package:pathseek/features/clients/domain/entities/client_profile.dart';
import 'package:pathseek/features/clients/domain/repositories/clients_repository.dart';

part 'clients_event.dart';
part 'clients_state.dart';

class ClientsBloc extends Bloc<ClientsEvent, ClientsState> {
  ClientsBloc({required ClientsRepository repository})
      : _repository = repository,
        super(const ClientsState.initial()) {
    on<ClientsLoaded>(_onLoaded);
    on<ClientSaved>(_onSaved);
    on<ClientDeleted>(_onDeleted);
  }

  final ClientsRepository _repository;

  Future<void> _onLoaded(
    ClientsLoaded event,
    Emitter<ClientsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final clients = await _repository.getClients();
      emit(state.copyWith(isLoading: false, clients: clients));
    } on Failure catch (failure) {
      emit(state.copyWith(isLoading: false, errorMessage: failure.message));
    }
  }

  Future<void> _onSaved(
    ClientSaved event,
    Emitter<ClientsState> emit,
  ) async {
    emit(state.copyWith(isSaving: true, saveErrorMessage: null));
    try {
      final saved = event.id == null
          ? await _repository.createClient(event.payload)
          : await _repository.updateClient(event.id!, event.payload);
      final others = state.clients
          .where((client) => client.id != saved.id)
          .toList();
      emit(
        state.copyWith(
          isSaving: false,
          clients: [...others, saved],
          lastSavedId: saved.id,
        ),
      );
    } on Failure catch (failure) {
      emit(state.copyWith(isSaving: false, saveErrorMessage: failure.message));
    }
  }

  Future<void> _onDeleted(
    ClientDeleted event,
    Emitter<ClientsState> emit,
  ) async {
    emit(state.copyWith(isSaving: true, saveErrorMessage: null));
    try {
      await _repository.deleteClient(event.id);
      emit(
        state.copyWith(
          isSaving: false,
          clients: state.clients.where((client) => client.id != event.id).toList(),
        ),
      );
    } on Failure catch (failure) {
      emit(state.copyWith(isSaving: false, saveErrorMessage: failure.message));
    }
  }
}
