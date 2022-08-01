import 'package:example/services/services.dart';
import 'package:flutter/material.dart';

import 'app.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initService();

  runApp(const MyApp());
}
