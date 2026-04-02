import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/financial_insights_service.dart';

final financialInsightsServiceProvider = Provider<FinancialInsightsService>((
  ref,
) {
  return const FinancialInsightsService();
});
