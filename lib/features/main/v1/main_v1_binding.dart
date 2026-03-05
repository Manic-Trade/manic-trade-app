import 'package:get/get.dart';
import 'package:finality/features/main/v1/main_v1_controller.dart';

class MainV1Binding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<MainV1Controller>()) {
      Get.put(MainV1Controller());
    }
  }
}
