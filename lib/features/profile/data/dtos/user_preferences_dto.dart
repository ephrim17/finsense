import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/constants/finance_defaults.dart';
import '../../domain/entities/user_preferences.dart';

part 'user_preferences_dto.freezed.dart';
part 'user_preferences_dto.g.dart';

@freezed
class UserPreferencesDto with _$UserPreferencesDto {
  const factory UserPreferencesDto({
    @Default(FinanceDefaults.defaultCurrencyCode) String currencyCode,
    @Default(true) bool notificationsEnabled,
    @Default(false) bool smartInsightsEnabled,
    @Default(false) bool biometricEnabled,
  }) = _UserPreferencesDto;

  const UserPreferencesDto._();

  factory UserPreferencesDto.fromJson(Map<String, dynamic> json) =>
      _$UserPreferencesDtoFromJson(json);

  UserPreferences toDomain() => UserPreferences(
    currencyCode: currencyCode,
    notificationsEnabled: notificationsEnabled,
    smartInsightsEnabled: smartInsightsEnabled,
    biometricEnabled: biometricEnabled,
  );

  factory UserPreferencesDto.fromDomain(UserPreferences preferences) =>
      UserPreferencesDto(
        currencyCode: preferences.currencyCode,
        notificationsEnabled: preferences.notificationsEnabled,
        smartInsightsEnabled: preferences.smartInsightsEnabled,
        biometricEnabled: preferences.biometricEnabled,
      );
}
