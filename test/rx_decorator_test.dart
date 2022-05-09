import 'package:flutter_test/flutter_test.dart';
import 'package:speed_up_get/src/rx_decorator.dart';

void main() {
  group('GetRxDecorator tests', () {
    test('GetRxDecorator: strings equality test', () async {
      final v1 = 'a'.obsDeco();
      final v2 = 'a'.obsDeco();
      expect(v1, equals(v2));
    });

    test('GetRxDecorator: strings not equality test', () async {
      final v1 = 'a'.obsDeco();
      final v2 = 'b'.obsDeco();
      expect(v1, isNot(equals(v2)));
    });

    test('GetRxDecorator: lists equality test', () async {
      final v1 = GetRxDecorator(const ['a', 'b']);
      final v2 = GetRxDecorator(const ['a', 'b']);
      expect(v1, equals(v2));
    });

    test('GetRxDecorator: lists not equality test', () async {
      final v1 = GetRxDecorator(const ['a', 'b']);
      final v2 = GetRxDecorator(const ['a', 'c']);
      expect(v1, isNot(equals(v2)));
    });

    test('GetRxDecorator: maps equality test', () async {
      final v1 = GetRxDecorator(const {
        1: ['a', 'b']
      });
      final v2 = GetRxDecorator(const {
        1: ['a', 'b']
      });
      expect(v1, equals(v2));
    });

    test('GetRxDecorator: maps not equality test', () async {
      final v1 = GetRxDecorator(const {
        1: ['a', 'b']
      });
      final v2 = GetRxDecorator(const {
        1: ['d', 'b']
      });
      expect(v1, isNot(equals(v2)));
    });

    test('GetRxDecorator: maps key not equality test', () async {
      final v1 = GetRxDecorator(const {
        1: ['a', 'b']
      });
      final v2 = GetRxDecorator(const {
        2: ['a', 'b']
      });
      expect(v1, isNot(equals(v2)));
    });

    /// Here we just use auto setting.
    test('GetRxDecorator: with default setter test (No special business logic)',
        () async {
      var v = 'a'.obsDeco();
      expectLater(v.stream, emitsInOrder(['b', 'c', 'cd']));
      v('b');
      v('c');
      v += 'd';
    });

    /// Here we can use special business logic inside custom setter.
    test(
        'GetRxDecorator: with custom setter test (with special business logic)',
        () async {
      var v = 'a'.obsDeco(
          setter: (_, newValue, __) =>
              // We can return as `wrong` either [oldValue] or null.
              newValue?.contains('-') ?? false ? newValue : null);
      expectLater(v.stream, emitsInOrder(['b-', '-c', '-c-']));
      v('b-');
      v('b');
      v('c');
      v('-c');
      v('d');
      v += '-';
    });

    /// Here we does not use forceRefresh.
    test('GetRxDecorator: without refresh test', () async {
      final v = 'a'.obsDeco(
          setter: (_, newValue, __) =>
              // We can return as `wrong` either [oldValue] or null.
              newValue?.contains('-') ?? false ? newValue : null);
      expectLater(v.stream, emitsInOrder(['b-', '-c', 'd-d']));
      v('b-');
      v('b-');
      v('b-');
      v('b');
      v('c');
      v('c');
      v('-c');
      v('-c');
      v('-c');
      v('d-d');
    });

    /// Here we use forceRefresh.
    test('GetRxDecorator: with refresh test', () async {
      final v = 'a'.obsDeco(
        forceRefresh: true,
        // We can return as `wrong` either [oldValue] or null.
        setter: (_, newValue, __) =>
            newValue?.contains('-') ?? false ? newValue : null,
      );
      expectLater(v.stream, emitsInOrder(['b-', 'b-', '-c', '-c', 'd-d']));
      v('b-');
      v('b-');
      v('-c');
      v('-c');
      v('d-d');
    });

    /// Here we use [args] as extra variable.
    test('GetRxDecorator: with args test', () async {
      final v = 'a'.obsDeco(
        forceRefresh: true,
        setter: (_, newValue, args) {
          if (args is int && args < 2) {
            return null;
          }
          // We can return as `wrong` either [oldValue] or null.
          return newValue?.contains('-') ?? false ? newValue : null;
        },
      );
      expectLater(v.stream, emitsInOrder(['b-2', '2-c', '3-d-d']));
      v('b-1', 1);
      v('b-2', 2);
      v('1-c', 1);
      v('2-c', 2);
      v('3-d-d', 3);
    });

    /// Here we use [args] as extra variable - variant 2.
    test('GetRxDecorator: with args-2 test', () async {
      final v = 'a'.obsDeco(
        forceRefresh: true,
        setter: (oldValue, newValue, args) {
          if (args is bool) {
            return null;
          }

          // We can return as `wrong` either [oldValue] or null.
          return newValue?.contains('-') ?? false ? newValue : oldValue;
        },
      );
      expectLater(v.stream, emitsInOrder(['b-2', '2-c', '3-d-d']));
      v('b-1', false);
      v('b-2', 2);
      v('1-c', true);
      v('2-c', 2);
      v('3-d-d', 4.4);
    });

    /// Test using auto calculate without outer affect ([newValue] == null).
    test('GetRxDecorator: Collatz conjecture setter test', () async {
      final v = 7.obsDeco(
        // Here we use [oldValue] as base of next step
        // and does not use [newValue] at all.
        setter: (oldValue, _, __) {
          if (oldValue.isEven) {
            return oldValue ~/ 2;
          } else {
            return 3 * oldValue + 1;
          }
        },
      );
      expectLater(
          v.stream,
          emitsInOrder([
            22,
            11,
            34,
            17,
            52,
            26,
            13,
            40,
            20,
            10,
            5,
            16,
            8,
            4,
            2,
            1,
            4,
            2,
            1,
          ]));

      // Just call [v.value()] without outer variables.
      List.generate(19, (_) => v());
    });

    /// Here one can see overridden operation
    test('GetRxDecorator: decorate int test', () async {
      var v = 0.obsDeco(setter: (_, newValue, __) {
        return (newValue ?? 0) * 2;
      });
      expectLater(v.stream, emitsInOrder([20, 60, 160, 0]));
      v += 10;
      v += 10;
      v += 20;
      v -= 160;
    });

    /// Here one can see overridden operation
    test('GetRxDecorator: decorate bool test', () async {
      var v = true.obsDeco();
      expectLater(v.stream, emitsInOrder([false, true]));
      v.toggle();
      v.toggle();
    });

    /// Here one can see overridden operation
    test('GetRxDecorator: decorate T test', () async {
      var v = _Sample(10).obsDeco();
      expectLater(v.stream, emitsInOrder([_Sample(20), _Sample(30)]));

      v(_Sample(20));
      v(_Sample(30));
    });
  });

  group('GetRxDecorator as Pattern tests', () {
    ///
    test('GetRxDecorator as Pattern: stream test', () async {
      var rxVarInt = 1.obsDeco();

      expectLater(rxVarInt.stream, emitsInOrder([2]));

      rxVarInt(2);
    });

    ///
    test('GetRxDecorator as Pattern: value test', () async {
      var rxVarInt = 1.obsDeco();

      expectLater(rxVarInt.stream, emitsInOrder([2, 3, 2, 10]));

      expect(rxVarInt.value, equals(1));
      expect(rxVarInt(), equals(1));

      rxVarInt += 1;
      expect(rxVarInt.value, equals(2));
      expect(rxVarInt(), equals(2));

      rxVarInt++;
      expect(rxVarInt.value, equals(3));
      expect(rxVarInt(), equals(3));

      rxVarInt--;
      expect(rxVarInt.value, equals(2));
      expect(rxVarInt(), equals(2));

      rxVarInt(10);
      expect(rxVarInt.value, equals(10));
      expect(rxVarInt(), equals(10));
    });

    ///
    test('GetRxDecorator as Pattern: final value test', () async {
      final rxVarInt = 1.obsDeco();

      expectLater(rxVarInt.stream, emitsInOrder([2, 3, 2, 10]));

      expectLater(rxVarInt.value, equals(1));
      expectLater(rxVarInt(), equals(1));

      rxVarInt.value += 1;
      expect(rxVarInt.value, equals(2));
      expect(rxVarInt(), equals(2));

      rxVarInt.value++;
      expectLater(rxVarInt.value, equals(3));
      expectLater(rxVarInt(), equals(3));

      rxVarInt.value--;
      expectLater(rxVarInt.value, equals(2));
      expectLater(rxVarInt(), equals(2));

      rxVarInt.value = 10;
      expectLater(rxVarInt.value, equals(10));
      expectLater(rxVarInt(), equals(10));
    });
  });
}

class _Sample {
  _Sample(this.i);

  final int i;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _Sample && runtimeType == other.runtimeType && i == other.i;

  @override
  int get hashCode => i.hashCode;
}
