part of 'notifications_bloc.dart';

sealed class NotificationsEvent extends Equatable {
  const NotificationsEvent();

  @override
  List<Object?> get props => [];
}

class NotificationsLoaded extends NotificationsEvent {
  const NotificationsLoaded();
}

class NotificationMarkedRead extends NotificationsEvent {
  const NotificationMarkedRead(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}
