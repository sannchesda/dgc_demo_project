import 'package:dgc_demo_project/controllers/user_controller.dart';
import 'package:dgc_demo_project/language/localization_service.dart';
import 'package:dgc_demo_project/utils/constant.dart';
import 'package:dgc_demo_project/views/home_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final userController = Get.put(UserController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      LocalizationService().getLocale();
      initialCheck();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: Get.width,
        height: Get.height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 100,
              width: 100,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: Image.asset("${AssetDir.icon}/app_icon.png"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> initialCheck() async {
    await Future.delayed(const Duration(seconds: 1));
    Get.offAll(() => const HomePage());
  }
}
