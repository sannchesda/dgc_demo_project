import 'package:dgc_demo_project/language/en_us.dart';
import 'package:dgc_demo_project/language/km_kh.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';


class LocalizationService extends Translations {
  // static const locale = Locale('en', 'US');
  static const locale = Locale('km', 'KM');

  // fallbackLocale saves the day when the locale gets in trouble
  // static const fallbackLocale = Locale('en', 'US');
  static const fallbackLocale = Locale('km', 'KM');

  // Supported languages
  // Needs to be same order with locales
  static final langs = ['English', 'ខ្មែរ'];

  // Supported locales
  // Needs to be same order with langs
  static const locales = [
    Locale('en', 'US'),
    Locale('km', 'KM'),
  ];

  // Keys and their translations
  // Translations are separated maps in `lang` file
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': enUS, // lang/en_us.dart
        'km_KM': kmKH,
      };

  // Gets locale from language, and updates the locale
  void changeLocale(String lang) {
    final locale = _getLocaleFromLanguage(lang);

    Get.updateLocale(locale!);
    final GetStorage getStorage = GetStorage();
    getStorage.write("language", lang);
  }

  void getLocale() {
    final GetStorage getStorage = GetStorage();
    String lang = getStorage.read("language") ?? "English";
    changeLocale(lang);
  }

  // Finds language in `langs` list and returns it as Locale
  Locale? _getLocaleFromLanguage(String lang) {
    for (int i = 0; i < langs.length; i++) {
      if (lang == langs[i]) {
        return locales[i];
      }
    }
    return Get.locale;
  }

  String getCurrentLang() {
    if (Get.locale == const Locale('en', 'US')) {
      return langs[0];
    } else {
      return langs[1];
    }
  }

  String getLanguageCode() {
    if (Get.locale == const Locale('en', 'US')) {
      return "en";
    } else {
      return 'km';
    }
  }
}
