import 'package:example/pages/login_page_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speed_up_get/speed_up_get.dart';

class LoginPage extends GetView<ILoginPageController> {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.lazyPut<ILoginPageController>(() => LoginPageController());

    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: c.login,
          child: const Text('Login'),
        ),
      ),
    );
  }
}
