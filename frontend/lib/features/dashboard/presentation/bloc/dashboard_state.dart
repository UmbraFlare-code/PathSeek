part of 'dashboard_bloc.dart';

class DashboardState extends Equatable {
  const DashboardState({
    this.summary,
    this.isLoading = false,
    this.errorMessage,
  });

  const DashboardState.initial()
      : this();

  final DashboardSummary? summary;
  final bool isLoading;
  final String? errorMessage;

  bool get hasError => errorMessage != null;

  DashboardState copyWith({
    DashboardSummary? summary,
    bool? isLoading,
    String? errorMessage,
  }) {
    return DashboardState(
      summary: summary ?? this.summary,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [summary, isLoading, errorMessage];
}
