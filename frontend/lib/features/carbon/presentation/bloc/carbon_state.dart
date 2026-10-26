part of 'carbon_bloc.dart';

class CarbonState extends Equatable {
  const CarbonState({
    this.plan,
    this.isLoading = false,
    this.errorMessage,
  });

  const CarbonState.initial() : this();

  final CarbonPlan? plan;
  final bool isLoading;
  final String? errorMessage;

  CarbonState copyWith({
    CarbonPlan? plan,
    bool? isLoading,
    String? errorMessage,
  }) {
    return CarbonState(
      plan: plan ?? this.plan,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [plan, isLoading, errorMessage];
}
