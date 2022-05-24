import 'package:equatable/equatable.dart';
import 'package:get/get_rx/get_rx.dart';

/// GetRxDecorator for Rx<T> variables in Get library [https://pub.dev/packages/get]
/// This wrapper lets to apply UDF concept and makes it easier
/// to work with Getx' Rx<T> and Obx.
///
/// ============================================================================
///
/// Why one need to use this decorator? Because of problem with Rx<T> variables:
///
/// Mainly, direct using this reactive variables violates all of known
/// design patterns. Client (some View) send command to change state
/// and get result immediately without Model processing.
///
/// We should to hide variable itself behind accessors, and this decorator
/// makes it in very handy way.
///
/// ============================================================================
///
/// Without GetRxDecorator
///
/// ```dart
///   // declarations:
///
///   /// 1. Variable itself.
///   final _clickCounterUdf = 0.obs;
///
///   /// 2. Getter
///   int get clickCounterUdf => _clickCounterUdf();
///
///   /// 3. Setter
///   set clickCounterUdf(int v) => _clickCounterUdf(_process(v));
///
///   /// 4. Stream
///   Stream<int> get clickCounterStreamUdf => _clickCounterUdf.stream;
///
///   /// This processor drops values above 3 down to zero.
///   int _process(int v) => v > 3 ? 0 : v;
///
///   //=======================================================
///
///   // using:
///   // Somewhere in View
///   return Center(
///     child: ElevatedButton(
///       child: Obx(
///          () => Text('value = ${controller.clickCounterUdf}'),
///       ),
///       onPressed: () => controller.clickCounterUdf++,
///     ),
///   );
/// ```
///
/// With GetRxDecorator
///
/// ```dart
///
/// // declaration:
///
/// /// Encapsulated Rx variable
/// late var clickCounterDecor = 0.obsDeco(setter: (_, newValue, __) =>
///   _process(newValue ?? 0));
///
/// //=========================================================================
///
/// // using:
/// // Somewhere in View
/// return Center(
///  child: ElevatedButton(
///    child: Obx(
///          () => Text('value = ${controller.clickCounterDecor}'),
///    ),
///    onPressed: () => controller.clickCounterDecor++,
///  ),
/// );
///
/// ```
class GetRxDecorator<T> extends Equatable {
  GetRxDecorator(T initial, {this.setter, this.forceRefresh})
      : _src = Rx<T>(initial);

  /// Inner .obs variable.
  final Rx<T> _src;

  /// Callback for adjust custom setter.
  /// [oldValue] parameter allows to apply specific algorithms,
  ///   e.g. without [newValue], like a Collatz conjecture (see tests).
  /// [withArgs] parameter allows using additional arguments in algorithms,
  ///   e.g. type or instance of variable's sender or something (see tests).
  final GetRxDecoratorSetter<T>? setter;

  /// Decorates getter.
  T get value => _src();

  /// Decorates setter.
  set value(T? val) => _setValue(newValue: val);

  /// Decorates .obs inner stream.
  Stream<T> get stream => _src.stream;

  /// Force auto refresh.
  final bool? forceRefresh;

  /// Decorates .call([T? value]) but with additional [args] parameter.
  ///
  /// Use [this] as functional object with parameters:
  /// value means new value. Optional.
  /// args means additional argument(s) for some use cases. Optional.
  T call([T? value, dynamic args]) {
    _setValue(newValue: value, args: args);
    return this.value;
  }

  /// Additional setter in cases when no need to change value itself.
  /// For example, when every call changes inner value only depending
  /// on external arguments (see Collatz conjecture setter test)
  T withArgs(dynamic args) => call(_src(), args);

  /// We can use either custom setter or default setting mechanism.
  ///
  /// newValue: value to be set. It may be null in some logic cases. Optional.
  /// args: optional dynamic parameter. In some cases, you may need
  ///   an additional call context to select the logic of changing a variable.
  void _setValue({T? newValue, dynamic args}) {
    // Prepare for adjust latter auto refresh.
    final isSameValue = newValue == _src();

    if (setter == null) {
      _src(newValue);
    } else {
      // Here we can return as `wrong` either [oldValue] or null.
      final candidate = setter!(value, newValue, args);
      _src(candidate);
    }

    if (isSameValue && (forceRefresh ?? false)) {
      refresh();
    }
  }

  void refresh() => _src.refresh();

  /// Same as `toString()` but using a getter.
  String get string => value.toString();

  @override
  String toString() => value.toString();

  @override
  List<Object?> get props => [_src];
}

/// Type of callback to change value in UDF manner.
/// [oldValue] passes currentValue.
/// [newValue] passes value to apply.
/// [args] passes additional arguments.
typedef GetRxDecoratorSetter<T> = T? Function(
    T oldValue, T? newValue, dynamic args);

////////////////////////////////////////////////////////////////////////////////

///
extension IntGetRxDecoratorX on GetRxDecorator<int> {
  /// Addition operator.
  GetRxDecorator<int> operator +(int add) {
    call(value + add);
    return this;
  }

  /// Subtraction operator.
  GetRxDecorator<int>  operator -(int sub) {
    call(value - sub);
    return this;
  }

  /// Bit-wise and operator.
  ///
  /// Treating both `this` and [other] as sufficiently large two's component
  /// integers, the result is a number with only the bits set that are set in
  /// both `this` and [other]
  ///
  /// If both operands are negative, the result is negative, otherwise
  /// the result is non-negative.
  int operator &(int other) => value & other;

  /// Bit-wise or operator.
  ///
  /// Treating both `this` and [other] as sufficiently large two's component
  /// integers, the result is a number with the bits set that are set in either
  /// of `this` and [other]
  ///
  /// If both operands are non-negative, the result is non-negative,
  /// otherwise the result is negative.
  int operator |(int other) => value | other;

  /// Bit-wise exclusive-or operator.
  ///
  /// Treating both `this` and [other] as sufficiently large two's component
  /// integers, the result is a number with the bits set that are set in one,
  /// but not both, of `this` and [other]
  ///
  /// If the operands have the same sign, the result is non-negative,
  /// otherwise the result is negative.
  int operator ^(int other) => value ^ other;

  /// The bit-wise negate operator.
  ///
  /// Treating `this` as a sufficiently large two's component integer,
  /// the result is a number with the opposite bits set.
  ///
  /// This maps any integer `x` to `-x - 1`.
  int operator ~() => ~value;

  /// Shift the bits of this integer to the left by [shiftAmount].
  ///
  /// Shifting to the left makes the number larger, effectively multiplying
  /// the number by `pow(2, shiftIndex)`.
  ///
  /// There is no limit on the size of the result. It may be relevant to
  /// limit intermediate values by using the "and" operator with a suitable
  /// mask.
  ///
  /// It is an error if [shiftAmount] is negative.
  int operator <<(int shiftAmount) => value << shiftAmount;

  /// Shift the bits of this integer to the right by [shiftAmount].
  ///
  /// Shifting to the right makes the number smaller and drops the least
  /// significant bits, effectively doing an integer division by
  ///`pow(2, shiftIndex)`.
  ///
  /// It is an error if [shiftAmount] is negative.
  int operator >>(int shiftAmount) => value >> shiftAmount;

  /// Returns this integer to the power of [exponent] modulo [modulus].
  ///
  /// The [exponent] must be non-negative and [modulus] must be
  /// positive.
  int modPow(int exponent, int modulus) => value.modPow(exponent, modulus);

  /// Returns the greatest common divisor of this integer and [other].
  ///
  /// If either number is non-zero, the result is the numerically greatest
  /// integer dividing both `this` and `other`.
  ///
  /// The greatest common divisor is independent of the order,
  /// so `x.gcd(y)` is  always the same as `y.gcd(x)`.
  ///
  /// For any integer `x`, `x.gcd(x)` is `x.abs()`.
  ///
  /// If both `this` and `other` is zero, the result is also zero.
  int gcd(int other) => value.gcd(other);

  /// Returns true if and only if this integer is even.
  bool get isEven => value.isEven;

  /// Returns true if and only if this integer is odd.
  bool get isOdd => value.isOdd;

  /// Returns the minimum number of bits required to store this integer.
  ///
  /// The number of bits excludes the sign bit, which gives the natural length
  /// for non-negative (unsigned) values.  Negative values are complemented to
  /// return the bit position of the first bit that differs from the sign bit.
  ///
  /// To find the number of bits needed to store the value as a signed value,
  /// add one, i.e. use `x.bitLength + 1`.
  /// ```
  /// x.bitLength == (-x-1).bitLength
  ///
  /// 3.bitLength == 2;     // 00000011
  /// 2.bitLength == 2;     // 00000010
  /// 1.bitLength == 1;     // 00000001
  /// 0.bitLength == 0;     // 00000000
  /// (-1).bitLength == 0;  // 11111111
  /// (-2).bitLength == 1;  // 11111110
  /// (-3).bitLength == 2;  // 11111101
  /// (-4).bitLength == 2;  // 11111100
  /// ```
  int get bitLength => value.bitLength;

  /// Returns the least significant [width] bits of this integer as a
  /// non-negative number (i.e. unsigned representation).  The returned value
  /// has zeros in all bit positions higher than [width].
  /// ```
  /// (-1).toUnsigned(5) == 31   // 11111111  ->  00011111
  /// ```
  /// This operation can be used to simulate arithmetic from low level
  /// languages.
  /// For example, to increment an 8 bit quantity:
  /// ```
  /// q = (q + 1).toUnsigned(8);
  /// ```
  /// `q` will count from `0` up to `255` and then wrap around to `0`.
  ///
  /// If the input fits in [width] bits without truncation, the result is the
  /// same as the input.  The minimum width needed to avoid truncation of `x` is
  /// given by `x.bitLength`, i.e.
  /// ```
  /// x == x.toUnsigned(x.bitLength);
  /// ```
  int toUnsigned(int width) => value.toUnsigned(width);

  /// Returns the least significant [width] bits of this integer, extending the
  /// highest retained bit to the sign.  This is the same as truncating the
  /// value to fit in [width] bits using an signed 2-s complement
  /// representation.
  /// The returned value has the same bit value in all positions higher than
  /// [width].
  ///
  /// ```
  ///                                V--sign bit-V
  /// 16.toSigned(5) == -16   //  00010000 -> 11110000
  /// 239.toSigned(5) == 15   //  11101111 -> 00001111
  ///                                ^           ^
  /// ```
  /// This operation can be used to simulate arithmetic from low level
  /// languages.
  /// For example, to increment an 8 bit signed quantity:
  /// ```
  /// q = (q + 1).toSigned(8);
  /// ```
  /// `q` will count from `0` up to `127`, wrap to `-128` and count back up to
  /// `127`.
  ///
  /// If the input value fits in [width] bits without truncation, the result is
  /// the same as the input.  The minimum width needed to avoid truncation
  /// of `x` is `x.bitLength + 1`, i.e.
  /// ```
  /// x == x.toSigned(x.bitLength + 1);
  /// ```
  int toSigned(int width) => value.toSigned(width);

  /// Return the negative value of this integer.
  ///
  /// The result of negating an integer always has the opposite sign, except
  /// for zero, which is its own negation.
  int operator -() => -value;

  /// Returns the absolute value of this integer.
  ///
  /// For any integer `x`, the result is the same as `x < 0 ? -x : x`.
  int abs() => value.abs();

  /// Returns the sign of this integer.
  ///
  /// Returns 0 for zero, -1 for values less than zero and
  /// +1 for values greater than zero.
  int get sign => value.sign;

  /// Returns `this`.
  int round() => value.round();

  /// Returns `this`.
  int floor() => value.floor();

  /// Returns `this`.
  int ceil() => value.ceil();

  /// Returns `this`.
  int truncate() => value.truncate();

  /// Returns `this.toDouble()`.
  double roundToDouble() => value.roundToDouble();

  /// Returns `this.toDouble()`.
  double floorToDouble() => value.floorToDouble();

  /// Returns `this.toDouble()`.
  double ceilToDouble() => value.ceilToDouble();

  /// Returns `this.toDouble()`.
  double truncateToDouble() => value.truncateToDouble();
}

extension GetRxDecoratorIntX on int {
  GetRxDecorator<int> obsDeco(
          {bool? forceRefresh, GetRxDecoratorSetter<int>? setter}) =>
      GetRxDecorator<int>(this, forceRefresh: forceRefresh, setter: setter);
}



///
// class GetRxDecoratorDouble extends GetRxDecorator<double> {
//   GetRxDecoratorDouble(double initial,
//       {bool? forceRefresh, GetRxDecoratorSetter<double>? setter})
//       : super(initial, forceRefresh: forceRefresh, setter: setter);
//
//   /// Addition operator.
//   GetRxDecoratorDouble operator +(double add) {
//     call(_src.value + add);
//     return this;
//   }
//
//   /// Subtraction operator.
//   GetRxDecoratorDouble operator -(double sub) {
//     call(_src.value - sub);
//     return this;
//   }
// }

extension DoubleGetRxDecoratorX on GetRxDecorator<double> {
  /// Addition operator.
  GetRxDecorator<double> operator +(num other) {
    value = value + other;
    return this;
  }

  /// Subtraction operator.
  GetRxDecorator<double> operator -(num other) {
    value = value - other;
    return this;
  }

  /// Multiplication operator.
  double operator *(num other) => value * other;

  double operator %(num other) => value % other;

  /// Division operator.
  double operator /(num other) => value / other;

  /// Truncating division operator.
  ///
  /// The result of the truncating division `a ~/ b` is equivalent to
  /// `(a / b).truncate()`.
  int operator ~/(num other) => value ~/ other;

  /// Negate operator. */
  double operator -() => -value;

  /// Returns the absolute value of this [double].
  double abs() => value.abs();

  /// Returns the sign of the double's numerical value.
  ///
  /// Returns -1.0 if the value is less than zero,
  /// +1.0 if the value is greater than zero,
  /// and the value itself if it is -0.0, 0.0 or NaN.
  double get sign => value.sign;

  /// Returns the integer closest to `this`.
  ///
  /// Rounds away from zero when there is no closest integer:
  ///  `(3.5).round() == 4` and `(-3.5).round() == -4`.
  ///
  /// If `this` is not finite (`NaN` or infinity), throws an [UnsupportedError].
  int round() => value.round();

  /// Returns the greatest integer no greater than `this`.
  ///
  /// If `this` is not finite (`NaN` or infinity), throws an [UnsupportedError].
  int floor() => value.floor();

  /// Returns the least integer no smaller than `this`.
  ///
  /// If `this` is not finite (`NaN` or infinity), throws an [UnsupportedError].
  int ceil() => value.ceil();

  /// Returns the integer obtained by discarding any fractional
  /// digits from `this`.
  ///
  /// If `this` is not finite (`NaN` or infinity), throws an [UnsupportedError].
  int truncate() => value.truncate();

  /// Returns the integer double value closest to `this`.
  ///
  /// Rounds away from zero when there is no closest integer:
  ///  `(3.5).roundToDouble() == 4` and `(-3.5).roundToDouble() == -4`.
  ///
  /// If this is already an integer valued double, including `-0.0`, or it is
  /// not a finite value, the value is returned unmodified.
  ///
  /// For the purpose of rounding, `-0.0` is considered to be below `0.0`,
  /// and `-0.0` is therefore considered closer to negative numbers than `0.0`.
  /// This means that for a value, `d` in the range `-0.5 < d < 0.0`,
  /// the result is `-0.0`.
  double roundToDouble() => value.roundToDouble();

  /// Returns the greatest integer double value no greater than `this`.
  ///
  /// If this is already an integer valued double, including `-0.0`, or it is
  /// not a finite value, the value is returned unmodified.
  ///
  /// For the purpose of rounding, `-0.0` is considered to be below `0.0`.
  /// A number `d` in the range `0.0 < d < 1.0` will return `0.0`.
  double floorToDouble() => value.floorToDouble();

  /// Returns the least integer double value no smaller than `this`.
  ///
  /// If this is already an integer valued double, including `-0.0`, or it is
  /// not a finite value, the value is returned unmodified.
  ///
  /// For the purpose of rounding, `-0.0` is considered to be below `0.0`.
  /// A number `d` in the range `-1.0 < d < 0.0` will return `-0.0`.
  double ceilToDouble() => value.ceilToDouble();

  /// Returns the integer double value obtained by discarding any fractional
  /// digits from `this`.
  ///
  /// If this is already an integer valued double, including `-0.0`, or it is
  /// not a finite value, the value is returned unmodified.
  ///
  /// For the purpose of rounding, `-0.0` is considered to be below `0.0`.
  /// A number `d` in the range `-1.0 < d < 0.0` will return `-0.0`, and
  /// in the range `0.0 < d < 1.0` it will return 0.0.
  double truncateToDouble() => value.truncateToDouble();
}

///
extension GetRxDecoratorDoubleX on double {
  GetRxDecorator<double> obsDeco(
          {bool? forceRefresh, GetRxDecoratorSetter<double>? setter}) =>
      GetRxDecorator<double>(this, forceRefresh: forceRefresh, setter: setter);
}

///
extension BoolGetRxDecoratorX on GetRxDecorator<bool> {
  bool get isTrue => value;

  bool get isFalse => !isTrue;

  bool operator &(bool other) => other && value;

  bool operator |(bool other) => other || value;

  bool operator ^(bool other) => !other == value;

  /// Toggles the bool [value] between false and true.
  /// A shortcut for `flag.value = !flag.value;`
  /// FIXME: why return this? fluent interface is not
  ///  not really a dart thing since we have '..' operator
  // ignore: avoid_returning_this
  GetRxDecorator<bool> toggle() {
    call(_src.value = !_src.value);
    return this;
  }
}

///
extension GetRxDecoratorBoolX on bool {
  GetRxDecorator<bool> obsDeco(
          {bool? forceRefresh, GetRxDecoratorSetter<bool>? setter}) =>
      GetRxDecorator<bool>(this, forceRefresh: forceRefresh, setter: setter);
}

///
class GetRxDecoratorString extends GetRxDecorator<String>
    implements Comparable<String>, Pattern {
  GetRxDecoratorString(String initial,
      {bool? forceRefresh, GetRxDecoratorSetter<String>? setter})
      : super(initial, forceRefresh: forceRefresh, setter: setter);

  GetRxDecoratorString operator +(String add) {
    call(_src.value + add);
    return this;
  }

  @override
  Iterable<Match> allMatches(String string, [int start = 0]) {
    return _src.value.allMatches(string, start);
  }

  @override
  Match? matchAsPrefix(String string, [int start = 0]) {
    return _src.value.matchAsPrefix(string, start);
  }

  @override
  int compareTo(String other) {
    return _src.value.compareTo(other);
  }
}

///
extension StringGetRxDecoratorX on String {
  GetRxDecoratorString obsDeco(
          {bool? forceRefresh, GetRxDecoratorSetter<String>? setter}) =>
      GetRxDecoratorString(this, forceRefresh: forceRefresh, setter: setter);
}

///
extension GetRxDecoratorX<T> on T {
  GetRxDecorator<T> obsDeco(
          {bool? forceRefresh, GetRxDecoratorSetter<T>? setter}) =>
      GetRxDecorator<T>(this, forceRefresh: forceRefresh, setter: setter);
}

