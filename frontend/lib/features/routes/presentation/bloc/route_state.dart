part of 'route_bloc.dart';

class RouteState extends Equatable {
  const RouteState({
    required this.isGenerating,
    this.plan,
    this.performance,
    this.errorMessage,
    this.lastNotice,
  });

  const RouteState.initial()
      : isGenerating = false,
        plan = null,
        performance = null,
        errorMessage = null,
        lastNotice = null;

  final bool isGenerating;
  final RoutePlan? plan;
  final RoutePerformance? performance;
  final String? errorMessage;
  final String? lastNotice;

  RouteState copyWith({
    bool? isGenerating,
    RoutePlan? plan,
    bool clearPlan = false,
    RoutePerformance? performance,
    String? errorMessage,
    String? lastNotice,
  }) {
    return RouteState(
      isGenerating: isGenerating ?? this.isGenerating,
      plan: clearPlan ? null : (plan ?? this.plan),
      performance: performance ?? this.performance,
      errorMessage: errorMessage,
      lastNotice: lastNotice,
    );
  }

  @override
  List<Object?> get props =>
      [isGenerating, plan, performance, errorMessage, lastNotice];
}
