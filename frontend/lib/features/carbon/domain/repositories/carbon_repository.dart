import 'package:pathseek/features/carbon/domain/entities/carbon_plan.dart';

abstract class CarbonRepository {
  Future<CarbonPlan> getPlan();
}
