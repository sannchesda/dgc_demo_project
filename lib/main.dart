import 'package:dgc_demo_project/controllers/initial_binding.dart';
import 'package:dgc_demo_project/firebase_options.dart';
import 'package:dgc_demo_project/utils/color.dart';
import 'package:dgc_demo_project/utils/constant.dart';
import 'package:dgc_demo_project/utils/font.dart';
import 'package:dgc_demo_project/views/main_navigation_wrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness:
          (GetPlatform.isIOS) ? Brightness.dark : Brightness.light,
    ),
  );
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await GetStorage.init();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = GetStorage();
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus &&
            currentFocus.focusedChild != null) {
          FocusManager.instance.primaryFocus?.unfocus();
        }
      },
      child: GetMaterialApp(
        title: 'Todo Checklist App',
        localizationsDelegates: const [
          ...GlobalMaterialLocalizations.delegates,
          GlobalWidgetsLocalizations.delegate,
          DefaultMaterialLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en'), Locale('km')],
        initialBinding: InitialBinding(),
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            brightness: Brightness.light,
          ),
          fontFamily: getFont(),
          hintColor: Colors.grey[400],
          appBarTheme: const AppBarTheme(centerTitle: true),
          iconTheme: IconThemeData(color: AppColors.icon),
          navigationBarTheme: NavigationBarThemeData(
            // indicatorColor: AppColors.lightYellow,
            iconTheme: WidgetStateProperty.all(
              IconThemeData(color: AppColors.icon),
            ),
          ),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            brightness: Brightness.dark,
          ),
          fontFamily: getFont(),
          hintColor: Colors.grey[400],
          appBarTheme: const AppBarTheme(centerTitle: true),
          iconTheme: IconThemeData(color: AppColors.iconDark),
          navigationBarTheme: NavigationBarThemeData(
            iconTheme: WidgetStateProperty.all(
              IconThemeData(color: AppColors.iconDark),
            ),
          ),
        ),
        themeMode: (storage.read(StorageKey.themeModeKeyName) ?? "") == "Dark"
            ? ThemeMode.dark
            : ThemeMode.light,
        home: const MainNavigationWrapper(),
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
            child: child ?? Container(),
          );
        },
      ),
    );
  }

  String getFont() {
    if (Get.locale == const Locale('en', 'US')) {
      return AppFonts.primary;
    } else {
      return AppFonts.khmerFont;
    }
  }
}
