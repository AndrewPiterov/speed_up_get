import 'dart:developer';

import 'package:fluent_result/fluent_result.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:speed_up_get/speed_up_get.dart';
import 'package:given_when_then_unit_test/given_when_then_unit_test.dart';

class ServiceParameters extends AppServiceParams {
  ServiceParameters({required this.value});

  final String value;

  @override
  List<Object?> get props => [value];
}

class ServiceWithParameters extends AppService<ServiceParameters> {
  @override
  Future<Result> initAsync() {
    log('initAsync');
    return super.initAsync();
  }

  @override
  Future<Result> initAsyncWith(ServiceParameters params) {
    log('initAsyncWith');
    return super.initAsyncWith(params);
  }
}

void main() {
  beforeAll(() {
    Get.put<Logger>(Logger());
  });

  test('ServiceWithParameters', () async {
    final service = ServiceWithParameters();
    final result = await service.initAsync();
    expect(result.isSuccess, true);
  });

  test('ServiceWithParameters', () async {
    final service = ServiceWithParameters();
    final result =
        await service.initAsyncWith(ServiceParameters(value: 'test value'));
    expect(result.isSuccess, true);
  });
}
