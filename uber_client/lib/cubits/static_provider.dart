import 'package:flutter/material.dart';

import '../repositories/cache.dart';

/**
 * handle static app state, langauge, theme ...
 */
class StaticProvider extends ChangeNotifier {
  late Locale? _locale;

  StaticProvider() {
    _locale = Cache.appLocale;
  }

  Locale? get locale => _locale;

  void setLocale(Locale? locale) {
    _locale = locale;
    Cache.appLocale = locale;
    notifyListeners();
  }
}
