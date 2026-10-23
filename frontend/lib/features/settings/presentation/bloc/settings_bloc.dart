import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/settings_entities.dart';
import '../../domain/repositories/settings_repository.dart';

sealed class SettingsEvent {}

class SettingsLoaded extends SettingsEvent {
  SettingsLoaded({required this.manageUsers});
  final bool manageUsers;
}

class SettingsRolesLoaded extends SettingsEvent {}

class SettingsUsersLoaded extends SettingsEvent {
  SettingsUsersLoaded(this.query);
  final UserQuery query;
}

class SettingsUserSaved extends SettingsEvent {
  SettingsUserSaved(this.changes);
  final UserChanges changes;
}

class SettingsUserFormOpened extends SettingsEvent {}

class SettingsState extends Equatable {
  const SettingsState({
    this.roles = const [],
    this.userPage,
    this.query = const UserQuery(),
    this.loadingRoles = false,
    this.loadingUsers = false,
    this.saving = false,
    this.rolesError,
    this.usersError,
    this.saveError,
    this.savedRevision = 0,
  });
  final List<RoleDefinition> roles;
  final UserPage? userPage;
  final UserQuery query;
  final bool loadingRoles, loadingUsers, saving;
  final String? rolesError, usersError, saveError;
  final int savedRevision;

  SettingsState copyWith({
    List<RoleDefinition>? roles,
    UserPage? userPage,
    UserQuery? query,
    bool? loadingRoles,
    bool? loadingUsers,
    bool? saving,
    String? rolesError,
    String? usersError,
    String? saveError,
    bool clearRolesError = false,
    bool clearUsersError = false,
    bool clearSaveError = false,
    int? savedRevision,
  }) => SettingsState(
    roles: roles ?? this.roles,
    userPage: userPage ?? this.userPage,
    query: query ?? this.query,
    loadingRoles: loadingRoles ?? this.loadingRoles,
    loadingUsers: loadingUsers ?? this.loadingUsers,
    saving: saving ?? this.saving,
    rolesError: clearRolesError ? null : rolesError ?? this.rolesError,
    usersError: clearUsersError ? null : usersError ?? this.usersError,
    saveError: clearSaveError ? null : saveError ?? this.saveError,
    savedRevision: savedRevision ?? this.savedRevision,
  );
  @override
  List<Object?> get props => [
    roles,
    userPage,
    query,
    loadingRoles,
    loadingUsers,
    saving,
    rolesError,
    usersError,
    saveError,
    savedRevision,
  ];
}

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc({required SettingsRepository repository})
    : _repository = repository,
      super(const SettingsState()) {
    on<SettingsLoaded>((event, emit) {
      _manageUsers = event.manageUsers;
      add(SettingsRolesLoaded());
      if (_manageUsers) add(SettingsUsersLoaded(const UserQuery()));
    });
    on<SettingsRolesLoaded>(_loadRoles);
    on<SettingsUsersLoaded>(_loadUsers);
    on<SettingsUserSaved>(_save);
    on<SettingsUserFormOpened>((event, emit) {
      emit(state.copyWith(clearSaveError: true));
    });
  }
  final SettingsRepository _repository;
  bool _manageUsers = false;
  int _usersRequest = 0;

  String _message(Object error) => error is Failure
      ? error.message
      : 'No se pudo completar la solicitud. Inténtalo de nuevo.';

  Future<void> _loadRoles(
    SettingsRolesLoaded event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(loadingRoles: true, clearRolesError: true));
    try {
      final roles = await _repository.getRoles();
      emit(state.copyWith(roles: roles, loadingRoles: false));
    } catch (error) {
      emit(state.copyWith(loadingRoles: false, rolesError: _message(error)));
    }
  }

  Future<void> _loadUsers(
    SettingsUsersLoaded event,
    Emitter<SettingsState> emit,
  ) async {
    if (!_manageUsers) return;
    final request = ++_usersRequest;
    emit(
      state.copyWith(
        query: event.query,
        loadingUsers: true,
        clearUsersError: true,
      ),
    );
    try {
      final page = await _repository.getUsers(event.query);
      if (request != _usersRequest) return;
      emit(state.copyWith(userPage: page, loadingUsers: false));
    } catch (error) {
      if (request != _usersRequest) return;
      emit(state.copyWith(loadingUsers: false, usersError: _message(error)));
    }
  }

  Future<void> _save(
    SettingsUserSaved event,
    Emitter<SettingsState> emit,
  ) async {
    if (!_manageUsers || state.saving) return;
    emit(state.copyWith(saving: true, clearSaveError: true));
    try {
      await _repository.saveUser(event.changes);
      emit(
        state.copyWith(saving: false, savedRevision: state.savedRevision + 1),
      );
      add(SettingsUsersLoaded(state.query));
    } catch (error) {
      emit(state.copyWith(saving: false, saveError: _message(error)));
    }
  }
}
