import 'dart:developer';

import 'package:fluent_result/fluent_result.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:speed_up_get/speed_up_get.dart';
import 'package:given_when_then_unit_test/given_when_then_unit_test.dart';

class ServiceWithoutParameters extends AppService {
  @override
  Future<Result> initAsync() {
    log('ServiceParameters initAsync');
    return super.initAsync();
  }

  @override
  Future<Result> initAsyncWith(dynamic params) {
    log('ServiceParameters initAsyncWith');
    return super.initAsyncWith(params);
  }
}

void main() {
  beforeAll(() {
    Get.put<Logger>(Logger());
  });

  test('ServiceWithoutParameters', () async {
    final service = ServiceWithoutParameters();
    final result = await service.initAsync();
    expect(result.isSuccess, true);
  });
}
