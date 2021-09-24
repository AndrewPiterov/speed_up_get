import 'package:example/pages/login_page.dart';
import 'package:example/some_service.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:speed_up_get/speed_up_get.dart';

abstract class IHomePageController {
  int get counter;

  void incrementCounter();
  Future signOut();
}

class HomePageController extends GetxController
    with GetxSubscribing
    implements IHomePageController {
  HomePageController({ISomeService? someService})
      : _someService = someService ?? Get.find();

  final ISomeService _someService;

  var _counter = 0.obs;
  @override
  int get counter => _counter.value;

  @override
  void onInit() {
    super.onInit();

    subscribe(_someService.value$, (value) {
      debugPrint('Home Controller: ' + value.toString());
    });
  }

  @override
  void incrementCounter() {
    debugPrint('Count');
    _counter = _counter + 1;
  }

  @override
  Future signOut() async {
    await Get.offAllNamed('/login');
  }

  @override
  void onClose() {
    // No need unsubscribe
    super.onClose();
  }
}
