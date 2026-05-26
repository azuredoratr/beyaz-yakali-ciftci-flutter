import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class BitkiServisi {
  static const _key = 'bitkiler';

  // Tüm bitkileri getir
  static Future<List<Map<String, dynamic>>> bitkileriGetir() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_key);
    if (json == null) return [];
    final liste = jsonDecode(json) as List;
    return liste.map((e) => e as Map<String, dynamic>).toList();
  }

  // Bitki ekle
  static Future<void> bitkiEkle(Map<String, dynamic> bitki) async {
    final liste = await bitkileriGetir();
    liste.add(bitki);
    await _kaydet(liste);
  }

  // Bitki sil
  static Future<void> bitkiSil(String id) async {
    final liste = await bitkileriGetir();
    liste.removeWhere((b) => b['id'] == id);
    await _kaydet(liste);
  }

  // Bitki güncelle
  static Future<void> bitkiGuncelle(Map<String, dynamic> bitki) async {
    final liste = await bitkileriGetir();
    final index = liste.indexWhere((b) => b['id'] == bitki['id']);
    if (index != -1) {
      liste[index] = bitki;
      await _kaydet(liste);
    }
  }

  // Hafta hesapla — ekim tarihinden bugüne
  static int haftaHesapla(String ekimTarihi) {
    final ekim = DateTime.parse(ekimTarihi);
    final fark = DateTime.now().difference(ekim).inDays;
    return (fark / 7).floor() + 1;
  }

  // Tüm bitkilerin haftalarını güncelle
  static Future<List<Map<String, dynamic>>> bitkileriGuncelleVeGetir() async {
    final liste = await bitkileriGetir();
    for (final bitki in liste) {
      if (bitki['ekim_tarihi'] != null) {
        bitki['hafta'] = haftaHesapla(bitki['ekim_tarihi'] as String);
      }
    }
    await _kaydet(liste);
    return liste;
  }

  static Future<void> _kaydet(List<Map<String, dynamic>> liste) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(liste));
  }
}