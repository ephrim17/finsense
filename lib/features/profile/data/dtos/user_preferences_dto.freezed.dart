// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_preferences_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

UserPreferencesDto _$UserPreferencesDtoFromJson(Map<String, dynamic> json) {
  return _UserPreferencesDto.fromJson(json);
}

/// @nodoc
mixin _$UserPreferencesDto {
  String get currencyCode => throw _privateConstructorUsedError;
  bool get notificationsEnabled => throw _privateConstructorUsedError;
  bool get smartInsightsEnabled => throw _privateConstructorUsedError;
  bool get biometricEnabled => throw _privateConstructorUsedError;

  /// Serializes this UserPreferencesDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserPreferencesDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserPreferencesDtoCopyWith<UserPreferencesDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserPreferencesDtoCopyWith<$Res> {
  factory $UserPreferencesDtoCopyWith(
    UserPreferencesDto value,
    $Res Function(UserPreferencesDto) then,
  ) = _$UserPreferencesDtoCopyWithImpl<$Res, UserPreferencesDto>;
  @useResult
  $Res call({
    String currencyCode,
    bool notificationsEnabled,
    bool smartInsightsEnabled,
    bool biometricEnabled,
  });
}

/// @nodoc
class _$UserPreferencesDtoCopyWithImpl<$Res, $Val extends UserPreferencesDto>
    implements $UserPreferencesDtoCopyWith<$Res> {
  _$UserPreferencesDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserPreferencesDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currencyCode = null,
    Object? notificationsEnabled = null,
    Object? smartInsightsEnabled = null,
    Object? biometricEnabled = null,
  }) {
    return _then(
      _value.copyWith(
            currencyCode: null == currencyCode
                ? _value.currencyCode
                : currencyCode // ignore: cast_nullable_to_non_nullable
                      as String,
            notificationsEnabled: null == notificationsEnabled
                ? _value.notificationsEnabled
                : notificationsEnabled // ignore: cast_nullable_to_non_nullable
                      as bool,
            smartInsightsEnabled: null == smartInsightsEnabled
                ? _value.smartInsightsEnabled
                : smartInsightsEnabled // ignore: cast_nullable_to_non_nullable
                      as bool,
            biometricEnabled: null == biometricEnabled
                ? _value.biometricEnabled
                : biometricEnabled // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserPreferencesDtoImplCopyWith<$Res>
    implements $UserPreferencesDtoCopyWith<$Res> {
  factory _$$UserPreferencesDtoImplCopyWith(
    _$UserPreferencesDtoImpl value,
    $Res Function(_$UserPreferencesDtoImpl) then,
  ) = __$$UserPreferencesDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String currencyCode,
    bool notificationsEnabled,
    bool smartInsightsEnabled,
    bool biometricEnabled,
  });
}

/// @nodoc
class __$$UserPreferencesDtoImplCopyWithImpl<$Res>
    extends _$UserPreferencesDtoCopyWithImpl<$Res, _$UserPreferencesDtoImpl>
    implements _$$UserPreferencesDtoImplCopyWith<$Res> {
  __$$UserPreferencesDtoImplCopyWithImpl(
    _$UserPreferencesDtoImpl _value,
    $Res Function(_$UserPreferencesDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserPreferencesDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currencyCode = null,
    Object? notificationsEnabled = null,
    Object? smartInsightsEnabled = null,
    Object? biometricEnabled = null,
  }) {
    return _then(
      _$UserPreferencesDtoImpl(
        currencyCode: null == currencyCode
            ? _value.currencyCode
            : currencyCode // ignore: cast_nullable_to_non_nullable
                  as String,
        notificationsEnabled: null == notificationsEnabled
            ? _value.notificationsEnabled
            : notificationsEnabled // ignore: cast_nullable_to_non_nullable
                  as bool,
        smartInsightsEnabled: null == smartInsightsEnabled
            ? _value.smartInsightsEnabled
            : smartInsightsEnabled // ignore: cast_nullable_to_non_nullable
                  as bool,
        biometricEnabled: null == biometricEnabled
            ? _value.biometricEnabled
            : biometricEnabled // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserPreferencesDtoImpl extends _UserPreferencesDto {
  const _$UserPreferencesDtoImpl({
    this.currencyCode = FinanceDefaults.defaultCurrencyCode,
    this.notificationsEnabled = true,
    this.smartInsightsEnabled = false,
    this.biometricEnabled = false,
  }) : super._();

  factory _$UserPreferencesDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserPreferencesDtoImplFromJson(json);

  @override
  @JsonKey()
  final String currencyCode;
  @override
  @JsonKey()
  final bool notificationsEnabled;
  @override
  @JsonKey()
  final bool smartInsightsEnabled;
  @override
  @JsonKey()
  final bool biometricEnabled;

  @override
  String toString() {
    return 'UserPreferencesDto(currencyCode: $currencyCode, notificationsEnabled: $notificationsEnabled, smartInsightsEnabled: $smartInsightsEnabled, biometricEnabled: $biometricEnabled)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserPreferencesDtoImpl &&
            (identical(other.currencyCode, currencyCode) ||
                other.currencyCode == currencyCode) &&
            (identical(other.notificationsEnabled, notificationsEnabled) ||
                other.notificationsEnabled == notificationsEnabled) &&
            (identical(other.smartInsightsEnabled, smartInsightsEnabled) ||
                other.smartInsightsEnabled == smartInsightsEnabled) &&
            (identical(other.biometricEnabled, biometricEnabled) ||
                other.biometricEnabled == biometricEnabled));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    currencyCode,
    notificationsEnabled,
    smartInsightsEnabled,
    biometricEnabled,
  );

  /// Create a copy of UserPreferencesDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserPreferencesDtoImplCopyWith<_$UserPreferencesDtoImpl> get copyWith =>
      __$$UserPreferencesDtoImplCopyWithImpl<_$UserPreferencesDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$UserPreferencesDtoImplToJson(this);
  }
}

abstract class _UserPreferencesDto extends UserPreferencesDto {
  const factory _UserPreferencesDto({
    final String currencyCode,
    final bool notificationsEnabled,
    final bool smartInsightsEnabled,
    final bool biometricEnabled,
  }) = _$UserPreferencesDtoImpl;
  const _UserPreferencesDto._() : super._();

  factory _UserPreferencesDto.fromJson(Map<String, dynamic> json) =
      _$UserPreferencesDtoImpl.fromJson;

  @override
  String get currencyCode;
  @override
  bool get notificationsEnabled;
  @override
  bool get smartInsightsEnabled;
  @override
  bool get biometricEnabled;

  /// Create a copy of UserPreferencesDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserPreferencesDtoImplCopyWith<_$UserPreferencesDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
