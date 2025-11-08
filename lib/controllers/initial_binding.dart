import 'package:dgc_demo_project/controllers/todo_controller.dart';
import 'package:get/get.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(TodoController());
  }
}
