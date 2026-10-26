part of 'clients_bloc.dart';

sealed class ClientsEvent extends Equatable {
  const ClientsEvent();

  @override
  List<Object?> get props => [];
}

class ClientsLoaded extends ClientsEvent {
  const ClientsLoaded();
}

class ClientSaved extends ClientsEvent {
  const ClientSaved({required this.payload, this.id});

  final Map<String, dynamic> payload;
  final String? id;

  @override
  List<Object?> get props => [payload, id];
}

class ClientDeleted extends ClientsEvent {
  const ClientDeleted(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}
