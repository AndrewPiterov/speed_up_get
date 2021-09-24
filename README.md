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

## Contributing

We accept the following contributions:

* Improving documentation
* Reporting issues
* Fixing bugs

## Maintainers

* [Andrew Piterov](mailto:piterov1990@gmail.com?subject=[GitHub]%20Source%20Dart%20fluent_result)
