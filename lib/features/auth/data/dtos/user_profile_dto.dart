import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/constants/finance_defaults.dart';
import '../../domain/entities/user_profile.dart';

part 'user_profile_dto.freezed.dart';
part 'user_profile_dto.g.dart';

@freezed
class UserProfileDto with _$UserProfileDto {
  const factory UserProfileDto({
    required String id,
    required String email,
    required String fullName,
    String? photoUrl,
    @Default(FinanceDefaults.defaultCurrencyCode) String currencyCode,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _UserProfileDto;

  const UserProfileDto._();

  factory UserProfileDto.fromJson(Map<String, dynamic> json) =>
      _$UserProfileDtoFromJson(json);

  factory UserProfileDto.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    return UserProfileDto(
      id: doc.id,
      email: data['email'] as String? ?? '',
      fullName: data['fullName'] as String? ?? '',
      photoUrl: data['photoUrl'] as String?,
      currencyCode:
          data['currencyCode'] as String? ??
          FinanceDefaults.defaultCurrencyCode,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  UserProfile toDomain() => UserProfile(
    id: id,
    email: email,
    fullName: fullName,
    photoUrl: photoUrl,
    currencyCode: currencyCode,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  Map<String, dynamic> toFirestore() => {
    'email': email,
    'fullName': fullName,
    'photoUrl': photoUrl,
    'currencyCode': currencyCode,
    'createdAt': createdAt == null ? null : Timestamp.fromDate(createdAt!),
    'updatedAt': updatedAt == null ? null : Timestamp.fromDate(updatedAt!),
  };

  factory UserProfileDto.fromDomain(UserProfile user) => UserProfileDto(
    id: user.id,
    email: user.email,
    fullName: user.fullName,
    photoUrl: user.photoUrl,
    currencyCode: user.currencyCode,
    createdAt: user.createdAt,
    updatedAt: user.updatedAt,
  );
}
