import 'package:example/some_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  Get.lazyPut<ISomeService>(() => SomeService());

  runApp(const MyApp());
}
