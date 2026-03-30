// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'savings_goal_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SavingsGoalDto _$SavingsGoalDtoFromJson(Map<String, dynamic> json) {
  return _SavingsGoalDto.fromJson(json);
}

/// @nodoc
mixin _$SavingsGoalDto {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  double get targetAmount => throw _privateConstructorUsedError;
  double get currentAmount => throw _privateConstructorUsedError;
  String get icon => throw _privateConstructorUsedError;
  String get color => throw _privateConstructorUsedError;
  DateTime? get deadline => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this SavingsGoalDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SavingsGoalDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SavingsGoalDtoCopyWith<SavingsGoalDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SavingsGoalDtoCopyWith<$Res> {
  factory $SavingsGoalDtoCopyWith(
    SavingsGoalDto value,
    $Res Function(SavingsGoalDto) then,
  ) = _$SavingsGoalDtoCopyWithImpl<$Res, SavingsGoalDto>;
  @useResult
  $Res call({
    String id,
    String userId,
    String title,
    double targetAmount,
    double currentAmount,
    String icon,
    String color,
    DateTime? deadline,
    DateTime createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class _$SavingsGoalDtoCopyWithImpl<$Res, $Val extends SavingsGoalDto>
    implements $SavingsGoalDtoCopyWith<$Res> {
  _$SavingsGoalDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SavingsGoalDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? title = null,
    Object? targetAmount = null,
    Object? currentAmount = null,
    Object? icon = null,
    Object? color = null,
    Object? deadline = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            targetAmount: null == targetAmount
                ? _value.targetAmount
                : targetAmount // ignore: cast_nullable_to_non_nullable
                      as double,
            currentAmount: null == currentAmount
                ? _value.currentAmount
                : currentAmount // ignore: cast_nullable_to_non_nullable
                      as double,
            icon: null == icon
                ? _value.icon
                : icon // ignore: cast_nullable_to_non_nullable
                      as String,
            color: null == color
                ? _value.color
                : color // ignore: cast_nullable_to_non_nullable
                      as String,
            deadline: freezed == deadline
                ? _value.deadline
                : deadline // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SavingsGoalDtoImplCopyWith<$Res>
    implements $SavingsGoalDtoCopyWith<$Res> {
  factory _$$SavingsGoalDtoImplCopyWith(
    _$SavingsGoalDtoImpl value,
    $Res Function(_$SavingsGoalDtoImpl) then,
  ) = __$$SavingsGoalDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String userId,
    String title,
    double targetAmount,
    double currentAmount,
    String icon,
    String color,
    DateTime? deadline,
    DateTime createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class __$$SavingsGoalDtoImplCopyWithImpl<$Res>
    extends _$SavingsGoalDtoCopyWithImpl<$Res, _$SavingsGoalDtoImpl>
    implements _$$SavingsGoalDtoImplCopyWith<$Res> {
  __$$SavingsGoalDtoImplCopyWithImpl(
    _$SavingsGoalDtoImpl _value,
    $Res Function(_$SavingsGoalDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SavingsGoalDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? title = null,
    Object? targetAmount = null,
    Object? currentAmount = null,
    Object? icon = null,
    Object? color = null,
    Object? deadline = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$SavingsGoalDtoImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        targetAmount: null == targetAmount
            ? _value.targetAmount
            : targetAmount // ignore: cast_nullable_to_non_nullable
                  as double,
        currentAmount: null == currentAmount
            ? _value.currentAmount
            : currentAmount // ignore: cast_nullable_to_non_nullable
                  as double,
        icon: null == icon
            ? _value.icon
            : icon // ignore: cast_nullable_to_non_nullable
                  as String,
        color: null == color
            ? _value.color
            : color // ignore: cast_nullable_to_non_nullable
                  as String,
        deadline: freezed == deadline
            ? _value.deadline
            : deadline // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SavingsGoalDtoImpl extends _SavingsGoalDto {
  const _$SavingsGoalDtoImpl({
    required this.id,
    required this.userId,
    required this.title,
    required this.targetAmount,
    required this.currentAmount,
    required this.icon,
    required this.color,
    this.deadline,
    required this.createdAt,
    this.updatedAt,
  }) : super._();

  factory _$SavingsGoalDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$SavingsGoalDtoImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String title;
  @override
  final double targetAmount;
  @override
  final double currentAmount;
  @override
  final String icon;
  @override
  final String color;
  @override
  final DateTime? deadline;
  @override
  final DateTime createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'SavingsGoalDto(id: $id, userId: $userId, title: $title, targetAmount: $targetAmount, currentAmount: $currentAmount, icon: $icon, color: $color, deadline: $deadline, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SavingsGoalDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.targetAmount, targetAmount) ||
                other.targetAmount == targetAmount) &&
            (identical(other.currentAmount, currentAmount) ||
                other.currentAmount == currentAmount) &&
            (identical(other.icon, icon) || other.icon == icon) &&
            (identical(other.color, color) || other.color == color) &&
            (identical(other.deadline, deadline) ||
                other.deadline == deadline) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    title,
    targetAmount,
    currentAmount,
    icon,
    color,
    deadline,
    createdAt,
    updatedAt,
  );

  /// Create a copy of SavingsGoalDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SavingsGoalDtoImplCopyWith<_$SavingsGoalDtoImpl> get copyWith =>
      __$$SavingsGoalDtoImplCopyWithImpl<_$SavingsGoalDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SavingsGoalDtoImplToJson(this);
  }
}

abstract class _SavingsGoalDto extends SavingsGoalDto {
  const factory _SavingsGoalDto({
    required final String id,
    required final String userId,
    required final String title,
    required final double targetAmount,
    required final double currentAmount,
    required final String icon,
    required final String color,
    final DateTime? deadline,
    required final DateTime createdAt,
    final DateTime? updatedAt,
  }) = _$SavingsGoalDtoImpl;
  const _SavingsGoalDto._() : super._();

  factory _SavingsGoalDto.fromJson(Map<String, dynamic> json) =
      _$SavingsGoalDtoImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get title;
  @override
  double get targetAmount;
  @override
  double get currentAmount;
  @override
  String get icon;
  @override
  String get color;
  @override
  DateTime? get deadline;
  @override
  DateTime get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of SavingsGoalDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SavingsGoalDtoImplCopyWith<_$SavingsGoalDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
