import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GorevServisi {
  static Map<String, dynamic>? _bitkilerData;

  // JSON'u yükle
  static Future<void> yukle() async {
    if (_bitkilerData != null) return;
    final str = await rootBundle.loadString('lib/data/bitkiler.json');
    _bitkilerData = jsonDecode(str);
  }

  // O bitkinin o haftasının görevlerini getir
  static Future<List<Map<String, dynamic>>> gorevleriGetir({
    required String bitkiId,
    required int hafta,
    required String baslangic, // 'tohum', 'fide', 'tarla'
  }) async {
    await yukle();

    final bitki = _bitkilerData!['bitkiler'][bitkiId];
    if (bitki == null) return [];

    final haftalikIcerik = bitki['haftalik_icerik'];
    if (haftalikIcerik == null) return [];

    final haftaVeri = haftalikIcerik[hafta.toString()];
    if (haftaVeri == null) return [];

    final gorevHavuzu = _bitkilerData!['gorev_havuzu'];
    final gorevler = <Map<String, dynamic>>[];

    final gorevIdleri = [
      ...((haftaVeri['ortak_gorevler'] as List?) ?? []),
      ...((haftaVeri['bitkiye_ozgu_gorevler'] as List?) ?? []),
    ];

    for (final id in gorevIdleri) {
      Map<String, dynamic>? gorev =
          gorevHavuzu['evrensel']?[id] ??
          gorevHavuzu['bitkiye_ozgu']?[bitkiId]?[id];

      if (gorev == null) continue;

      // Başlangıç tipine göre nasıl yapılır talimatını seç
      String? nasil;
      if (baslangic == 'tohum' && gorev['nasil_yapilir_tohum'] != null) {
        nasil = (gorev['nasil_yapilir_tohum'] as List).join('\n');
      } else if (baslangic == 'fide' && gorev['nasil_yapilir_fide'] != null) {
        nasil = (gorev['nasil_yapilir_fide'] as List).join('\n');
      } else if (baslangic == 'tarla' && gorev['nasil_yapilir_tarla'] != null) {
        nasil = (gorev['nasil_yapilir_tarla'] as List).join('\n');
      } else if (gorev['nasil_yapilir'] != null) {
        nasil = (gorev['nasil_yapilir'] as List).join('\n');
      }

      gorevler.add({
        'id': id,
        'ad': gorev['ad'] ?? id,
        'aciklama': gorev['aciklama'] ?? '',
        'tip': gorev['tip'] ?? 'rutin',
        'nasil_yapilir': nasil,
        'not': haftaVeri['gorev_notlari']?[id],
      });
    }

    return gorevler;
  }

  // Tamamlanan görevleri kaydet
  static Future<void> gorevTamamla(String bitkiId, int hafta, String gorevId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'gorev_${bitkiId}_$hafta';
    final liste = prefs.getStringList(key) ?? [];
    if (!liste.contains(gorevId)) {
      liste.add(gorevId);
      await prefs.setStringList(key, liste);
    }
  }

  // Tamamlanan görevleri geri al
  static Future<void> gorevGeriAl(String bitkiId, int hafta, String gorevId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'gorev_${bitkiId}_$hafta';
    final liste = prefs.getStringList(key) ?? [];
    liste.remove(gorevId);
    await prefs.setStringList(key, liste);
  }

  // O haftanın tamamlanan görevlerini getir
  static Future<List<String>> tamamlananGorevler(String bitkiId, int hafta) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'gorev_${bitkiId}_$hafta';
    return prefs.getStringList(key) ?? [];
  }
  /// Ana ekran için: tüm bitlerin bu haftaki görevlerini birleştirilmiş halde getirir.
/// Dönüş: [ {'gorevAd': 'Sulama', 'bitkiler': ['Domates', 'Salatalık'], 'tamamlandi': false}, ... ]
static Future<List<Map<String, dynamic>>> anaEkranGorevleriniGetir(
    List<Map<String, dynamic>> bitkiler) async {
  await yukle();

  // gorevAd → {bitkiler: [], tamamlananSayisi: 0, toplamSayi: 0}
  final Map<String, Map<String, dynamic>> gorevMap = {};
  int toplamGorev = 0;
  int toplamTamamlanan = 0;

  for (final bitki in bitkiler) {
    final bitkiId = bitki['bitki_id'] as String? ?? '';
    final hafta = bitki['hafta'] as int? ?? 1;
    final baslangic = bitki['baslangic'] as String? ?? 'tohum';
    final bitkiAd = bitki['tur'] as String? ?? bitki['ad'] as String? ?? '?';

    final gorevler = await gorevleriGetir(
        bitkiId: bitkiId, hafta: hafta, baslangic: baslangic);
    final tamamlananlar = await tamamlananGorevler(bitkiId, hafta);

    for (final g in gorevler) {
      final ad = g['ad'] as String;
      final tamamlandi = tamamlananlar.contains(g['id'] as String);
      toplamGorev++;
      if (tamamlandi) toplamTamamlanan++;

      if (!gorevMap.containsKey(ad)) {
        gorevMap[ad] = {
          'gorevAd': ad,
          'bitkiler': <String>[],
          'tamamlanmayanBitkiler': <String>[],
          'tamamTamamlandi': true,
        };
      }
      (gorevMap[ad]!['bitkiler'] as List<String>).add(bitkiAd);
      if (!tamamlandi) {
        (gorevMap[ad]!['tamamlanmayanBitkiler'] as List<String>).add(bitkiAd);
        gorevMap[ad]!['tamamTamamlandi'] = false;
      }
    }
  }

  return [
    {'__meta__': true, 'toplamGorev': toplamGorev, 'toplamTamamlanan': toplamTamamlanan},
    ...gorevMap.values.toList(),
  ];
}
}