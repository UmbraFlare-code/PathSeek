part of 'notifications_bloc.dart';

class NotificationsState extends Equatable {
  const NotificationsState({
    this.notifications = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  const NotificationsState.initial() : this();

  final List<RouteNotification> notifications;
  final bool isLoading;
  final String? errorMessage;

  bool get hasUnread =>
      notifications.any((notification) => !notification.leida);

  NotificationsState copyWith({
    List<RouteNotification>? notifications,
    bool? isLoading,
    String? errorMessage,
  }) {
    return NotificationsState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [notifications, isLoading, errorMessage];
}
