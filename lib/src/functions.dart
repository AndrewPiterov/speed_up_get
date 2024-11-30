import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speed_up_get/src/app_service.dart';

/// Registering services asynchronously (Sugar way)
Future registerServiceAsync<T extends IAppService>(
  T service, [
  AppServiceParams? params,
]) async {
  return benchLog(
    '==> ⚙️ [registerServiceAsync] async initialization (${service.runtimeType.toString()})',
    () async {
      if (params != null) {
        await service.initAsyncWith(params);
      } else {
        await service.initAsync();
      }
      Get.put<T>(service);
    },
  );
}

/// Log the duration of the [func] execution.
Future benchLog(String label, Function action) async {
  final start = DateTime.now();
  await action();
  final end = DateTime.now();
  final duration = end.difference(start);
  debugPrint('$label: $duration');
}
