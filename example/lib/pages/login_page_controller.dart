import 'package:example/some_service.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:speed_up_get/speed_up_get.dart';

abstract class ILoginPageController {
  Future login();
}

class LoginPageController extends GetxController
    with GetxSubscribing
    implements ILoginPageController {
  LoginPageController({ISomeService? someService})
      : _someService = someService ?? Get.find();

  final ISomeService _someService;

  @override
  void onInit() {
    super.onInit();

    subscribe(_someService.value$, (value) {
      debugPrint('Login Controller: ' + value.toString());
    });
  }

  @override
  Future login() async {
    await Get.offAllNamed('/');
  }
}
