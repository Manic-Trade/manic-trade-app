class Currencies {
  Currencies._();

  static const String usd = "USD";
  static const String cny = "CNY";
  static const String krw = "KRW";
  static const String gbp = "GBP";
  static const String eur = "EUR";
  static const String rub = "RUB";
  static const String symbolUsd = "\$";
  static const String symbolCny = "¥";
  static const String symbolKrw = "₩";
  static const String symbolGbp = "£";
  static const String symbolEur = "€";
  static const String symbolRub = "₽";
  static const List<String> all = [usd, cny, krw, gbp, eur, rub];

  static final _currencySymbolMap = {
    usd: symbolUsd,
    cny: symbolCny,
    krw: symbolKrw,
    gbp: symbolGbp,
    eur: symbolEur,
    rub: symbolRub,
  };

  static String? getSymbolForCurrency(String currency) {
    return _currencySymbolMap[currency];
  }
}

extension CurrencySymbol on String? {
  String asCurrencySymbolFormat(String amount) {
    var value = this;
    if (value == null) {
      return amount;
    }
    var currencySymbol = Currencies.getSymbolForCurrency(value.toUpperCase());
    if (currencySymbol != null) {
      return "$currencySymbol$amount";
    } else {
      return "$amount$value";
    }
  }

  String toCurrencySymbol() {
    if (this == null) {
      return "";
    }
    return Currencies.getSymbolForCurrency(this!.toUpperCase()) ?? "";
  }

  String withUsdSymbol() {
    if (this == null) {
      return "";
    }
    return "\$$this";
  }

  String withCurrencySymbol(String currency) {
    var amount = this;
    if (amount == null) {
      return currency.asCurrencySymbolFormat("0");
    }
    return currency.asCurrencySymbolFormat(amount);
  }
}
