// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_preferences.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserPreferencesImpl _$$UserPreferencesImplFromJson(
  Map<String, dynamic> json,
) => _$UserPreferencesImpl(
  currencyCode:
      json['currencyCode'] as String? ?? FinanceDefaults.defaultCurrencyCode,
  notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
  smartInsightsEnabled: json['smartInsightsEnabled'] as bool? ?? false,
  biometricEnabled: json['biometricEnabled'] as bool? ?? false,
);

Map<String, dynamic> _$$UserPreferencesImplToJson(
  _$UserPreferencesImpl instance,
) => <String, dynamic>{
  'currencyCode': instance.currencyCode,
  'notificationsEnabled': instance.notificationsEnabled,
  'smartInsightsEnabled': instance.smartInsightsEnabled,
  'biometricEnabled': instance.biometricEnabled,
};
