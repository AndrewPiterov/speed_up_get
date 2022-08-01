import 'dart:developer';

import 'package:example/services/value_service.dart';
import 'package:get/get.dart';

class AnotherService extends GetxService {
  final ValueService someService = Get.find();

  @override
  void onInit() {
    super.onInit();
    log('[AnotherService] [onInit] ${someService.val}');
  }

  @override
  void onReady() {
    super.onReady();
    log('[AnotherService] [onReady] ${someService.val}');
  }
}
