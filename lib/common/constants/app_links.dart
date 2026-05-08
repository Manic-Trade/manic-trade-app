class AppLinks {
  AppLinks._();

  static const urlAndroidRateUs =
      "https://play.google.com/store/apps/details?id=trade.manic.app";
  static const urlTermsOfUse = "https://www.manic.trade/terms";
  static const urlPrivacy = "https://www.manic.trade/privacy";

  static const _urlTransakBuyBase =
      "https://global.transak.com/?apiKey=42568c7e-f940-4c40-a07f-71afb08d313b&productsAvailed=BUY&cryptoCurrencyCode=USDC&network=solana&defaultFiatCurrency=USD&walletAddress=";

  static const urlApplyForWhitelist =
      "https://form.typeform.com/to/s7fHHpgL?typeform-source=manic-trade-web.vercel.app";

  static const urlPriceSource = "https://pyth.network/";

  static String getTransakBuyUrl(String walletAddress) {
    return "$_urlTransakBuyBase$walletAddress";
  }

  static const urlLeaderboardDetails =
      "https://www.manic.trade/blogs/manic-alpha-season-2-trading-competition-user-guide";

  static const urlDiscordSupport = "https://discord.com/invite/manic-trade";

  static const urlAgentSkill = "https://github.com/manic-trade/manic-agent-skill";

  static const xManicTradeHandle = "ManicTrade";
  static const urlFollowManicTradeOnX =
      "https://x.com/intent/follow?screen_name=$xManicTradeHandle";
}
