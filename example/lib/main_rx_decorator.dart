import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speed_up_get/speed_up_get.dart';

/// This is sample page for [GetRxDecorator] concepts and howto.
///
/// Every button (except red one) shows 2 variables:
/// ordinary Rx<T> and decorator to check that they work
/// the same way.
///
/// Red button shows using [GetRxDecorator.args] to show use case
/// with external additional parameters.
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Obs and Decorators',
                style: Theme.of(context).textTheme.displaySmall,
                textAlign: TextAlign.center,
              ),
            ),
            GetX<IntController>(
              init: IntController(),
              builder: (c) {
                return Button(
                  c.clickCounterUdf,
                  c.clickCounterDecor,
                  () {
                    c.clickCounterUdf++;
                    c.clickCounterDecor++;
                  },
                );
              },
            ),
            GetX<DoubleController>(
              init: DoubleController(),
              initState: (_) {},
              builder: (c) {
                return Button(
                  c.valueUdf,
                  c.valueDecor,
                  () {
                    c.valueUdf += 1.1;
                    c.valueDecor += 1.1;
                  },
                );
              },
            ),
            GetX<BoolController>(
              init: BoolController(),
              initState: (_) {},
              builder: (c) {
                return Button(
                  c.checkedUdf,
                  c.checkedDecor,
                  () {
                    // in plain obs .toggle() does not work in UDF pattern ...
                    c.checkedUdf = !c.checkedUdf;
                    // ... and in decorator it does
                    c.checkedDecor.toggle();
                  },
                );
              },
            ),
            GetX<StringController>(
              init: StringController(),
              initState: (_) {},
              builder: (c) {
                return Button(
                  c.stringUdf,
                  c.stringDecor,
                  () {
                    c.stringUdf += ', world!';
                    c.stringDecor += ', world!';
                  },
                );
              },
            ),
            GetX<CollatzController>(
              init: CollatzController(),
              initState: (_) {},
              builder: (c) {
                return Button(
                  c.collatzUdf,
                  c.collatzDecor,
                  () {
                    // In plain obs we re forced to pass some dummy value
                    // an it is confused
                    c.collatzUdf = 10;
                    // whereas the decorator has clear semantics
                    c.collatzDecor();
                  },
                );
              },
            ),
            // This widget demonstrates how to use additions args
            //  in [GetRxDecorator].
            //  This argument(s) prohibits variable changing.
            GetX<CollatzController>(
              builder: (c) {
                return SizedBox(
                  width: Get.width - 100,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red, // background
                      onPrimary: Colors.yellow, // foreground
                    ),
                    onPressed: () {
                      c.collatzDecor.withArgs(this);
                    },
                    child: Column(
                      children: [
                        Text(
                            '${c.collatzDecor.runtimeType}: ${c.collatzDecor}'),
                      ],
                    ),
                  ),
                );
              },
            ),
            const Logger(),
          ],
        ),
      ),
    );
  }
}

/// Generic button for checking Decorator concepts.
/// We will manipulate with 2 reactive variables at once
/// and both should be equal.
class Button<O, D, C extends GetxController> extends StatelessWidget {
  const Button(this.obs, this.obsDecorator, this.onPressed, {Key? key})
      : super(key: key);

  final O obs;
  final D obsDecorator;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: Get.width - 100,
        child: ElevatedButton(
          child: Column(
            children: [
              // Here is standard rx-variable
              Text((v) {
                return '${v.runtimeType}: $v';
              }(obs)),
              // Here is decorator for rx-variable
              Text((v) {
                return '${v.runtimeType}: $v';
              }(obsDecorator)),
            ],
          ),
          onPressed: onPressed,
        ),
      ),
    );
  }
}

/// Logger demonstrates that decorators work identically to native `.obs`.
class Logger extends StatelessWidget {
  const Logger({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ic = Get.find<IntController>();
    final dc = Get.find<DoubleController>();
    final bc = Get.find<BoolController>();
    final sc = Get.find<StringController>();
    final cc = Get.find<CollatzController>();

    return Obx(() {
      return SizedBox(
        width: Get.width - 100,
        child: Card(
          color: Theme.of(context).backgroundColor,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
              title: const Text('Log:'),
              subtitle: Text('int = ${ic.clickCounterDecor}\n'
                  'double decorator = ${dc.valueDecor},\n'
                  'bool decorator = ${bc.checkedDecor},\n'
                  'string decorator = ${sc.stringDecor},\n'
                  'collatz decorator = ${cc.collatzDecor}'),
            ),
          ),
        ),
      );
    });
  }
}

///
class IntController extends GetxController {
  /// Ordinary observable variable.
  /// The problem is there is no way to control its value in business layer.
  var clickCounter = 0.obs;

  /// Observable variable in UDF pattern.
  /// Now we can control variable' value through setter [clickCounterUdf].
  /// But we have to orchestrate 3 or 4 entity for this pattern:
  ///
  /// 1. Variable itself.
  final _clickCounterUdf = 0.obs;

  /// 2. Its Getter
  int get clickCounterUdf => _clickCounterUdf();

  /// 3. Its Setter
  set clickCounterUdf(int v) => _clickCounterUdf(_process(v));

  /// 4. Its Stream
  Stream<int> get clickCounterStreamUdf => _clickCounterUdf.stream;

  /// Decorator for observable variable.
  /// All advantages in one.
  late var clickCounterDecor =
      0.obsDeco(setter: (_, newValue, __) => _process(newValue ?? 0));

  /// This processor drops values above 3 down to zero.
  int _process(int v) => v > 3 ? 0 : v;
}

///
class DoubleController extends GetxController {
  static const _startValue = 0.1;
  static const _maxValue = 3.1;

  final _valueUdf = _startValue.obs;

  double get valueUdf => _valueUdf();

  set valueUdf(double v) => _valueUdf(_process(v));

  ///
  late var valueDecor = _startValue.obsDeco(
      setter: (_, newValue, __) => _process(newValue ?? _startValue));

  /// This processor drops values above 3.1 down to 0.1.
  double _process(double v) => v > _maxValue ? _startValue : v;
}

///
class BoolController extends GetxController {
  final _checkedUdf = false.obs;

  bool get checkedUdf => _checkedUdf();

  set checkedUdf(bool v) => _checkedUdf(v);

  /// Decorator (4-in-1)
  /// Setter here makes nothing special.
  var checkedDecor = false.obsDeco(setter: (_, newValue, __) => newValue);
}

///
class StringController extends GetxController {
  final _stringUdf = 'hello'.obs;

  String get stringUdf => _stringUdf();

  set stringUdf(String v) => _stringUdf(v.length > 18 ? 'hello' : v);

  /// Decorator 4-in-1
  late var stringDecor = 'hello'.obsDeco(setter: (_, newValue, __) {
    return _process(newValue ?? '');
  });

  /// This processor cuts oversized value to simple 'hello' one.
  String _process(String v) => v.length > 18 ? 'hello' : v;
}

///
class CollatzController extends GetxController {
  final _collatzUdf = 7.obs;

  int get collatzUdf => _collatzUdf();

  /// This setter realizes Collatz conjecture.
  /// See that one forces here to pass something as a parameter
  /// even if it is not used.
  set collatzUdf(int _) {
    if (_collatzUdf.value.isEven) {
      _collatzUdf.value = _collatzUdf.value ~/ 2;
    } else {
      _collatzUdf.value = 3 * _collatzUdf.value + 1;
    }
  }

  /// Decorator.
  /// This setter realizes Collatz conjecture.
  /// As you see that we are free to eliminate passing any parameter
  /// if it is not required.
  var collatzDecor = 7.obsDeco(setter: (oldValue, _, args) {
    // See how context works!
    if (args != null) {
      Future.delayed(const Duration(milliseconds: 250)).then((_) {
        ScaffoldMessenger.of(Get.context!).showSnackBar(SnackBar(
          backgroundColor: Colors.red,
          content: Text('It is not possible with this args: $args'),
        ));
      });
      return oldValue;
    }

    //
    if (oldValue.isEven) {
      return oldValue ~/ 2;
    } else {
      return 3 * oldValue + 1;
    }
  });
}
