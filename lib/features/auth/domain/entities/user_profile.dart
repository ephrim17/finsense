import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/constants/finance_defaults.dart';

part 'user_profile.freezed.dart';
part 'user_profile.g.dart';

@freezed
class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String id,
    required String email,
    required String fullName,
    String? photoUrl,
    @Default(FinanceDefaults.defaultCurrencyCode) String currencyCode,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
}
