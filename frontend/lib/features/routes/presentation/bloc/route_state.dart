part of 'route_bloc.dart';

class RouteState extends Equatable {
  const RouteState({
    this.routes = const [],
    this.selectedRoute,
    this.isLoading = false,
    this.isGenerating = false,
    this.isSaving = false,
    this.generateSuccess = false,
    this.generatedRoutes = 0,
    this.unassignedOrders = 0,
    this.errorMessage,
    this.generateErrorMessage,
    this.saveErrorMessage,
    this.isDetailLoading = false,
    this.detailError,
    this.isReoptimizing = false,
    this.reoptimizeSuccess = false,
    this.reoptimizeErrorMessage,
  });

  const RouteState.initial()
      : this();

  final List<DeliveryRoute> routes;
  final DeliveryRoute? selectedRoute;
  final bool isLoading;
  final bool isGenerating;
  final bool isSaving;
  final bool generateSuccess;
  final int generatedRoutes;
  final int unassignedOrders;
  final String? errorMessage;
  final String? generateErrorMessage;
  final String? saveErrorMessage;
  final bool isDetailLoading;
  final String? detailError;
  final bool isReoptimizing;
  final bool reoptimizeSuccess;
  final String? reoptimizeErrorMessage;

  bool get hasError => errorMessage != null;
  bool get hasGenerateError => generateErrorMessage != null;
  bool get hasSaveError => saveErrorMessage != null;
  bool get hasDetailError => detailError != null;
  bool get hasReoptimizeError => reoptimizeErrorMessage != null;
  bool get isEmpty => routes.isEmpty && !isLoading;

  RouteState copyWith({
    List<DeliveryRoute>? routes,
    DeliveryRoute? selectedRoute,
    bool? isLoading,
    bool? isGenerating,
    bool? isSaving,
    bool? generateSuccess,
    int? generatedRoutes,
    int? unassignedOrders,
    String? errorMessage,
    String? generateErrorMessage,
    String? saveErrorMessage,
    bool? isDetailLoading,
    String? detailError,
    bool? isReoptimizing,
    bool? reoptimizeSuccess,
    String? reoptimizeErrorMessage,
  }) {
    return RouteState(
      routes: routes ?? this.routes,
      selectedRoute: selectedRoute ?? this.selectedRoute,
      isLoading: isLoading ?? this.isLoading,
      isGenerating: isGenerating ?? this.isGenerating,
      isSaving: isSaving ?? this.isSaving,
      generateSuccess: generateSuccess ?? this.generateSuccess,
      generatedRoutes: generatedRoutes ?? this.generatedRoutes,
      unassignedOrders: unassignedOrders ?? this.unassignedOrders,
      errorMessage: errorMessage,
      generateErrorMessage: generateErrorMessage,
      saveErrorMessage: saveErrorMessage,
      isDetailLoading: isDetailLoading ?? this.isDetailLoading,
      detailError: detailError,
      isReoptimizing: isReoptimizing ?? this.isReoptimizing,
      reoptimizeSuccess: reoptimizeSuccess ?? this.reoptimizeSuccess,
      reoptimizeErrorMessage: reoptimizeErrorMessage,
    );
  }

  @override
  List<Object?> get props => [
        routes,
        selectedRoute,
        isLoading,
        isGenerating,
        isSaving,
        generateSuccess,
        generatedRoutes,
        unassignedOrders,
        errorMessage,
        generateErrorMessage,
        saveErrorMessage,
        isDetailLoading,
        detailError,
        isReoptimizing,
        reoptimizeSuccess,
        reoptimizeErrorMessage,
      ];
}
