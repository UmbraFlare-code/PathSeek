part of 'order_bloc.dart';

class OrderState extends Equatable {
  const OrderState({
    this.orders = const [],
    this.isLoading = false,
    this.isSaving = false,
    this.saveSuccess = false,
    this.errorMessage,
    this.saveErrorMessage,
  });

  const OrderState.initial()
      : this();

  final List<Order> orders;
  final bool isLoading;
  final bool isSaving;
  final bool saveSuccess;
  final String? errorMessage;
  final String? saveErrorMessage;

  bool get hasError => errorMessage != null;
  bool get hasSaveError => saveErrorMessage != null;
  bool get isEmpty => orders.isEmpty && !isLoading;

  OrderState copyWith({
    List<Order>? orders,
    bool? isLoading,
    bool? isSaving,
    bool? saveSuccess,
    String? errorMessage,
    String? saveErrorMessage,
  }) {
    return OrderState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      saveSuccess: saveSuccess ?? this.saveSuccess,
      errorMessage: errorMessage,
      saveErrorMessage: saveErrorMessage,
    );
  }

  @override
  List<Object?> get props => [
        orders,
        isLoading,
        isSaving,
        saveSuccess,
        errorMessage,
        saveErrorMessage,
      ];
}
