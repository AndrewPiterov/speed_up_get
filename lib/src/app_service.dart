import 'package:get/get.dart';
import 'package:speed_up_get/speed_up_get.dart';

abstract class AppService extends GetxService
    with GetxSubscribing
    implements IAsyncInitService {
  @override
  Future initAsync([IAsyncInitServiceParams? params]) async {}
}
