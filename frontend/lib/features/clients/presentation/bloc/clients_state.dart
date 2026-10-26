part of 'clients_bloc.dart';

class ClientsState extends Equatable {
  const ClientsState({
    this.clients = const [],
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
    this.saveErrorMessage,
    this.lastSavedId,
  });

  const ClientsState.initial() : this();

  final List<ClientProfile> clients;
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final String? saveErrorMessage;
  final String? lastSavedId;

  ClientsState copyWith({
    List<ClientProfile>? clients,
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    String? saveErrorMessage,
    String? lastSavedId,
  }) {
    return ClientsState(
      clients: clients ?? this.clients,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage,
      saveErrorMessage: saveErrorMessage,
      lastSavedId: lastSavedId,
    );
  }

  @override
  List<Object?> get props => [
    clients,
    isLoading,
    isSaving,
    errorMessage,
    saveErrorMessage,
    lastSavedId,
  ];
}
