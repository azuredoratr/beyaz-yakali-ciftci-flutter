import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../main.dart';
import '../services/tercihler_servisi.dart';
import '../services/bitki_servisi.dart';
import 'bitki_ekle.dart';
import 'bitki_detay.dart';

const Map<String, String> turFotografMap = {
  'salkım': 'assets/images/salkım_domates.png',
  'silindir': 'assets/images/silindir_domates.png',
  'cherry': 'assets/images/cherry_domates.png',
  'beef': 'assets/images/beef_domates.png',
  'pembe': 'assets/images/pembe_domates.png',
  'ayas': 'assets/images/ayas_domatesi.png',
  'yumurta': 'assets/images/yumurta_domates.png',
  'datca': 'assets/images/datca_bogma_domates.png',
  'sivri': 'assets/images/sivri_biber.png',
  'carliston': 'assets/images/carliston_biber.png',
  'kapya': 'assets/images/kapya_biber.png',
  'dolmalik': 'assets/images/dolmalik_biber.png',
  'aci': 'assets/images/aci_biber.png',
  'cin': 'assets/images/cin_biberi.png',
  'egzotik_aci': 'assets/images/egzotik_aci_biberler.png',
  'sofralik': 'assets/images/sofralik_salatalik.png',
  'tursulik': 'assets/images/tursuluk_salatalik.png',
  'bodur': 'assets/images/bodur_salatalik.png',
  'acur': 'assets/images/acur.png',
  'kemer': 'assets/images/kemer_patlican.png',
  'bostan': 'assets/images/bostan_patlicani.png',
  'halkapinar': 'assets/images/halkapinar_patlicani.png',
  'aydın_siyahi': 'assets/images/aydin_siyahi.png',
  'kirmasti': 'assets/images/kirmasti_patlicani.png',
  'sirik': 'assets/images/sirik_fasulye.png',
  'ayse_kadin': 'assets/images/aysekadin_fasulyesi.png',
  'seker': 'assets/images/seker_misiri.png',
  'cin_misir': 'assets/images/cin_misiri.png',
  'kirkagac': 'assets/images/kirkaagac_kavunu.png',
  'yuva': 'assets/images/yuva_kavunu.png',
  'cantaloup': 'assets/images/kantalup_kavun.png',
  'uzun': 'assets/images/uzun_karpuz.png',
  'yuvarlak': 'assets/images/yuvarlak_karpuz.png',
  'mini': 'assets/images/mini_karpuz.png',
  'tohumsuz': 'assets/images/tohumsuz_karpuz.png',
  'sakiz': 'assets/images/sakiz_kabagi.png',
  'bal': 'assets/images/bal_kabagi.png',
  'balkabagi': 'assets/images/kara_kabak.png',
  'zucchini': 'assets/images/zucchini.png',
};

String? turFotografGetir(String? turId) {
  if (turId == null) return null;
  return turFotografMap[turId];
}

String heroImajGetir(String bahceTipi) {
  final saat = DateTime.now().hour;
  final String zaman;
  if (saat >= 5 && saat < 11) {
    zaman = 'sabah';
  } else if (saat >= 11 && saat < 16) {
    zaman = 'oglen';
  } else if (saat >= 16 && saat < 20) {
    zaman = 'aksam';
  } else {
    zaman = 'gece';
  }

  final String tip;
  final bt = bahceTipi.toLowerCase();
  if (bt.contains('tarla') || bt.contains('arazi')) {
    tip = 'tarla';
  } else if (bt.contains('saksı') || bt.contains('saksi') || bt.contains('balkon') || bt.contains('ev')) {
    tip = 'saksi';
  } else {
    tip = 'bahce';
  }

  return 'assets/images/hero_${tip}_$zaman.png';
}

String havaDurumuEmoji(int kod) {
  if (kod == 0) return '☀️';
  if (kod <= 3) return '⛅';
  if (kod <= 48) return '☁️';
  if (kod <= 67) return '🌧️';
  if (kod <= 77) return '❄️';
  return '⛈️';
}

String havaDurumuMetin(int kod) {
  if (kod == 0) return 'Açık';
  if (kod <= 3) return 'Parçalı bulutlu';
  if (kod <= 48) return 'Bulutlu';
  if (kod <= 67) return 'Yağmurlu';
  if (kod <= 77) return 'Karlı';
  return 'Fırtınalı';
}

String akilliOneri(Map<String, dynamic> hava, String bahceTipi) {
  final c = hava['current'];
  final kod = c['weathercode'] as int;
  final sicaklik = (c['temperature_2m'] as num).toDouble();
  if (sicaklik < 2) return 'Don riski var!';
  if (kod >= 51 && kod <= 67) return 'Yağmur bekleniyor, sulama gerek yok.';
  if (sicaklik > 34) return 'Çok sıcak, sabah erken sulama önerilir.';
  return 'Bahçe bakımı için güzel bir gün!';
}

const Map<String, Map<String, double>> sehirKoordinatlar = {
  'Ankara': {'lat': 39.93, 'lon': 32.85},
  'İstanbul': {'lat': 41.01, 'lon': 28.95},
  'İzmir': {'lat': 38.42, 'lon': 27.14},
  'Antalya': {'lat': 36.90, 'lon': 30.70},
  'Bursa': {'lat': 40.18, 'lon': 29.06},
  'Eskişehir': {'lat': 39.78, 'lon': 30.52},
  'Konya': {'lat': 37.87, 'lon': 32.49},
  'Adana': {'lat': 37.00, 'lon': 35.32},
  'Gaziantep': {'lat': 37.06, 'lon': 37.38},
  'Mersin': {'lat': 36.80, 'lon': 34.63},
  'Diyarbakır': {'lat': 37.91, 'lon': 40.23},
  'Kayseri': {'lat': 38.73, 'lon': 35.49},
  'Samsun': {'lat': 41.29, 'lon': 36.33},
  'Trabzon': {'lat': 41.00, 'lon': 39.72},
  'Van': {'lat': 38.50, 'lon': 43.38},
};

class AnaEkranPage extends StatefulWidget {
  const AnaEkranPage({super.key});

  @override
  State<AnaEkranPage> createState() => _AnaEkranPageState();
}

class _AnaEkranPageState extends State<AnaEkranPage> {
  List<Map<String, dynamic>> _bitkiler = [];
  Map<String, dynamic>? _hava;
  bool _havaYukleniyor = true;
  String _sehir = 'Ankara';
  String _bahceTipi = 'bahce';

  @override
  void initState() {
    super.initState();
    _yukle();
  }

  Future<void> _yukle() async {
    final sehir = await TercihlerServisi.sehirGetir();
    final bahce = await TercihlerServisi.bahceTipiGetir();
    final bitkiler = await BitkiServisi.bitkileriGuncelleVeGetir();
    setState(() {
      _sehir = sehir;
      _bahceTipi = bahce;
      _bitkiler = bitkiler;
    });
    await _havaGetir();
  }

  Future<void> _havaGetir() async {
    final koord = sehirKoordinatlar[_sehir] ?? sehirKoordinatlar['Ankara']!;
    try {
      final url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast'
        '?latitude=${koord['lat']}&longitude=${koord['lon']}'
        '&current=temperature_2m,weathercode,windspeed_10m,relativehumidity_2m'
        '&timezone=Europe%2FIstanbul',
      );
      final res = await http.get(url);
      if (res.statusCode == 200) {
        if (mounted) setState(() { _hava = jsonDecode(res.body); _havaYukleniyor = false; });
        return;
      }
    } catch (_) {}
    if (mounted) setState(() => _havaYukleniyor = false);
  }

  String get _selamlama {
    final saat = DateTime.now().hour;
    if (saat < 12) return 'Günaydın,';
    if (saat < 18) return 'İyi günler,';
    return 'İyi akşamlar,';
  }

  String _icgoruBasligi(String oneri) {
    if (oneri.contains('Don')) return 'Don riski var.';
    if (oneri.contains('Yağmur')) return 'Sulamayı erteleyebilirsin.';
    if (oneri.contains('sıcak')) return 'Sabah erken sulama önerilir.';
    return 'Bugün sulama için uygun.';
  }

  String _icgoruAciklama(String oneri) {
    if (oneri.contains('Don')) return 'Fideleri koru, hassas bitkileri içeri al.';
    if (oneri.contains('Yağmur')) return 'Doğal yağış toprağı destekleyecek.';
    if (oneri.contains('sıcak')) return 'Öğlen sulama yapma. Buharlaşma yüksek.';
    return 'Toprak nemi ideal. Akşam sulaması önerilir.';
  }

  String _gorevOraniText(Map<String, dynamic> bitki) {
    final yuzde = (bitki['yuzde'] as double?) ?? 0.5;
    if (yuzde >= 0.95) return '3/3';
    if (yuzde >= 0.65) return '2/3';
    if (yuzde >= 0.35) return '1/3';
    return '0/3';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E9),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeroHeader()),
          SliverToBoxAdapter(child: _buildBahceIcGorusu()),
          SliverToBoxAdapter(child: _buildBitkilerim()),
          SliverToBoxAdapter(child: _buildAltBolumler()),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }

  // ── HERO HEADER ─────────────────────────────────────────────
  Widget _buildHeroHeader() {
    final topPadding = MediaQuery.of(context).padding.top;
    final heroHeight = MediaQuery.of(context).size.height * 0.30;

    return SizedBox(
      height: heroHeight,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              heroImajGetir(_bahceTipi),
              fit: BoxFit.cover,
              alignment: const Alignment(-0.2, -0.6),
              errorBuilder: (_, __, ___) => Container(color: AppColors.primary),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.08),
                    Colors.black.withOpacity(0.15),
                    const Color(0xFFF5F1E9),
                  ],
                  stops: const [0.0, 0.60, 1.0],
                ),
              ),
            ),
          ),
          Positioned(
            top: topPadding + 10,
            left: 24,
            right: 24,
            child: Row(
              children: [
                const Icon(Icons.location_on_outlined, color: Colors.white, size: 16),
                const SizedBox(width: 4),
                Text(_sehir, style: GoogleFonts.dmSans(
                  color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 16),
                const Spacer(),
                _buildHeroIconBtn(Icons.notifications_outlined, () {}),
                const SizedBox(width: 10),
                _buildHeroIconBtn(Icons.add, () async {
                  await Navigator.push(context, MaterialPageRoute(
                    builder: (_) => BitkiEklePage(onBitkiEklendi: (yeni) async {
                      await BitkiServisi.bitkiEkle(yeni);
                      final liste = await BitkiServisi.bitkileriGuncelleVeGetir();
                      if (mounted) setState(() => _bitkiler = liste);
                    }),
                  ));
                }, filled: true),
              ],
            ),
          ),
          Positioned(
            left: 24, right: 24, bottom: 60,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_selamlama, style: GoogleFonts.dmSans(
                  fontSize: 15, fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.92))),
                Text('Mustafa 🌿', style: GoogleFonts.cormorantGaramond(
                  fontSize: 48, fontWeight: FontWeight.w700,
                  color: Colors.white, height: 1.0)),
                const SizedBox(height: 5),
                Text(
                  _bitkiler.isEmpty ? 'Henüz bitki eklemedin.' : 'Bitkiler mutlu, hasat yakın.',
                  style: GoogleFonts.dmSans(
                    fontSize: 13, fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.90)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroIconBtn(IconData icon, VoidCallback onTap, {bool filled = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: filled ? AppColors.primary : Colors.white.withOpacity(0.88),
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Icon(icon, size: 19, color: filled ? Colors.white : AppColors.textPrimary),
      ),
    );
  }

  // ── BAHÇE İÇGÖRÜSÜ ─────────────────────────────────────────
  Widget _buildBahceIcGorusu() {
    if (_havaYukleniyor) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.94),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 18, offset: const Offset(0, 8))],
          ),
          child: const Center(child: CircularProgressIndicator()),
        ),
      );
    }
    if (_hava == null) return const SizedBox();

    final c = _hava!['current'];
    final sicaklik = (c['temperature_2m'] as num).round();
    final kod = c['weathercode'] as int;
    final emoji = havaDurumuEmoji(kod);
    final durum = havaDurumuMetin(kod);
    final oneri = akilliOneri(_hava!, _bahceTipi);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.96),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: Colors.white, width: 1.2),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 24, offset: const Offset(0, 10)),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sol: sıcaklık
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('BAHÇE İÇGÖRÜSÜ', style: GoogleFonts.dmSans(
                  fontSize: 10, fontWeight: FontWeight.w800,
                  letterSpacing: 1.2, color: AppColors.primary)),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('$sicaklik°', style: GoogleFonts.dmSans(
                      fontSize: 38, fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary, height: 1.0)),
                    const SizedBox(width: 6),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Text(emoji, style: const TextStyle(fontSize: 22))),
                  ],
                ),
                Text(durum, style: GoogleFonts.dmSans(
                  fontSize: 12, color: AppColors.textSecondary)),
                Text(_sehir, style: GoogleFonts.dmSans(
                  fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
            // Dikey ayraç
            Container(
              width: 1, height: 90,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              color: AppColors.cardBorder,
            ),
            // Sağ: içgörü
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_icgoruBasligi(oneri), style: GoogleFonts.dmSans(
                    fontSize: 13, fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary, height: 1.25)),
                  const SizedBox(height: 6),
                  Text(_icgoruAciklama(oneri), style: GoogleFonts.dmSans(
                    fontSize: 12, height: 1.45,
                    color: AppColors.textPrimary.withOpacity(0.62))),
                  const SizedBox(height: 8),
                  Row(children: [
                    Text('Detayı gör', style: GoogleFonts.dmSans(
                      fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primary)),
                    const SizedBox(width: 3),
                    Icon(Icons.arrow_forward, size: 13, color: AppColors.primary),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── BİTKİLERİM ──────────────────────────────────────────────
  Widget _buildBitkilerim() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Bitkilerim', style: GoogleFonts.dmSans(
                fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              Text('Tümü →', style: GoogleFonts.dmSans(
                fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 10),
          child: Text(
            '${_bitkiler.length} aktif bitki · 2 görev · 1 uyarı',
            style: GoogleFonts.dmSans(
              fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
          ),
        ),
        SizedBox(
          height: 188,
          child: _bitkiler.isEmpty
              ? Center(child: Padding(
                  padding: const EdgeInsets.only(left: 24),
                  child: _buildEkleKarti()))
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(left: 24),
                  itemCount: _bitkiler.length + 1,
                  itemBuilder: (context, index) {
                    if (index == _bitkiler.length) return _buildEkleKarti();
                    return _buildBitkiKarti(_bitkiler[index]);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildBitkiKarti(Map<String, dynamic> bitki) {
    final turId = bitki['tur_id'] as String?;
    final fotografYolu = turFotografGetir(turId);
    final yuzde = (bitki['yuzde'] as double?) ?? 0.5;
    final hafta = bitki['hafta'] as int? ?? 1;
    final tur = bitki['tur'] as String? ?? bitki['ad'] as String;

    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(context,
          MaterialPageRoute(builder: (_) => BitkiDetayPage(bitki: bitki)));
        if (result == true) _yukle();
      },
      child: Container(
        width: 142,
        margin: const EdgeInsets.only(right: 12, bottom: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.20), blurRadius: 16, offset: const Offset(0, 8))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            children: [
              Positioned.fill(
                child: fotografYolu != null
                    ? Image.asset(fotografYolu, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(color: const Color(0xFF1B4332),
                          child: Center(child: Text(bitki['emoji'] as String? ?? '🌱',
                            style: const TextStyle(fontSize: 44)))))
                    : Container(color: const Color(0xFF1B4332),
                        child: Center(child: Text(bitki['emoji'] as String? ?? '🌱',
                          style: const TextStyle(fontSize: 44))))),
              Positioned.fill(child: Container(decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                  colors: [Colors.white.withOpacity(0.07), Colors.transparent, Colors.black.withOpacity(0.08)],
                  stops: const [0.0, 0.5, 1.0])))),
              Positioned(top: 0, left: 0, right: 0, height: 60,
                child: Container(decoration: BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
                    colors: [Colors.white.withOpacity(0.18), Colors.transparent])))),
              Positioned.fill(child: Container(decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.white.withOpacity(0.20), width: 1.5)))),
              Positioned(top: 10, left: 10,
                child: Container(width: 26, height: 26,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.22), shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.35))),
                  child: const Icon(Icons.water_drop_outlined, size: 13, color: Colors.white))),
              Positioned(top: 10, right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.40),
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(color: Colors.white.withOpacity(0.18))),
                  child: Text('Hf $hafta', style: GoogleFonts.dmSans(
                    fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white)))),
              Positioned(bottom: 10, left: 10, right: 10,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.38),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withOpacity(0.14), width: 1)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(tur, style: GoogleFonts.dmSans(
                      fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 5),
                    Row(children: [
                      Expanded(child: ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: LinearProgressIndicator(
                          value: yuzde,
                          backgroundColor: Colors.white.withOpacity(0.20),
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary),
                          minHeight: 4))),
                      const SizedBox(width: 7),
                      Text(_gorevOraniText(bitki), style: GoogleFonts.dmSans(
                        fontSize: 10, fontWeight: FontWeight.w800,
                        color: Colors.white.withOpacity(0.90))),
                    ]),
                  ]),
                )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEkleKarti() {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(
        builder: (_) => BitkiEklePage(onBitkiEklendi: (yeni) async {
          await BitkiServisi.bitkiEkle(yeni);
          final liste = await BitkiServisi.bitkileriGuncelleVeGetir();
          if (mounted) setState(() => _bitkiler = liste);
        }))),
      child: Container(
        width: 96, height: 188,
        margin: const EdgeInsets.only(right: 24, bottom: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.primary.withOpacity(0.18), width: 1.5),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(width: 44, height: 44,
            decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.28), blurRadius: 12, offset: const Offset(0, 4))]),
            child: const Icon(Icons.add, color: Colors.white, size: 22)),
          const SizedBox(height: 10),
          Text('Bitki\nEkle', textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
        ]),
      ),
    );
  }

  // ── ALT BÖLÜMLER ─────────────────────────────────────────────
  Widget _buildAltBolumler() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildHaftalikGorevlerKarti()),
          const SizedBox(width: 14),
          Expanded(child: _buildSeyirDefterimKarti()),
        ],
      ),
    );
  }

  Widget _buildHaftalikGorevlerKarti() {
    final gorevler = [
      {'baslik': 'Sulama', 'tamamlandi': true},
      {'baslik': 'Gübreleme', 'tamamlandi': false},
      {'baslik': 'Destek Çubuğu', 'tamamlandi': false},
    ];
    final tamamlanan = gorevler.where((g) => g['tamamlandi'] as bool).length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.90),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.95), width: 1.2),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 18, offset: const Offset(0, 7))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text('BU HAFTA', style: GoogleFonts.dmSans(
            fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.1, color: AppColors.primary))),
          Text('$tamamlanan/${gorevler.length}', style: GoogleFonts.dmSans(
            fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.secondary)),
        ]),
        const SizedBox(height: 12),
        ...gorevler.asMap().entries.map((e) {
          final i = e.key;
          final g = e.value;
          final tamamlandi = g['tamamlandi'] as bool;
          return Padding(
            padding: EdgeInsets.only(bottom: i < gorevler.length - 1 ? 10 : 0),
            child: Row(children: [
              Container(width: 22, height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: tamamlandi ? AppColors.secondary : Colors.transparent,
                  border: Border.all(color: tamamlandi ? AppColors.secondary : AppColors.cardBorder, width: 1.5)),
                child: tamamlandi ? const Icon(Icons.check, size: 12, color: Colors.white) : null),
              const SizedBox(width: 8),
              Expanded(child: Text(g['baslik'] as String, style: GoogleFonts.dmSans(
                fontSize: 12, fontWeight: FontWeight.w600,
                color: tamamlandi ? AppColors.textSecondary : AppColors.textPrimary,
                decoration: tamamlandi ? TextDecoration.lineThrough : null),
                maxLines: 1, overflow: TextOverflow.ellipsis)),
            ]),
          );
        }),
      ]),
    );
  }

  Widget _buildSeyirDefterimKarti() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.86),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.95), width: 1.2),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 18, offset: const Offset(0, 7))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text('SEYİR DEFTERİM', style: GoogleFonts.dmSans(
            fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.1, color: AppColors.primary))),
          Text('Tümü →', style: GoogleFonts.dmSans(
            fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary)),
        ]),
        const SizedBox(height: 10),
        Text('16 Mayıs · 19:20', style: GoogleFonts.dmSans(
          fontSize: 11, color: AppColors.textSecondary)),
        const SizedBox(height: 5),
        Text('Domateslerde ilk\nçiçek salkımları.', style: GoogleFonts.cormorantGaramond(
          fontSize: 17, fontWeight: FontWeight.w700,
          color: AppColors.textPrimary, height: 1.15)),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset('assets/images/pembe_domates.png',
            height: 68, width: double.infinity, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(height: 68,
              decoration: BoxDecoration(color: AppColors.cardBorder,
                borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.image_outlined, color: Colors.white54))),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () {},
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 9),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12)),
            child: Text('✎ Yeni kayıt ekle', textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
          ),
        ),
      ]),
    );
  }
}