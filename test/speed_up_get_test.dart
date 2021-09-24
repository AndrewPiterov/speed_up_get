import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:speed_up_get/speed_up_get.dart';

class TestController extends GetxController with GetxSubscribing {
  TestController(this.count);
  final int count;

  late StreamController<int> _controller;

  Stream<int> get value$ => _controller.stream;

  @override
  void onInit() {
    super.onInit();
    _controller = StreamController();

    subscribe(
      Stream<int>.periodic(const Duration(milliseconds: 100), (x) => x)
          .take(count),
      (value) {
        _controller.add(value as int);
      },
    );
  }

  @override
  void onClose() {
    _controller.close();
    super.onClose();
  }
}

void main() {
  test('Subscribe in a controller', () async {
    const count = 5;
    final controller = Get.put(TestController(count));

    // final items = <int>[];
    // final sub = controller.value$.listen((value) {
    //   if (value >= 10) {
    //     Get.reset();
    //     return;
    //   }
    //   items.add(value);
    // });

    // expect(controller.value$, emitsInOrder([0, 1, 2, 3, 4, 5]));

    // controller.value$.listen((event) {
    //   expectAsync1(
    //       (value) => expect(
    //             value,
    //             inInclusiveRange(110, 11110),
    //           ),
    //       count: 1);
    // });

    // await Future.delayed(const Duration(seconds: 10));
    // expect(items.length, count);
    // sub.cancel();
  });
}
