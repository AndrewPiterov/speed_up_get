import 'package:flutter_test/flutter_test.dart';
import 'package:speed_up_get/src/rx_decorator.dart';

void main() {
  group('GetRxDecorator tests', () {
    ///
    test('GetRxDecorator: equality test', () async {
      {
        final v1 = 'a'.obsDeco();
        final v2 = 'a'.obsDeco();
        expect(v1, equals(v2));
      }
      {
        final v1 = GetRxDecorator(const ['a', 'b']);
        final v2 = GetRxDecorator(const ['a', 'b']);
        expect(v1, equals(v2));
      }
      {
        final v1 = GetRxDecorator(const {
          1: ['a', 'b']
        });
        final v2 = GetRxDecorator(const {
          1: ['a', 'b']
        });
        expect(v1, equals(v2));
      }
      {
        final v1 = 'a'.obsDeco();
        final v2 = 'b'.obsDeco();
        expect(v1, isNot(equals(v2)));
      }
      {
        final v1 = GetRxDecorator(const ['a', 'b']);
        final v2 = GetRxDecorator(const ['a', 'c']);
        expect(v1, isNot(equals(v2)));
      }
      {
        final v1 = GetRxDecorator(const {
          1: ['a', 'b']
        });
        final v2 = GetRxDecorator(const {
          1: ['d', 'b']
        });
        expect(v1, isNot(equals(v2)));
      }
      {
        final v1 = GetRxDecorator(const {
          1: ['a', 'b']
        });
        final v2 = GetRxDecorator(const {
          2: ['a', 'b']
        });
        expect(v1, isNot(equals(v2)));
      }
    });

    /// Here we just use auto setting.
    test('GetRxDecorator: with default setter test (No special business logic)',
        () async {
      var v = 'a'.obsDeco();
      expectLater(v.stream, emitsInOrder(['b', 'c', 'cd']));
      v.setValue(newValue: 'b');
      v.setValue(newValue: 'c');
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
      v.setValue(newValue: 'b-');
      v.setValue(newValue: 'b');
      v.setValue(newValue: 'c');
      v.setValue(newValue: '-c');
      v.setValue(newValue: 'd');
      v += '-';
    });

    /// Here we does not use autoRefresh.
    test('GetRxDecorator: without refresh test', () async {
      final v = 'a'.obsDeco(
          setter: (_, newValue, __) =>
              // We can return as `wrong` either [oldValue] or null.
              newValue?.contains('-') ?? false ? newValue : null);
      expectLater(v.stream, emitsInOrder(['b-', '-c', 'd-d']));
      v.setValue(newValue: 'b-');
      v.setValue(newValue: 'b-');
      v.setValue(newValue: 'b-');
      v.setValue(newValue: 'b');
      v.setValue(newValue: 'c');
      v.setValue(newValue: 'c');
      v.setValue(newValue: '-c');
      v.setValue(newValue: '-c');
      v.setValue(newValue: '-c');
      v.setValue(newValue: 'd-d');
    });

    /// Here we use autoRefresh.
    test('GetRxDecorator: with refresh test', () async {
      final v = 'a'.obsDeco(
        forceUpdate: true,
        // We can return as `wrong` either [oldValue] or null.
        setter: (_, newValue, __) =>
            newValue?.contains('-') ?? false ? newValue : null,
      );
      expectLater(v.stream, emitsInOrder(['b-', 'b-', '-c', '-c', 'd-d']));
      v.setValue(newValue: 'b-');
      v.setValue(newValue: 'b-');
      v.setValue(newValue: '-c');
      v.setValue(newValue: '-c');
      v.setValue(newValue: 'd-d');
    });

    /// Here we use [args] as extra variable.
    test('GetRxDecorator: with args test', () async {
      final v = 'a'.obsDeco(
        forceUpdate: true,
        setter: (_, newValue, args) {
          if (args is int && args < 2) {
            return null;
          }
          // We can return as `wrong` either [oldValue] or null.
          return newValue?.contains('-') ?? false ? newValue : null;
        },
      );
      expectLater(v.stream, emitsInOrder(['b-2', '2-c', '3-d-d']));
      v.setValue(newValue: 'b-1', args: 1);
      v.setValue(newValue: 'b-2', args: 2);
      v.setValue(newValue: '1-c', args: 1);
      v.setValue(newValue: '2-c', args: 2);
      v.setValue(newValue: '3-d-d', args: 3);
    });

    /// Here we use [args] as extra variable - variant 2.
    test('GetRxDecorator: with args-2 test', () async {
      final v = 'a'.obsDeco(
        forceUpdate: true,
        setter: (oldValue, newValue, args) {
          if (args is bool) {
            return null;
          }

          // We can return as `wrong` either [oldValue] or null.
          return newValue?.contains('-') ?? false ? newValue : oldValue;
        },
      );
      expectLater(v.stream, emitsInOrder(['b-2', '2-c', '3-d-d']));
      v.setValue(newValue: 'b-1', args: false);
      v.setValue(newValue: 'b-2', args: 2);
      v.setValue(newValue: '1-c', args: true);
      v.setValue(newValue: '2-c', args: 2);
      v.setValue(newValue: '3-d-d', args: 4.4);
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
      List.generate(19, (_) => v.setValue());
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
  });
}
