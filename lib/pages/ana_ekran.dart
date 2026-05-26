import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../main.dart';
import '../services/tercihler_servisi.dart';
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

const Map<String, Map<String, double>> sehirKoordinatlar = {
  'Adana': {'lat': 37.00, 'lon': 35.32},
  'Ankara': {'lat': 39.93, 'lon': 32.85},
  'Antalya': {'lat': 36.90, 'lon': 30.70},
  'Bursa': {'lat': 40.18, 'lon': 29.06},
  'Diyarbakır': {'lat': 37.91, 'lon': 40.23},
  'Eskişehir': {'lat': 39.78, 'lon': 30.52},
  'Gaziantep': {'lat': 37.06, 'lon': 37.38},
  'İstanbul': {'lat': 41.01, 'lon': 28.97},
  'İzmir': {'lat': 38.42, 'lon': 27.14},
  'Kayseri': {'lat': 38.73, 'lon': 35.49},
  'Konya': {'lat': 37.87, 'lon': 32.49},
  'Mersin': {'lat': 36.80, 'lon': 34.63},
  'Samsun': {'lat': 41.29, 'lon': 36.33},
  'Trabzon': {'lat': 41.00, 'lon': 39.72},
  'Van': {'lat': 38.50, 'lon': 43.38},
};

String? turFotografGetir(String? turId) {
  if (turId == null) return null;
  return turFotografMap[turId];
}

String havaDurumuEmoji(int kod) {
  if (kod == 0) return '☀️';
  if (kod <= 3) return '⛅';
  if (kod <= 48) return '☁️';
  if (kod <= 67) return '🌧️';
  if (kod <= 77) return '🌨️';
  if (kod <= 82) return '🌦️';
  return '⛈️';
}

String havaDurumuMetin(int kod) {
  if (kod == 0) return 'Açık';
  if (kod <= 3) return 'Parçalı bulutlu';
  if (kod <= 48) return 'Bulutlu';
  if (kod <= 67) return 'Yağmurlu';
  if (kod <= 77) return 'Karlı';
  if (kod <= 82) return 'Sağanak';
  return 'Fırtınalı';
}

String gunAdi(String tarih) {
  final dt = DateTime.parse(tarih);
  const gunler = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
  return gunler[dt.weekday - 1];
}

String akilliOneri(Map<String, dynamic> hava, String bahceTipi) {
  final current = hava['current'];
  final daily = hava['daily'];
  final kod = current['weathercode'] as int;
  final maxSicaklik = (daily['temperature_2m_max'][0] as num).toDouble();
  final minSicaklik = (daily['temperature_2m_min'][0] as num).toDouble();
  final yagmurlu = kod >= 51;
  final cokSicak = maxSicaklik > 35;
  final donRiski = minSicaklik < 5;
  final tarla = bahceTipi.contains('Tarla') || bahceTipi.contains('Arazi');

  if (donRiski) return '❄️ Don riski var! Fideleri içeri al, hassas bitkileri koru.';
  if (yagmurlu && tarla) return '🌧️ Yağmur var — tarlada sulama gerekmez, doğal yağış yeterli.';
  if (yagmurlu && !tarla) return '🌧️ Yağmur var — balkon/saksı bitkilerini sulamayı atla.';
  if (cokSicak) return '🌡️ Çok sıcak! Sabah erken sula, öğlen sulama yapma.';
  return '✅ Bahçe bakımı için güzel bir gün!';
}

class AnaEkranPage extends StatefulWidget {
  const AnaEkranPage({super.key});

  @override
  State<AnaEkranPage> createState() => _AnaEkranPageState();
}

class _AnaEkranPageState extends State<AnaEkranPage> {
  List<Map<String, dynamic>> _bitkiler = [
    {'id': '1', 'bitki_id': 'domates', 'ad': 'Domates', 'tur': 'Cherry Domates', 'tur_id': 'cherry', 'emoji': '🍅', 'hafta': 7, 'yuzde': 0.72},
    {'id': '2', 'bitki_id': 'salatalik', 'ad': 'Salatalık', 'tur': 'Sofralık Salatalık', 'tur_id': 'sofralik', 'emoji': '🥒', 'hafta': 4, 'yuzde': 0.45},
    {'id': '3', 'bitki_id': 'fasulye', 'ad': 'Fasulye', 'tur': 'Sırık Fasulye', 'tur_id': 'sirik', 'emoji': '🫘', 'hafta': 10, 'yuzde': 0.90},
  ];

  Map<String, dynamic>? _hava;
  bool _havaYukleniyor = true;
  String _sehir = 'Ankara';
  String _bahceTipi = 'Hobi Bahçesi';

  @override
  void initState() {
    super.initState();
    _tercihlerYukle();
  }

  Future<void> _tercihlerYukle() async {
    final sehir = await TercihlerServisi.sehirGetir();
    final bahce = await TercihlerServisi.bahceTipiGetir();
    setState(() {
      _sehir = sehir;
      _bahceTipi = bahce;
    });
    _havaGetir();
  }

  Future<void> _havaGetir() async {
    final koord = sehirKoordinatlar[_sehir] ?? sehirKoordinatlar['Ankara']!;
    final lat = koord['lat']!;
    final lon = koord['lon']!;
    try {
      final url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast'
        '?latitude=$lat&longitude=$lon'
        '&current=temperature_2m,weathercode,windspeed_10m,relativehumidity_2m'
        '&daily=temperature_2m_max,temperature_2m_min,weathercode'
        '&timezone=Europe%2FIstanbul'
        '&forecast_days=4',
      );
      final res = await http.get(url);
      if (res.statusCode == 200) {
        setState(() { _hava = jsonDecode(res.body); _havaYukleniyor = false; });
        return;
      }
    } catch (_) {}
    setState(() => _havaYukleniyor = false);
  }

  String get _selamlama {
    final saat = DateTime.now().hour;
    if (saat < 12) return 'Günaydın,';
    if (saat < 18) return 'İyi günler,';
    return 'İyi akşamlar,';
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        extendBody: true,
        backgroundColor: const Color(0xFFF0EDE8),
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset('assets/images/bg2.png', fit: BoxFit.cover),
            ),
            Positioned.fill(
              child: Container(color: Colors.white.withOpacity(0.1)),
            ),
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildHeader()),
                SliverToBoxAdapter(child: _buildHavaDurumu()),
                SliverToBoxAdapter(child: _buildAkilliOneri()),
                SliverToBoxAdapter(child: _buildBitkilerim()),
                SliverToBoxAdapter(child: _buildHaftalikGorevler()),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final topPadding = MediaQuery.of(context).padding.top;
    return Padding(
      padding: EdgeInsets.fromLTRB(24, topPadding + 20, 24, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_selamlama, style: GoogleFonts.dmSans(fontSize: 14, color: AppColors.textSecondary)),
              Row(
                children: [
                  Text('Mustafa', style: GoogleFonts.dmSans(fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                  const SizedBox(width: 8),
                  const Text('🌿', style: TextStyle(fontSize: 24)),
                ],
              ),
              Text('Bitkiler mutlu ve büyüyor.', style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textSecondary)),
            ],
          ),
          Row(
            children: [
              _buildIconBtn(Icons.notifications_outlined, () {}),
              const SizedBox(width: 8),
              _buildIconBtn(Icons.add, () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => BitkiEklePage(
                    onBitkiEklendi: (yeni) => setState(() => _bitkiler.add(yeni)),
                  ),
                ));
              }, filled: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconBtn(IconData icon, VoidCallback onTap, {bool filled = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44, height: 44,
        decoration: BoxDecoration(
          color: filled ? AppColors.primary : Colors.white.withOpacity(0.8),
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 2))],
        ),
        child: Icon(icon, size: 20, color: filled ? Colors.white : AppColors.textPrimary),
      ),
    );
  }

  Widget _buildHavaDurumu() {
  if (_havaYukleniyor) return const SizedBox(height: 80);
  if (_hava == null) return const SizedBox();

  final c = _hava!['current'];
  final sicaklik = (c['temperature_2m'] as num).round();
  final kod = c['weathercode'] as int;
  final emoji = havaDurumuEmoji(kod);
  final durum = havaDurumuMetin(kod);

  final daily = _hava!['daily'];
  final gunler = <Map<String, dynamic>>[];
  for (int i = 1; i <= 3; i++) {
    gunler.add({
      'gun': gunAdi(daily['time'][i] as String),
      'emoji': havaDurumuEmoji(daily['weathercode'][i] as int),
      'max': (daily['temperature_2m_max'][i] as num).round(),
    });
  }

  return Align(
    alignment: Alignment.centerLeft,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 0, 0),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.58 - 24,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.75),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.9), width: 1.5),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, 4))],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Sol — ikon + sıcaklık + şehir + durum
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 28)),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('$sicaklik°', style: GoogleFonts.dmSans(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.textPrimary, height: 1)),
                          Text(_sehir, style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textSecondary)),
                          Text(durum, style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Dikey çizgi
              Container(
                width: 1,
                height: 60,
                color: AppColors.cardBorder,
                margin: const EdgeInsets.symmetric(horizontal: 8),
              ),
              // Sağ — 3 günlük tahmin
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: gunler.map((g) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(g['gun'] as String, style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                        Text(g['emoji'] as String, style: const TextStyle(fontSize: 12)),
                        Text('${g['max']}°', style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      ],
                    ),
                  )).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

  Widget _buildAkilliOneri() {
    if (_hava == null) return const SizedBox();
    final oneri = akilliOneri(_hava!, _bahceTipi);

   return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 0, 0),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.58 - 24,
    child: Container(
      margin: EdgeInsets.zero,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.75),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.9), width: 1.5),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 3))],
        ),
        child: Row(
          children: [
            Container(
              width: 30, height: 30,
              decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 15),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(oneri, style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
            ),
          ],
        ),
      ),
      ),
    ),
  );
  }

  Widget _buildBitkilerim() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Bitkilerim', style: GoogleFonts.dmSans(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              Text('Tümü →', style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 24, right: 24),
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

    String asama = 'Büyüme Aşaması';
    if (hafta <= 2) asama = 'Tohum Aşaması';
    else if (hafta <= 6) asama = 'Fide Aşaması';
    else if (hafta <= 10) asama = 'Büyüme Aşaması';
    else if (hafta <= 13) asama = 'Çiçeklenme';
    else if (hafta <= 16) asama = 'Meyve Aşaması';
    else asama = 'Hasat Zamanı';

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BitkiDetayPage(bitki: bitki))),
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 16, offset: const Offset(0, 6))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            children: [
              Positioned.fill(
                child: fotografYolu != null
                    ? Image.asset(fotografYolu, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(color: const Color(0xFF1B4332),
                            child: Center(child: Text(bitki['emoji'] as String? ?? '🌱', style: const TextStyle(fontSize: 52)))))
                    : Container(color: const Color(0xFF1B4332),
                        child: Center(child: Text(bitki['emoji'] as String? ?? '🌱', style: const TextStyle(fontSize: 52)))),
              ),
              Positioned(top: 10, left: 10,
                child: Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.4), width: 1),
                  ),
                  child: const Icon(Icons.water_drop_outlined, size: 16, color: Colors.white),
                ),
              ),
              Positioned(top: 10, right: 10,
                child: Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withOpacity(0.3),
                    border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(width: 40, height: 40,
                        child: CircularProgressIndicator(
                          value: yuzde, strokeWidth: 2.5,
                          backgroundColor: Colors.white.withOpacity(0.15),
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary),
                        ),
                      ),
                      Text('${(yuzde * 100).round()}%', style: GoogleFonts.dmSans(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white)),
                    ],
                  ),
                ),
              ),
              Positioned(bottom: 0, left: 0, right: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(12, 20, 12, 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter, end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tur, style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text(asama, style: GoogleFonts.dmSans(fontSize: 10, color: Colors.white.withOpacity(0.8))),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: LinearProgressIndicator(
                          value: yuzde,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary),
                          minHeight: 4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEkleKarti() {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(
        builder: (_) => BitkiEklePage(onBitkiEklendi: (yeni) => setState(() => _bitkiler.add(yeni))),
      )),
      child: Container(
        width: 110,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 1.5),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 46, height: 46,
              decoration: BoxDecoration(
                color: AppColors.primary, shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 22),
            ),
            const SizedBox(height: 10),
            Text('Bitki\nEkle', textAlign: TextAlign.center, style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
          ],
        ),
      ),
    );
  }

  Widget _buildHaftalikGorevler() {
    final gorevler = [
      {'baslik': 'Sulama', 'bitki': 'Cherry Domates', 'durum': 'Bugün', 'tamamlandi': true, 'ikon': Icons.water_drop_outlined},
      {'baslik': 'Gübreleme', 'bitki': 'Salatalık', 'durum': 'Yarın', 'tamamlandi': false, 'ikon': Icons.eco_outlined},
      {'baslik': 'Destek Çubuğu Ekle', 'bitki': 'Cherry Domates', 'durum': '2 Gün Kaldı', 'tamamlandi': false, 'ikon': Icons.vertical_align_top},
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Bu Haftanın Görevleri', style: GoogleFonts.dmSans(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              Text('1 / 3 tamam', style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.secondary, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.75),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.9), width: 1.5),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 4))],
            ),
            child: Column(
              children: gorevler.asMap().entries.map((e) {
                final i = e.key;
                final g = e.value;
                return Column(
                  children: [
                    _buildGorevSatiri(g),
                    if (i < gorevler.length - 1)
                      Divider(height: 1, color: AppColors.cardBorder.withOpacity(0.5), indent: 68),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGorevSatiri(Map<String, dynamic> gorev) {
    final tamamlandi = gorev['tamamlandi'] as bool;
    final ikon = gorev['ikon'] as IconData;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: tamamlandi ? AppColors.secondary.withOpacity(0.12) : Colors.white.withOpacity(0.6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(ikon, size: 18, color: tamamlandi ? AppColors.secondary : AppColors.textSecondary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(gorev['baslik'] as String, style: GoogleFonts.dmSans(
                  fontSize: 14, fontWeight: FontWeight.w600,
                  color: tamamlandi ? AppColors.textSecondary : AppColors.textPrimary,
                  decoration: tamamlandi ? TextDecoration.lineThrough : null,
                )),
                Text(gorev['bitki'] as String, style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Text(gorev['durum'] as String, style: GoogleFonts.dmSans(
            fontSize: 12,
            color: tamamlandi ? AppColors.secondary : AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          )),
          const SizedBox(width: 10),
          Container(
            width: 24, height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: tamamlandi ? AppColors.secondary : Colors.transparent,
              border: Border.all(color: tamamlandi ? AppColors.secondary : AppColors.cardBorder, width: 1.5),
            ),
            child: tamamlandi ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
          ),
        ],
      ),
    );
  }
}