// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'budget_plan.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

BudgetPlan _$BudgetPlanFromJson(Map<String, dynamic> json) {
  return _BudgetPlan.fromJson(json);
}

/// @nodoc
mixin _$BudgetPlan {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get categoryName => throw _privateConstructorUsedError;
  double get limitAmount => throw _privateConstructorUsedError;
  double get spentAmount => throw _privateConstructorUsedError;
  BudgetPeriodType get periodType => throw _privateConstructorUsedError;
  String get monthKey => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this BudgetPlan to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BudgetPlan
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BudgetPlanCopyWith<BudgetPlan> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BudgetPlanCopyWith<$Res> {
  factory $BudgetPlanCopyWith(
    BudgetPlan value,
    $Res Function(BudgetPlan) then,
  ) = _$BudgetPlanCopyWithImpl<$Res, BudgetPlan>;
  @useResult
  $Res call({
    String id,
    String userId,
    String categoryName,
    double limitAmount,
    double spentAmount,
    BudgetPeriodType periodType,
    String monthKey,
    DateTime createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class _$BudgetPlanCopyWithImpl<$Res, $Val extends BudgetPlan>
    implements $BudgetPlanCopyWith<$Res> {
  _$BudgetPlanCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BudgetPlan
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? categoryName = null,
    Object? limitAmount = null,
    Object? spentAmount = null,
    Object? periodType = null,
    Object? monthKey = null,
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
            categoryName: null == categoryName
                ? _value.categoryName
                : categoryName // ignore: cast_nullable_to_non_nullable
                      as String,
            limitAmount: null == limitAmount
                ? _value.limitAmount
                : limitAmount // ignore: cast_nullable_to_non_nullable
                      as double,
            spentAmount: null == spentAmount
                ? _value.spentAmount
                : spentAmount // ignore: cast_nullable_to_non_nullable
                      as double,
            periodType: null == periodType
                ? _value.periodType
                : periodType // ignore: cast_nullable_to_non_nullable
                      as BudgetPeriodType,
            monthKey: null == monthKey
                ? _value.monthKey
                : monthKey // ignore: cast_nullable_to_non_nullable
                      as String,
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
abstract class _$$BudgetPlanImplCopyWith<$Res>
    implements $BudgetPlanCopyWith<$Res> {
  factory _$$BudgetPlanImplCopyWith(
    _$BudgetPlanImpl value,
    $Res Function(_$BudgetPlanImpl) then,
  ) = __$$BudgetPlanImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String userId,
    String categoryName,
    double limitAmount,
    double spentAmount,
    BudgetPeriodType periodType,
    String monthKey,
    DateTime createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class __$$BudgetPlanImplCopyWithImpl<$Res>
    extends _$BudgetPlanCopyWithImpl<$Res, _$BudgetPlanImpl>
    implements _$$BudgetPlanImplCopyWith<$Res> {
  __$$BudgetPlanImplCopyWithImpl(
    _$BudgetPlanImpl _value,
    $Res Function(_$BudgetPlanImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BudgetPlan
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? categoryName = null,
    Object? limitAmount = null,
    Object? spentAmount = null,
    Object? periodType = null,
    Object? monthKey = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$BudgetPlanImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        categoryName: null == categoryName
            ? _value.categoryName
            : categoryName // ignore: cast_nullable_to_non_nullable
                  as String,
        limitAmount: null == limitAmount
            ? _value.limitAmount
            : limitAmount // ignore: cast_nullable_to_non_nullable
                  as double,
        spentAmount: null == spentAmount
            ? _value.spentAmount
            : spentAmount // ignore: cast_nullable_to_non_nullable
                  as double,
        periodType: null == periodType
            ? _value.periodType
            : periodType // ignore: cast_nullable_to_non_nullable
                  as BudgetPeriodType,
        monthKey: null == monthKey
            ? _value.monthKey
            : monthKey // ignore: cast_nullable_to_non_nullable
                  as String,
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
class _$BudgetPlanImpl extends _BudgetPlan {
  const _$BudgetPlanImpl({
    required this.id,
    required this.userId,
    required this.categoryName,
    required this.limitAmount,
    required this.spentAmount,
    this.periodType = BudgetPeriodType.monthly,
    required this.monthKey,
    required this.createdAt,
    this.updatedAt,
  }) : super._();

  factory _$BudgetPlanImpl.fromJson(Map<String, dynamic> json) =>
      _$$BudgetPlanImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String categoryName;
  @override
  final double limitAmount;
  @override
  final double spentAmount;
  @override
  @JsonKey()
  final BudgetPeriodType periodType;
  @override
  final String monthKey;
  @override
  final DateTime createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'BudgetPlan(id: $id, userId: $userId, categoryName: $categoryName, limitAmount: $limitAmount, spentAmount: $spentAmount, periodType: $periodType, monthKey: $monthKey, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BudgetPlanImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.categoryName, categoryName) ||
                other.categoryName == categoryName) &&
            (identical(other.limitAmount, limitAmount) ||
                other.limitAmount == limitAmount) &&
            (identical(other.spentAmount, spentAmount) ||
                other.spentAmount == spentAmount) &&
            (identical(other.periodType, periodType) ||
                other.periodType == periodType) &&
            (identical(other.monthKey, monthKey) ||
                other.monthKey == monthKey) &&
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
    categoryName,
    limitAmount,
    spentAmount,
    periodType,
    monthKey,
    createdAt,
    updatedAt,
  );

  /// Create a copy of BudgetPlan
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BudgetPlanImplCopyWith<_$BudgetPlanImpl> get copyWith =>
      __$$BudgetPlanImplCopyWithImpl<_$BudgetPlanImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BudgetPlanImplToJson(this);
  }
}

abstract class _BudgetPlan extends BudgetPlan {
  const factory _BudgetPlan({
    required final String id,
    required final String userId,
    required final String categoryName,
    required final double limitAmount,
    required final double spentAmount,
    final BudgetPeriodType periodType,
    required final String monthKey,
    required final DateTime createdAt,
    final DateTime? updatedAt,
  }) = _$BudgetPlanImpl;
  const _BudgetPlan._() : super._();

  factory _BudgetPlan.fromJson(Map<String, dynamic> json) =
      _$BudgetPlanImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get categoryName;
  @override
  double get limitAmount;
  @override
  double get spentAmount;
  @override
  BudgetPeriodType get periodType;
  @override
  String get monthKey;
  @override
  DateTime get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of BudgetPlan
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BudgetPlanImplCopyWith<_$BudgetPlanImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
