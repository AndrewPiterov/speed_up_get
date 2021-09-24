import 'dart:async';
import 'dart:developer';
import 'package:get/get.dart';

mixin GetxSubscribing on DisposableInterface {
  final _subs = <StreamSubscription>[];

  void subscribe<T>(
    Stream<T> stream,
    void Function(T value) onValue, {
    void Function(Object error)? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    final subscription = stream.listen(
      onValue,
      onError: onError?.call,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
    _subs.add(subscription);
  }

  @override
  void onClose() {
    for (final s in _subs) {
      log('Subscription has been closed');
      s.cancel();
    }
    super.onClose();
  }
}
