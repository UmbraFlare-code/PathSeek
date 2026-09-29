part of 'auth_bloc.dart';

class AuthState extends Equatable {
  const AuthState._({
    this.user,
    this.errorMessage,
    this.isLoading = false,
  });

  const AuthState.unknown()
      : this._();

  const AuthState.loading()
      : this._(isLoading: true);

  const AuthState.unauthenticated()
      : this._();

  factory AuthState.authenticated(AppUser user) =>
      AuthState._(user: user);

  factory AuthState.failure(String message) =>
      AuthState._(errorMessage: message);

  final AppUser? user;
  final String? errorMessage;
  final bool isLoading;

  bool get isUnknown => user == null && !isLoading && errorMessage == null;
  bool get isAuthenticated => user != null;
  bool get isUnauthenticated => user == null && !isLoading && errorMessage == null;
  bool get hasError => errorMessage != null;

  @override
  List<Object?> get props => [user, errorMessage, isLoading];
}
