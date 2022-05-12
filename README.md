<!-- 
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages). 

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages). 
-->

The package extends functionality for [GetX](https://pub.dev/packages/get).

## Features

* Short reference to controller
* Unsubscribe a subscriptions automatically

## Getting started

Add dependency

```yaml
dependencies:
  speed_up_get: latest
```

## Usage

### Reference to a Controller

Now you can reference to controller in the View(Widget) with short `c` reference

```dart
Scaffold(
  appBar: AppBar(
    title: Text(c.title),
  ),
  body: Center(
    child: Obx(
      () => Text(
        '${c.counter}',
        style: Theme.of(context).textTheme.headline4,
      ),
    ),
  ),
  floatingActionButton: FloatingActionButton(
    onPressed: c.incrementCounter,
    tooltip: 'Increment',
    child: const Icon(Icons.add),
  ),
);
```

### Subscribing

Subscribe in `onInit` of Services or Controllers and forget to unsubscribe in `onClose`

```dart
@override
void onInit() {
  subscribe(Stream.values([1, 2, 3]), onValue: (value) => print(value));
}

@override
void onClose() {
  // TODO: No need unsubscribe
  super.onClose();
}
```

Longer examples to `/example` folder.

### Decorator for Rx<T> (.obs) variables

`GetRxDecorator` is useful where the Unidirectional Data Flow is need to be. 
One can achieve that with hiding Rx-variable behind accessors.

```dart
/// 1. Variable itself.
final _clickCounter = 0.obs;

/// 2. Getter
int get clickCounter => _clickCounter();

/// 3. Setter
set clickCounter(int v) => _clickCounter(_process(v));

/// 4. Its Stream
Stream<int> get clickCounterStream => _clickCounter.stream;

/// 5. Method to process
int _process(int v) => v > 3 ? 0 : v;
```
But it is some cumbersome.

Here is where the GetRxDecorator make sense to use.

```dart
/// 1. Encapsulated Rx variable
late var clickCounter =
   0.obsDeco(setter: (_, newValue, __) => _process(newValue ?? 0));

/// 2. Method to process
int _process(int v) => v > 3 ? 0 : v;
```

In simplest case enough to replace `.obs` with `.obsDeco`

```dart
var rxVarInt = 1.obs;
var rxVarInt = 1.obsDeco();
```

#### Features

Firstly, UDF with compact implementation. With UDF one controls data flow in strict OOP manner.

Second, one can pass optional arguments when try to change variable. 
It can useful in some circumstances.

```dart
onPressed: () {
  c.collatzDecor.withArgs(this);
},
```

Third, callback take current value as argument and with this one can realize interesting use cases, 
based on previous value rather on new one. Collatz conjecture is the good case.

```dart
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

```


A lot of tests inside can be a good point to start.

Run example in `/example/lib/main_rx_decorator.dart` file.


## Contributing

We accept the following contributions:

* Improving documentation
* Reporting issues
* Fixing bugs

## Maintainers

* [Andrew Piterov](mailto:piterov1990@gmail.com?subject=[GitHub]%20Source%20Dart%20fluent_result)
* [Valery Kulikov](mailto:frostyland@gmail.com?subject=[GitHub]%20Source%20Dart%20speed_up_get)

