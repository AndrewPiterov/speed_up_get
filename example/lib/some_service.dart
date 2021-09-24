import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:speed_up_get/speed_up_get.dart';

abstract class ISomeService {
  Stream<int> get value$;
}

class SomeService extends GetxService
    with GetxSubscribing
    implements ISomeService {
  late StreamController<int> _controller;

  @override
  Stream<int> get value$ => _controller.stream;

  @override
  void onInit() {
    super.onInit();

    _controller = StreamController.broadcast();

    subscribe(Stream.periodic(const Duration(seconds: 1)), (value) {
      final now = DateTime.now();
      debugPrint('Now: ' + now.toString());
      _controller.add(now.millisecondsSinceEpoch);
    });
  }

  @override
  void onClose() {
    _controller.close();
    // No need to unsubscribe
    super.onClose();
  }
}
