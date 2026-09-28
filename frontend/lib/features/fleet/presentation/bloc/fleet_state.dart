part of 'fleet_bloc.dart';

class FleetState extends Equatable {
  const FleetState({
    this.vehicles = const [],
    this.isLoading = false,
    this.isSaving = false,
    this.saveSuccess = false,
    this.errorMessage,
    this.saveErrorMessage,
  });

  const FleetState.initial()
      : this();

  final List<Vehicle> vehicles;
  final bool isLoading;
  final bool isSaving;
  final bool saveSuccess;
  final String? errorMessage;
  final String? saveErrorMessage;

  bool get hasError => errorMessage != null;
  bool get hasSaveError => saveErrorMessage != null;
  bool get isEmpty => vehicles.isEmpty && !isLoading;

  FleetState copyWith({
    List<Vehicle>? vehicles,
    bool? isLoading,
    bool? isSaving,
    bool? saveSuccess,
    String? errorMessage,
    String? saveErrorMessage,
  }) {
    return FleetState(
      vehicles: vehicles ?? this.vehicles,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      saveSuccess: saveSuccess ?? this.saveSuccess,
      errorMessage: errorMessage,
      saveErrorMessage: saveErrorMessage,
    );
  }

  @override
  List<Object?> get props => [
        vehicles,
        isLoading,
        isSaving,
        saveSuccess,
        errorMessage,
        saveErrorMessage,
      ];
}
