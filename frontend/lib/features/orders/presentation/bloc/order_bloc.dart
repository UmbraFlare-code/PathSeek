import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/order.dart';
import '../../domain/repositories/order_repository.dart';

part 'order_event.dart';
part 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  OrderBloc({required OrderRepository repository})
      : _repository = repository,
        super(const OrderState.initial()) {
    on<OrdersLoaded>(_onOrdersLoaded);
    on<OrderCreated>(_onOrderCreated);
    on<OrderUpdated>(_onOrderUpdated);
    on<OrderDeleted>(_onOrderDeleted);
  }

  final OrderRepository _repository;

  Future<void> _onOrdersLoaded(
    OrdersLoaded event,
    Emitter<OrderState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final orders = await _repository.getOrders();
      emit(state.copyWith(isLoading: false, orders: orders));
    } on Failure catch (failure) {
      emit(state.copyWith(isLoading: false, errorMessage: failure.message));
    }
  }

  Future<void> _onOrderCreated(
    OrderCreated event,
    Emitter<OrderState> emit,
  ) async {
    emit(state.copyWith(isSaving: true, saveErrorMessage: null, saveSuccess: false));
    try {
      final order = await _repository.createOrder(event.order);
      emit(
        state.copyWith(
          isSaving: false,
          saveSuccess: true,
          orders: [...state.orders, order],
        ),
      );
    } on Failure catch (failure) {
      emit(
        state.copyWith(isSaving: false, saveErrorMessage: failure.message),
      );
    }
  }

  Future<void> _onOrderUpdated(
    OrderUpdated event,
    Emitter<OrderState> emit,
  ) async {
    emit(state.copyWith(isSaving: true, saveErrorMessage: null, saveSuccess: false));
    try {
      final order = await _repository.updateOrder(event.order);
      emit(
        state.copyWith(
          isSaving: false,
          saveSuccess: true,
          orders:
              state.orders.map((o) => o.id == order.id ? order : o).toList(),
        ),
      );
    } on Failure catch (failure) {
      emit(
        state.copyWith(isSaving: false, saveErrorMessage: failure.message),
      );
    }
  }

  Future<void> _onOrderDeleted(
    OrderDeleted event,
    Emitter<OrderState> emit,
  ) async {
    emit(state.copyWith(isSaving: true, saveErrorMessage: null, saveSuccess: false));
    try {
      await _repository.deleteOrder(event.id);
      emit(
        state.copyWith(
          isSaving: false,
          orders: state.orders.where((o) => o.id != event.id).toList(),
        ),
      );
    } on Failure catch (failure) {
      emit(
        state.copyWith(isSaving: false, saveErrorMessage: failure.message),
      );
    }
  }
}
