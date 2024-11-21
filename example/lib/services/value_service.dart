import 'dart:math' as m;

import 'package:get/get.dart';
import 'package:speed_up_get/speed_up_get.dart';

class Params extends AppServiceParams {
  @override
  List<Object?> get props => [];
}

class ValueService extends AppService<Params> {
  final _val = 0.obs;
  int get val => _val.value;

  @override
  void onInit() {
    super.onInit();
    _val.value = m.max(1, val);
    d('[onInit] $val');
  }

  @override
  Future onReady() async {
    super.onReady();
    await Future.delayed(const Duration(seconds: 3));
    _val.value = m.max(2, val);
    d('[onReady] $val');
  }

  @override
  Future<void> initAsyncWith(params) async {
    _val.value = m.max(3, val);
    d('[init] $val');
  }
}
