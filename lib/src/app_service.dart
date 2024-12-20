import 'package:equatable/equatable.dart';
import 'package:fluent_result/fluent_result.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:speed_up_get/speed_up_get.dart';

abstract class AppServiceParams extends Equatable {}

abstract class IAppService<T extends AppServiceParams> {
  Future<Result> initAsync();

  Future<Result> initAsyncWith(T params);
}

abstract class AppService<T extends AppServiceParams> extends GetxService
    with GetxSubscribing
    implements IAppService<T> {
  final Logger logger = Get.find<Logger>();

  @override
  Future<Result> initAsync() async {
    d('has been initialized.');
    return success();
  }

  @override
  Future<Result> initAsyncWith(T params) async {
    d('has been initialized with $params.');
    return success();
  }

  void d(String message) {
    logger.d('[$runtimeType] $message');
  }
}
