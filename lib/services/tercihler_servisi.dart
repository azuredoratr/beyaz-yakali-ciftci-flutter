import 'package:shared_preferences/shared_preferences.dart';

class TercihlerServisi {
  static const _sehirKey = 'secilen_sehir';
  static const _bahceTipiKey = 'bahce_tipi';

  static Future<void> sehirKaydet(String sehir) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sehirKey, sehir);
  }

  static Future<String> sehirGetir() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_sehirKey) ?? 'Ankara';
  }

  static Future<void> bahceTipiKaydet(String tip) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_bahceTipiKey, tip);
  }

  static Future<String> bahceTipiGetir() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_bahceTipiKey) ?? 'Hobi Bahçesi';
  }

  static Future<bool> onboardingTamamlandiMi() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_sehirKey) != null;
  }

  static Future<void> onboardingTemizle() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}