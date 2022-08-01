import 'package:example/services/another_service.dart';
import 'package:example/services/some_service.dart';
import 'package:get/get.dart';

import 'value_service.dart';

export 'value_service.dart';

Future initService() async {
  Get.lazyPut<ISomeService>(() => SomeService());
  await Get.putAsync<ValueService>(() async {
    final x = ValueService();
    await x.init();
    return x;
  });
  Get.put(AnotherService());
}
