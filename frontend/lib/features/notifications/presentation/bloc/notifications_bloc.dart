import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pathseek/core/errors/failures.dart';
import 'package:pathseek/features/notifications/domain/entities/route_notification.dart';
import 'package:pathseek/features/notifications/domain/repositories/notifications_repository.dart';

part 'notifications_event.dart';
part 'notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  NotificationsBloc({required NotificationsRepository repository})
      : _repository = repository,
        super(const NotificationsState.initial()) {
    on<NotificationsLoaded>(_onLoaded);
    on<NotificationMarkedRead>(_onMarkedRead);
  }

  final NotificationsRepository _repository;

  Future<void> _onLoaded(
    NotificationsLoaded event,
    Emitter<NotificationsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final notifications = await _repository.getNotifications();
      emit(
        state.copyWith(
          isLoading: false,
          notifications: notifications,
        ),
      );
    } on Failure catch (failure) {
      emit(state.copyWith(isLoading: false, errorMessage: failure.message));
    }
  }

  Future<void> _onMarkedRead(
    NotificationMarkedRead event,
    Emitter<NotificationsState> emit,
  ) async {
    try {
      await _repository.markRead(event.id);
      final notifications = state.notifications
          .map(
            (notification) => notification.id == event.id
                ? RouteNotification(
                    id: notification.id,
                    rutaId: notification.rutaId,
                    mensaje: notification.mensaje,
                    leida: true,
                    createdAt: notification.createdAt,
                  )
                : notification,
          )
          .toList();
      emit(state.copyWith(notifications: notifications));
    } on Failure catch (failure) {
      emit(state.copyWith(errorMessage: failure.message));
    }
  }
}
