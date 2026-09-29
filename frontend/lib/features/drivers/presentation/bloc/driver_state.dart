part of 'driver_bloc.dart';

class DriverState extends Equatable {
  const DriverState({
    this.drivers = const [],
    this.isLoading = false,
    this.isSaving = false,
    this.saveSuccess = false,
    this.errorMessage,
    this.saveErrorMessage,
  });

  const DriverState.initial()
      : this();

  final List<Driver> drivers;
  final bool isLoading;
  final bool isSaving;
  final bool saveSuccess;
  final String? errorMessage;
  final String? saveErrorMessage;

  bool get hasError => errorMessage != null;
  bool get hasSaveError => saveErrorMessage != null;
  bool get isEmpty => drivers.isEmpty && !isLoading;

  DriverState copyWith({
    List<Driver>? drivers,
    bool? isLoading,
    bool? isSaving,
    bool? saveSuccess,
    String? errorMessage,
    String? saveErrorMessage,
  }) {
    return DriverState(
      drivers: drivers ?? this.drivers,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      saveSuccess: saveSuccess ?? this.saveSuccess,
      errorMessage: errorMessage,
      saveErrorMessage: saveErrorMessage,
    );
  }

  @override
  List<Object?> get props => [
        drivers,
        isLoading,
        isSaving,
        saveSuccess,
        errorMessage,
        saveErrorMessage,
      ];
}
