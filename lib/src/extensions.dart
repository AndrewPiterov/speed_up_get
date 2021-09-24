import 'package:get/get.dart';

extension GetxViewExtensions<T> on GetView<T> {
  T get c => controller;
}

extension GetxWidgetExtensions<T extends GetLifeCycleBase?> on GetWidget<T> {
  T get c => controller;
}
