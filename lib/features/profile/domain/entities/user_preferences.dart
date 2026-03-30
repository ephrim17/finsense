import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/constants/finance_defaults.dart';

part 'user_preferences.freezed.dart';
part 'user_preferences.g.dart';

@freezed
class UserPreferences with _$UserPreferences {
  const factory UserPreferences({
    @Default(FinanceDefaults.defaultCurrencyCode) String currencyCode,
    @Default(true) bool notificationsEnabled,
    @Default(false) bool smartInsightsEnabled,
    @Default(false) bool biometricEnabled,
  }) = _UserPreferences;

  factory UserPreferences.fromJson(Map<String, dynamic> json) =>
      _$UserPreferencesFromJson(json);
}
