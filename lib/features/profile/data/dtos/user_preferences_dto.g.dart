// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_preferences_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserPreferencesDtoImpl _$$UserPreferencesDtoImplFromJson(
  Map<String, dynamic> json,
) => _$UserPreferencesDtoImpl(
  currencyCode:
      json['currencyCode'] as String? ?? FinanceDefaults.defaultCurrencyCode,
  notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
  smartInsightsEnabled: json['smartInsightsEnabled'] as bool? ?? false,
  biometricEnabled: json['biometricEnabled'] as bool? ?? false,
);

Map<String, dynamic> _$$UserPreferencesDtoImplToJson(
  _$UserPreferencesDtoImpl instance,
) => <String, dynamic>{
  'currencyCode': instance.currencyCode,
  'notificationsEnabled': instance.notificationsEnabled,
  'smartInsightsEnabled': instance.smartInsightsEnabled,
  'biometricEnabled': instance.biometricEnabled,
};
