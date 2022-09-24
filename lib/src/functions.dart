import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'async_init_service.dart';

/// Registering services asynchronously (Sugar way)
Future registerServiceAsync<T extends IAsyncInitService>(
  T service, [
  IAsyncInitServiceParams? params,
]) async {
  return benchLog(
    '==> ⚙️ [Service] async initialization (${service.runtimeType.toString()})',
    () async {
      await service.initAsync();
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
