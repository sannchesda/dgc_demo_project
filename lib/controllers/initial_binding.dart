import 'package:dgc_demo_project/controllers/internet_check_controller.dart';
import 'package:get/get.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(InternetCheckController());
  }
}
