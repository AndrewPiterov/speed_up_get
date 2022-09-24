import 'dart:developer';
import 'dart:math' as m;

import 'package:get/get.dart';
import 'package:speed_up_get/speed_up_get.dart';

class ValueService extends AppService {
  final _val = 0.obs;
  int get val => _val.value;

  @override
  void onInit() {
    super.onInit();
    _val.value = m.max(1, val);
    log('[ValueService] [onInit] $val');
  }

  @override
  Future onReady() async {
    super.onReady();
    await Future.delayed(const Duration(seconds: 3));
    _val.value = m.max(2, val);
    log('[ValueService] [onReady] $val');
  }

  @override
  Future initAsync([IAsyncInitServiceParams? params]) async {
    super.initAsync();
    _val.value = m.max(3, val);
    log('[ValueService] [init] $val');
  }
}
