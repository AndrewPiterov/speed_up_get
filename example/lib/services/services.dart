import 'package:example/services/another_service.dart';
import 'package:example/services/some_service.dart';
import 'package:get/get.dart';
import 'package:speed_up_get/speed_up_get.dart';

import 'value_service.dart';

export 'value_service.dart';

Future initService() async {
  Get.lazyPut<ISomeService>(() => SomeService());
  await registerServiceAsync(ValueService());
  Get.put(AnotherService());
}
