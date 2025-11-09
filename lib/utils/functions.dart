import 'package:dgc_demo_project/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

DateTime? currentBackPressTime;

Future<bool> onWillPop(BuildContext context) async {
  DateTime now = DateTime.now();
  if (currentBackPressTime == null ||
      now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
    currentBackPressTime = now;
    showSnackbar(context, "exit_app_message".tr);
    return Future.value(false);
  }
  return Future.value(true);
}

void showSnackbar(
  BuildContext context,
  String message, {
  SnackBarAction? action,
  Duration? duration,
}) {
  ScaffoldMessenger.of(context).clearSnackBars();

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: const TextStyle(color: Colors.white),
      ),
      action: action,
      margin: const EdgeInsets.all(8),
      padding: (action != null) ? null : const EdgeInsets.all(16),
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
      duration: duration ?? const Duration(seconds: 1),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

Future<void> showSimpleSnackbar(String message, {bool isForce = false}) async {
  if (isForce) {
    await Get.closeCurrentSnackbar();
  }

  Get.snackbar(
    "",
    "",
    titleText: Text(
      message,
      // style: const TextStyle(
      //   color: Colors.white,
      //   fontFamily: AppFonts.primary,
      // ),
    ),
    messageText: const SizedBox(),
    margin: const EdgeInsets.all(8),
    snackStyle: SnackStyle.FLOATING,
    animationDuration: const Duration(milliseconds: 150),
    borderRadius: 16,
    // backgroundColor: Colors.black,
    snackPosition: SnackPosition.BOTTOM,
  );
}

void setStatusBarLight() {
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarIconBrightness:
          (GetPlatform.isIOS) ? Brightness.dark : Brightness.light,
      statusBarBrightness:
          (GetPlatform.isIOS) ? Brightness.dark : Brightness.light,
    ),
  );
}

void setStatusBarDark() {
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarIconBrightness:
          (GetPlatform.isIOS) ? Brightness.light : Brightness.dark,
      statusBarBrightness:
          (GetPlatform.isIOS) ? Brightness.light : Brightness.dark,
    ),
  );
}

Future<void> delay({Duration? duration}) async {
  await Future.delayed(
    duration ?? const Duration(milliseconds: AppStaticValue.delayDuration),
  );
}

int? checkDynamicId(dynamic data) {
  if (data == null) {
    return null;
  }
  if (data is int) {
    return data;
  }
  if (data is String) {
    if (data.isEmpty) {
      return null;
    }
    return int.parse(data);
  }
  return null;
}

Future<void> requestUserLocationPermission() async {
  final status = await Permission.location.status;
  if (status.isGranted) {
    return;
  }

  final isAllow = await Permission.location.request();
  if (isAllow.isGranted) {
    return;
  }
}

int getExtendedVersionNumber(String version) {
  List versionCells = version.split('.');
  versionCells = versionCells.map((i) => int.parse(i)).toList();
  return versionCells[0] * 10000 + versionCells[1] * 100 + versionCells[2];
}

void focus(BuildContext context) {
  FocusScopeNode currentFocus = FocusScope.of(context);

  if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
    FocusManager.instance.primaryFocus?.unfocus();
  }
}
