import 'dart:ui';

import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class ConfigHelper {
  Map<String, bool> _supportedLocales = {'en_VN': false, 'vi_VN': false};

  String _locale = "en_VN";
  String _currencySymbol = "";
  double _maxDecimal = 2;
  ConfigHelper._privateConstructor() {
    // initLocale();
  }

  initLocale() {
    _supportedLocales.keys.forEach((locale) {
      initializeDateFormatting(locale).whenComplete(() {
        print('Complete for locale ' + locale);
        _supportedLocales[locale] = true;
      });
    });
  }

  static final ConfigHelper instance = ConfigHelper._privateConstructor();

  String convertToCurrencyLocale(double amount, {locale, currencySymbol}) {
    return NumberFormat.currency(
            locale: locale ?? _locale,
            symbol: currencySymbol ?? _currencySymbol)
        .format(amount);
  }

  double parseAmount(String amountAsString) {
    return NumberFormat.currency(locale: _locale, symbol: _currencySymbol)
        .parse(amountAsString);
  }

  void config({locale, currencySymbol, maxDecimal}) {
    this._locale = locale ?? this._locale;
    this._currencySymbol = currencySymbol ?? this._currencySymbol;
    this._maxDecimal = maxDecimal ?? this._maxDecimal;
  }

  String locale() => _locale;
  String currencySymbol() => _currencySymbol;
  double maxDecimal() => _maxDecimal;
  String localeLangue() => _locale.substring(0, _locale.indexOf("_"));
  String localeCountry() => _locale.substring(_locale.indexOf("_") + 1);
  Locale localeObj() => Locale(this.localeLangue(), this.localeCountry());
  bool localeInit(String locale) => _supportedLocales[locale];
}
