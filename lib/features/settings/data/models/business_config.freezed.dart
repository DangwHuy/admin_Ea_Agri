// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'business_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

BusinessConfig _$BusinessConfigFromJson(Map<String, dynamic> json) {
  return _BusinessConfig.fromJson(json);
}

/// @nodoc
mixin _$BusinessConfig {
  OrderConfig get orders => throw _privateConstructorUsedError;
  ProductConfig get products => throw _privateConstructorUsedError;
  ExpertConfig get experts => throw _privateConstructorUsedError;
  PromotionConfig get promotions => throw _privateConstructorUsedError;

  /// Serializes this BusinessConfig to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BusinessConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BusinessConfigCopyWith<BusinessConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BusinessConfigCopyWith<$Res> {
  factory $BusinessConfigCopyWith(
    BusinessConfig value,
    $Res Function(BusinessConfig) then,
  ) = _$BusinessConfigCopyWithImpl<$Res, BusinessConfig>;
  @useResult
  $Res call({
    OrderConfig orders,
    ProductConfig products,
    ExpertConfig experts,
    PromotionConfig promotions,
  });

  $OrderConfigCopyWith<$Res> get orders;
  $ProductConfigCopyWith<$Res> get products;
  $ExpertConfigCopyWith<$Res> get experts;
  $PromotionConfigCopyWith<$Res> get promotions;
}

/// @nodoc
class _$BusinessConfigCopyWithImpl<$Res, $Val extends BusinessConfig>
    implements $BusinessConfigCopyWith<$Res> {
  _$BusinessConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BusinessConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? orders = null,
    Object? products = null,
    Object? experts = null,
    Object? promotions = null,
  }) {
    return _then(
      _value.copyWith(
            orders: null == orders
                ? _value.orders
                : orders // ignore: cast_nullable_to_non_nullable
                      as OrderConfig,
            products: null == products
                ? _value.products
                : products // ignore: cast_nullable_to_non_nullable
                      as ProductConfig,
            experts: null == experts
                ? _value.experts
                : experts // ignore: cast_nullable_to_non_nullable
                      as ExpertConfig,
            promotions: null == promotions
                ? _value.promotions
                : promotions // ignore: cast_nullable_to_non_nullable
                      as PromotionConfig,
          )
          as $Val,
    );
  }

  /// Create a copy of BusinessConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $OrderConfigCopyWith<$Res> get orders {
    return $OrderConfigCopyWith<$Res>(_value.orders, (value) {
      return _then(_value.copyWith(orders: value) as $Val);
    });
  }

  /// Create a copy of BusinessConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ProductConfigCopyWith<$Res> get products {
    return $ProductConfigCopyWith<$Res>(_value.products, (value) {
      return _then(_value.copyWith(products: value) as $Val);
    });
  }

  /// Create a copy of BusinessConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ExpertConfigCopyWith<$Res> get experts {
    return $ExpertConfigCopyWith<$Res>(_value.experts, (value) {
      return _then(_value.copyWith(experts: value) as $Val);
    });
  }

  /// Create a copy of BusinessConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PromotionConfigCopyWith<$Res> get promotions {
    return $PromotionConfigCopyWith<$Res>(_value.promotions, (value) {
      return _then(_value.copyWith(promotions: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$BusinessConfigImplCopyWith<$Res>
    implements $BusinessConfigCopyWith<$Res> {
  factory _$$BusinessConfigImplCopyWith(
    _$BusinessConfigImpl value,
    $Res Function(_$BusinessConfigImpl) then,
  ) = __$$BusinessConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    OrderConfig orders,
    ProductConfig products,
    ExpertConfig experts,
    PromotionConfig promotions,
  });

  @override
  $OrderConfigCopyWith<$Res> get orders;
  @override
  $ProductConfigCopyWith<$Res> get products;
  @override
  $ExpertConfigCopyWith<$Res> get experts;
  @override
  $PromotionConfigCopyWith<$Res> get promotions;
}

/// @nodoc
class __$$BusinessConfigImplCopyWithImpl<$Res>
    extends _$BusinessConfigCopyWithImpl<$Res, _$BusinessConfigImpl>
    implements _$$BusinessConfigImplCopyWith<$Res> {
  __$$BusinessConfigImplCopyWithImpl(
    _$BusinessConfigImpl _value,
    $Res Function(_$BusinessConfigImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BusinessConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? orders = null,
    Object? products = null,
    Object? experts = null,
    Object? promotions = null,
  }) {
    return _then(
      _$BusinessConfigImpl(
        orders: null == orders
            ? _value.orders
            : orders // ignore: cast_nullable_to_non_nullable
                  as OrderConfig,
        products: null == products
            ? _value.products
            : products // ignore: cast_nullable_to_non_nullable
                  as ProductConfig,
        experts: null == experts
            ? _value.experts
            : experts // ignore: cast_nullable_to_non_nullable
                  as ExpertConfig,
        promotions: null == promotions
            ? _value.promotions
            : promotions // ignore: cast_nullable_to_non_nullable
                  as PromotionConfig,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BusinessConfigImpl implements _BusinessConfig {
  const _$BusinessConfigImpl({
    this.orders = const OrderConfig(),
    this.products = const ProductConfig(),
    this.experts = const ExpertConfig(),
    this.promotions = const PromotionConfig(),
  });

  factory _$BusinessConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$BusinessConfigImplFromJson(json);

  @override
  @JsonKey()
  final OrderConfig orders;
  @override
  @JsonKey()
  final ProductConfig products;
  @override
  @JsonKey()
  final ExpertConfig experts;
  @override
  @JsonKey()
  final PromotionConfig promotions;

  @override
  String toString() {
    return 'BusinessConfig(orders: $orders, products: $products, experts: $experts, promotions: $promotions)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BusinessConfigImpl &&
            (identical(other.orders, orders) || other.orders == orders) &&
            (identical(other.products, products) ||
                other.products == products) &&
            (identical(other.experts, experts) || other.experts == experts) &&
            (identical(other.promotions, promotions) ||
                other.promotions == promotions));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, orders, products, experts, promotions);

  /// Create a copy of BusinessConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BusinessConfigImplCopyWith<_$BusinessConfigImpl> get copyWith =>
      __$$BusinessConfigImplCopyWithImpl<_$BusinessConfigImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$BusinessConfigImplToJson(this);
  }
}

abstract class _BusinessConfig implements BusinessConfig {
  const factory _BusinessConfig({
    final OrderConfig orders,
    final ProductConfig products,
    final ExpertConfig experts,
    final PromotionConfig promotions,
  }) = _$BusinessConfigImpl;

  factory _BusinessConfig.fromJson(Map<String, dynamic> json) =
      _$BusinessConfigImpl.fromJson;

  @override
  OrderConfig get orders;
  @override
  ProductConfig get products;
  @override
  ExpertConfig get experts;
  @override
  PromotionConfig get promotions;

  /// Create a copy of BusinessConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BusinessConfigImplCopyWith<_$BusinessConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

OrderConfig _$OrderConfigFromJson(Map<String, dynamic> json) {
  return _OrderConfig.fromJson(json);
}

/// @nodoc
mixin _$OrderConfig {
  double get vatPercent => throw _privateConstructorUsedError;
  double get shippingFeeFlat => throw _privateConstructorUsedError;
  int get autoCancelHours => throw _privateConstructorUsedError;
  List<String> get enabledPaymentMethods => throw _privateConstructorUsedError;

  /// Serializes this OrderConfig to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OrderConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OrderConfigCopyWith<OrderConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrderConfigCopyWith<$Res> {
  factory $OrderConfigCopyWith(
    OrderConfig value,
    $Res Function(OrderConfig) then,
  ) = _$OrderConfigCopyWithImpl<$Res, OrderConfig>;
  @useResult
  $Res call({
    double vatPercent,
    double shippingFeeFlat,
    int autoCancelHours,
    List<String> enabledPaymentMethods,
  });
}

/// @nodoc
class _$OrderConfigCopyWithImpl<$Res, $Val extends OrderConfig>
    implements $OrderConfigCopyWith<$Res> {
  _$OrderConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OrderConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? vatPercent = null,
    Object? shippingFeeFlat = null,
    Object? autoCancelHours = null,
    Object? enabledPaymentMethods = null,
  }) {
    return _then(
      _value.copyWith(
            vatPercent: null == vatPercent
                ? _value.vatPercent
                : vatPercent // ignore: cast_nullable_to_non_nullable
                      as double,
            shippingFeeFlat: null == shippingFeeFlat
                ? _value.shippingFeeFlat
                : shippingFeeFlat // ignore: cast_nullable_to_non_nullable
                      as double,
            autoCancelHours: null == autoCancelHours
                ? _value.autoCancelHours
                : autoCancelHours // ignore: cast_nullable_to_non_nullable
                      as int,
            enabledPaymentMethods: null == enabledPaymentMethods
                ? _value.enabledPaymentMethods
                : enabledPaymentMethods // ignore: cast_nullable_to_non_nullable
                      as List<String>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$OrderConfigImplCopyWith<$Res>
    implements $OrderConfigCopyWith<$Res> {
  factory _$$OrderConfigImplCopyWith(
    _$OrderConfigImpl value,
    $Res Function(_$OrderConfigImpl) then,
  ) = __$$OrderConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    double vatPercent,
    double shippingFeeFlat,
    int autoCancelHours,
    List<String> enabledPaymentMethods,
  });
}

/// @nodoc
class __$$OrderConfigImplCopyWithImpl<$Res>
    extends _$OrderConfigCopyWithImpl<$Res, _$OrderConfigImpl>
    implements _$$OrderConfigImplCopyWith<$Res> {
  __$$OrderConfigImplCopyWithImpl(
    _$OrderConfigImpl _value,
    $Res Function(_$OrderConfigImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OrderConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? vatPercent = null,
    Object? shippingFeeFlat = null,
    Object? autoCancelHours = null,
    Object? enabledPaymentMethods = null,
  }) {
    return _then(
      _$OrderConfigImpl(
        vatPercent: null == vatPercent
            ? _value.vatPercent
            : vatPercent // ignore: cast_nullable_to_non_nullable
                  as double,
        shippingFeeFlat: null == shippingFeeFlat
            ? _value.shippingFeeFlat
            : shippingFeeFlat // ignore: cast_nullable_to_non_nullable
                  as double,
        autoCancelHours: null == autoCancelHours
            ? _value.autoCancelHours
            : autoCancelHours // ignore: cast_nullable_to_non_nullable
                  as int,
        enabledPaymentMethods: null == enabledPaymentMethods
            ? _value._enabledPaymentMethods
            : enabledPaymentMethods // ignore: cast_nullable_to_non_nullable
                  as List<String>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$OrderConfigImpl implements _OrderConfig {
  const _$OrderConfigImpl({
    this.vatPercent = 10.0,
    this.shippingFeeFlat = 30000.0,
    this.autoCancelHours = 24,
    final List<String> enabledPaymentMethods = const [
      'COD',
      'Bank Transfer',
      'E-Wallet',
    ],
  }) : _enabledPaymentMethods = enabledPaymentMethods;

  factory _$OrderConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$OrderConfigImplFromJson(json);

  @override
  @JsonKey()
  final double vatPercent;
  @override
  @JsonKey()
  final double shippingFeeFlat;
  @override
  @JsonKey()
  final int autoCancelHours;
  final List<String> _enabledPaymentMethods;
  @override
  @JsonKey()
  List<String> get enabledPaymentMethods {
    if (_enabledPaymentMethods is EqualUnmodifiableListView)
      return _enabledPaymentMethods;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_enabledPaymentMethods);
  }

  @override
  String toString() {
    return 'OrderConfig(vatPercent: $vatPercent, shippingFeeFlat: $shippingFeeFlat, autoCancelHours: $autoCancelHours, enabledPaymentMethods: $enabledPaymentMethods)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrderConfigImpl &&
            (identical(other.vatPercent, vatPercent) ||
                other.vatPercent == vatPercent) &&
            (identical(other.shippingFeeFlat, shippingFeeFlat) ||
                other.shippingFeeFlat == shippingFeeFlat) &&
            (identical(other.autoCancelHours, autoCancelHours) ||
                other.autoCancelHours == autoCancelHours) &&
            const DeepCollectionEquality().equals(
              other._enabledPaymentMethods,
              _enabledPaymentMethods,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    vatPercent,
    shippingFeeFlat,
    autoCancelHours,
    const DeepCollectionEquality().hash(_enabledPaymentMethods),
  );

  /// Create a copy of OrderConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OrderConfigImplCopyWith<_$OrderConfigImpl> get copyWith =>
      __$$OrderConfigImplCopyWithImpl<_$OrderConfigImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OrderConfigImplToJson(this);
  }
}

abstract class _OrderConfig implements OrderConfig {
  const factory _OrderConfig({
    final double vatPercent,
    final double shippingFeeFlat,
    final int autoCancelHours,
    final List<String> enabledPaymentMethods,
  }) = _$OrderConfigImpl;

  factory _OrderConfig.fromJson(Map<String, dynamic> json) =
      _$OrderConfigImpl.fromJson;

  @override
  double get vatPercent;
  @override
  double get shippingFeeFlat;
  @override
  int get autoCancelHours;
  @override
  List<String> get enabledPaymentMethods;

  /// Create a copy of OrderConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrderConfigImplCopyWith<_$OrderConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ProductConfig _$ProductConfigFromJson(Map<String, dynamic> json) {
  return _ProductConfig.fromJson(json);
}

/// @nodoc
mixin _$ProductConfig {
  int get lowStockThreshold => throw _privateConstructorUsedError;
  int get priceUpdateFrequencyHours => throw _privateConstructorUsedError;

  /// Serializes this ProductConfig to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProductConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProductConfigCopyWith<ProductConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductConfigCopyWith<$Res> {
  factory $ProductConfigCopyWith(
    ProductConfig value,
    $Res Function(ProductConfig) then,
  ) = _$ProductConfigCopyWithImpl<$Res, ProductConfig>;
  @useResult
  $Res call({int lowStockThreshold, int priceUpdateFrequencyHours});
}

/// @nodoc
class _$ProductConfigCopyWithImpl<$Res, $Val extends ProductConfig>
    implements $ProductConfigCopyWith<$Res> {
  _$ProductConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProductConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? lowStockThreshold = null,
    Object? priceUpdateFrequencyHours = null,
  }) {
    return _then(
      _value.copyWith(
            lowStockThreshold: null == lowStockThreshold
                ? _value.lowStockThreshold
                : lowStockThreshold // ignore: cast_nullable_to_non_nullable
                      as int,
            priceUpdateFrequencyHours: null == priceUpdateFrequencyHours
                ? _value.priceUpdateFrequencyHours
                : priceUpdateFrequencyHours // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProductConfigImplCopyWith<$Res>
    implements $ProductConfigCopyWith<$Res> {
  factory _$$ProductConfigImplCopyWith(
    _$ProductConfigImpl value,
    $Res Function(_$ProductConfigImpl) then,
  ) = __$$ProductConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int lowStockThreshold, int priceUpdateFrequencyHours});
}

/// @nodoc
class __$$ProductConfigImplCopyWithImpl<$Res>
    extends _$ProductConfigCopyWithImpl<$Res, _$ProductConfigImpl>
    implements _$$ProductConfigImplCopyWith<$Res> {
  __$$ProductConfigImplCopyWithImpl(
    _$ProductConfigImpl _value,
    $Res Function(_$ProductConfigImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProductConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? lowStockThreshold = null,
    Object? priceUpdateFrequencyHours = null,
  }) {
    return _then(
      _$ProductConfigImpl(
        lowStockThreshold: null == lowStockThreshold
            ? _value.lowStockThreshold
            : lowStockThreshold // ignore: cast_nullable_to_non_nullable
                  as int,
        priceUpdateFrequencyHours: null == priceUpdateFrequencyHours
            ? _value.priceUpdateFrequencyHours
            : priceUpdateFrequencyHours // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ProductConfigImpl implements _ProductConfig {
  const _$ProductConfigImpl({
    this.lowStockThreshold = 10,
    this.priceUpdateFrequencyHours = 24,
  });

  factory _$ProductConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProductConfigImplFromJson(json);

  @override
  @JsonKey()
  final int lowStockThreshold;
  @override
  @JsonKey()
  final int priceUpdateFrequencyHours;

  @override
  String toString() {
    return 'ProductConfig(lowStockThreshold: $lowStockThreshold, priceUpdateFrequencyHours: $priceUpdateFrequencyHours)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductConfigImpl &&
            (identical(other.lowStockThreshold, lowStockThreshold) ||
                other.lowStockThreshold == lowStockThreshold) &&
            (identical(
                  other.priceUpdateFrequencyHours,
                  priceUpdateFrequencyHours,
                ) ||
                other.priceUpdateFrequencyHours == priceUpdateFrequencyHours));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, lowStockThreshold, priceUpdateFrequencyHours);

  /// Create a copy of ProductConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductConfigImplCopyWith<_$ProductConfigImpl> get copyWith =>
      __$$ProductConfigImplCopyWithImpl<_$ProductConfigImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProductConfigImplToJson(this);
  }
}

abstract class _ProductConfig implements ProductConfig {
  const factory _ProductConfig({
    final int lowStockThreshold,
    final int priceUpdateFrequencyHours,
  }) = _$ProductConfigImpl;

  factory _ProductConfig.fromJson(Map<String, dynamic> json) =
      _$ProductConfigImpl.fromJson;

  @override
  int get lowStockThreshold;
  @override
  int get priceUpdateFrequencyHours;

  /// Create a copy of ProductConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProductConfigImplCopyWith<_$ProductConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ExpertConfig _$ExpertConfigFromJson(Map<String, dynamic> json) {
  return _ExpertConfig.fromJson(json);
}

/// @nodoc
mixin _$ExpertConfig {
  String get defaultStartWorkTime => throw _privateConstructorUsedError;
  String get defaultEndWorkTime => throw _privateConstructorUsedError;
  int get sessionDurationMinutes => throw _privateConstructorUsedError;

  /// Serializes this ExpertConfig to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ExpertConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExpertConfigCopyWith<ExpertConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExpertConfigCopyWith<$Res> {
  factory $ExpertConfigCopyWith(
    ExpertConfig value,
    $Res Function(ExpertConfig) then,
  ) = _$ExpertConfigCopyWithImpl<$Res, ExpertConfig>;
  @useResult
  $Res call({
    String defaultStartWorkTime,
    String defaultEndWorkTime,
    int sessionDurationMinutes,
  });
}

/// @nodoc
class _$ExpertConfigCopyWithImpl<$Res, $Val extends ExpertConfig>
    implements $ExpertConfigCopyWith<$Res> {
  _$ExpertConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ExpertConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? defaultStartWorkTime = null,
    Object? defaultEndWorkTime = null,
    Object? sessionDurationMinutes = null,
  }) {
    return _then(
      _value.copyWith(
            defaultStartWorkTime: null == defaultStartWorkTime
                ? _value.defaultStartWorkTime
                : defaultStartWorkTime // ignore: cast_nullable_to_non_nullable
                      as String,
            defaultEndWorkTime: null == defaultEndWorkTime
                ? _value.defaultEndWorkTime
                : defaultEndWorkTime // ignore: cast_nullable_to_non_nullable
                      as String,
            sessionDurationMinutes: null == sessionDurationMinutes
                ? _value.sessionDurationMinutes
                : sessionDurationMinutes // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ExpertConfigImplCopyWith<$Res>
    implements $ExpertConfigCopyWith<$Res> {
  factory _$$ExpertConfigImplCopyWith(
    _$ExpertConfigImpl value,
    $Res Function(_$ExpertConfigImpl) then,
  ) = __$$ExpertConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String defaultStartWorkTime,
    String defaultEndWorkTime,
    int sessionDurationMinutes,
  });
}

/// @nodoc
class __$$ExpertConfigImplCopyWithImpl<$Res>
    extends _$ExpertConfigCopyWithImpl<$Res, _$ExpertConfigImpl>
    implements _$$ExpertConfigImplCopyWith<$Res> {
  __$$ExpertConfigImplCopyWithImpl(
    _$ExpertConfigImpl _value,
    $Res Function(_$ExpertConfigImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ExpertConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? defaultStartWorkTime = null,
    Object? defaultEndWorkTime = null,
    Object? sessionDurationMinutes = null,
  }) {
    return _then(
      _$ExpertConfigImpl(
        defaultStartWorkTime: null == defaultStartWorkTime
            ? _value.defaultStartWorkTime
            : defaultStartWorkTime // ignore: cast_nullable_to_non_nullable
                  as String,
        defaultEndWorkTime: null == defaultEndWorkTime
            ? _value.defaultEndWorkTime
            : defaultEndWorkTime // ignore: cast_nullable_to_non_nullable
                  as String,
        sessionDurationMinutes: null == sessionDurationMinutes
            ? _value.sessionDurationMinutes
            : sessionDurationMinutes // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ExpertConfigImpl implements _ExpertConfig {
  const _$ExpertConfigImpl({
    this.defaultStartWorkTime = '08:00',
    this.defaultEndWorkTime = '17:00',
    this.sessionDurationMinutes = 60,
  });

  factory _$ExpertConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExpertConfigImplFromJson(json);

  @override
  @JsonKey()
  final String defaultStartWorkTime;
  @override
  @JsonKey()
  final String defaultEndWorkTime;
  @override
  @JsonKey()
  final int sessionDurationMinutes;

  @override
  String toString() {
    return 'ExpertConfig(defaultStartWorkTime: $defaultStartWorkTime, defaultEndWorkTime: $defaultEndWorkTime, sessionDurationMinutes: $sessionDurationMinutes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExpertConfigImpl &&
            (identical(other.defaultStartWorkTime, defaultStartWorkTime) ||
                other.defaultStartWorkTime == defaultStartWorkTime) &&
            (identical(other.defaultEndWorkTime, defaultEndWorkTime) ||
                other.defaultEndWorkTime == defaultEndWorkTime) &&
            (identical(other.sessionDurationMinutes, sessionDurationMinutes) ||
                other.sessionDurationMinutes == sessionDurationMinutes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    defaultStartWorkTime,
    defaultEndWorkTime,
    sessionDurationMinutes,
  );

  /// Create a copy of ExpertConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExpertConfigImplCopyWith<_$ExpertConfigImpl> get copyWith =>
      __$$ExpertConfigImplCopyWithImpl<_$ExpertConfigImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ExpertConfigImplToJson(this);
  }
}

abstract class _ExpertConfig implements ExpertConfig {
  const factory _ExpertConfig({
    final String defaultStartWorkTime,
    final String defaultEndWorkTime,
    final int sessionDurationMinutes,
  }) = _$ExpertConfigImpl;

  factory _ExpertConfig.fromJson(Map<String, dynamic> json) =
      _$ExpertConfigImpl.fromJson;

  @override
  String get defaultStartWorkTime;
  @override
  String get defaultEndWorkTime;
  @override
  int get sessionDurationMinutes;

  /// Create a copy of ExpertConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExpertConfigImplCopyWith<_$ExpertConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PromotionConfig _$PromotionConfigFromJson(Map<String, dynamic> json) {
  return _PromotionConfig.fromJson(json);
}

/// @nodoc
mixin _$PromotionConfig {
  int get maxVouchersPerUser => throw _privateConstructorUsedError;
  bool get allowStackingVouchers => throw _privateConstructorUsedError;

  /// Serializes this PromotionConfig to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PromotionConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PromotionConfigCopyWith<PromotionConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PromotionConfigCopyWith<$Res> {
  factory $PromotionConfigCopyWith(
    PromotionConfig value,
    $Res Function(PromotionConfig) then,
  ) = _$PromotionConfigCopyWithImpl<$Res, PromotionConfig>;
  @useResult
  $Res call({int maxVouchersPerUser, bool allowStackingVouchers});
}

/// @nodoc
class _$PromotionConfigCopyWithImpl<$Res, $Val extends PromotionConfig>
    implements $PromotionConfigCopyWith<$Res> {
  _$PromotionConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PromotionConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? maxVouchersPerUser = null,
    Object? allowStackingVouchers = null,
  }) {
    return _then(
      _value.copyWith(
            maxVouchersPerUser: null == maxVouchersPerUser
                ? _value.maxVouchersPerUser
                : maxVouchersPerUser // ignore: cast_nullable_to_non_nullable
                      as int,
            allowStackingVouchers: null == allowStackingVouchers
                ? _value.allowStackingVouchers
                : allowStackingVouchers // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PromotionConfigImplCopyWith<$Res>
    implements $PromotionConfigCopyWith<$Res> {
  factory _$$PromotionConfigImplCopyWith(
    _$PromotionConfigImpl value,
    $Res Function(_$PromotionConfigImpl) then,
  ) = __$$PromotionConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int maxVouchersPerUser, bool allowStackingVouchers});
}

/// @nodoc
class __$$PromotionConfigImplCopyWithImpl<$Res>
    extends _$PromotionConfigCopyWithImpl<$Res, _$PromotionConfigImpl>
    implements _$$PromotionConfigImplCopyWith<$Res> {
  __$$PromotionConfigImplCopyWithImpl(
    _$PromotionConfigImpl _value,
    $Res Function(_$PromotionConfigImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PromotionConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? maxVouchersPerUser = null,
    Object? allowStackingVouchers = null,
  }) {
    return _then(
      _$PromotionConfigImpl(
        maxVouchersPerUser: null == maxVouchersPerUser
            ? _value.maxVouchersPerUser
            : maxVouchersPerUser // ignore: cast_nullable_to_non_nullable
                  as int,
        allowStackingVouchers: null == allowStackingVouchers
            ? _value.allowStackingVouchers
            : allowStackingVouchers // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PromotionConfigImpl implements _PromotionConfig {
  const _$PromotionConfigImpl({
    this.maxVouchersPerUser = 5,
    this.allowStackingVouchers = true,
  });

  factory _$PromotionConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$PromotionConfigImplFromJson(json);

  @override
  @JsonKey()
  final int maxVouchersPerUser;
  @override
  @JsonKey()
  final bool allowStackingVouchers;

  @override
  String toString() {
    return 'PromotionConfig(maxVouchersPerUser: $maxVouchersPerUser, allowStackingVouchers: $allowStackingVouchers)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PromotionConfigImpl &&
            (identical(other.maxVouchersPerUser, maxVouchersPerUser) ||
                other.maxVouchersPerUser == maxVouchersPerUser) &&
            (identical(other.allowStackingVouchers, allowStackingVouchers) ||
                other.allowStackingVouchers == allowStackingVouchers));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, maxVouchersPerUser, allowStackingVouchers);

  /// Create a copy of PromotionConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PromotionConfigImplCopyWith<_$PromotionConfigImpl> get copyWith =>
      __$$PromotionConfigImplCopyWithImpl<_$PromotionConfigImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PromotionConfigImplToJson(this);
  }
}

abstract class _PromotionConfig implements PromotionConfig {
  const factory _PromotionConfig({
    final int maxVouchersPerUser,
    final bool allowStackingVouchers,
  }) = _$PromotionConfigImpl;

  factory _PromotionConfig.fromJson(Map<String, dynamic> json) =
      _$PromotionConfigImpl.fromJson;

  @override
  int get maxVouchersPerUser;
  @override
  bool get allowStackingVouchers;

  /// Create a copy of PromotionConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PromotionConfigImplCopyWith<_$PromotionConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
