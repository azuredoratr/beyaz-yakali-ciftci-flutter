import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:palette_generator/palette_generator.dart';
import '../main.dart';
import '../services/gorev_servisi.dart';
import '../services/bitki_servisi.dart';
import 'ana_ekran.dart';

class BitkiDetayPage extends StatefulWidget {
  final Map<String, dynamic> bitki;
  const BitkiDetayPage({super.key, required this.bitki});

  @override
  State<BitkiDetayPage> createState() => _BitkiDetayPageState();
}

class _BitkiDetayPageState extends State<BitkiDetayPage> {
  List<Map<String, dynamic>> _gorevler = [];
  List<String> _tamamlananlar = [];
  bool _yukleniyor = true;
  Color _dominantRenk = const Color(0xFF1B2D1A);
  Color _ikincilRenk = const Color(0xFF0D1A0C);

  static const _matteKart = Color(0xFFF2EBDD);
  static const _koyu = Color(0xFF24281F);

  Color get _accent => _dominantRenk;

  final List<Map<String, dynamic>> _asamalar = [
    {'isim': 'Tohum', 'emoji': '🌱'},
    {'isim': 'Fide', 'emoji': '🪴'},
    {'isim': 'Büyüme', 'emoji': '🌿'},
    {'isim': 'Çiçeklenme', 'emoji': '🌸'},
    {'isim': 'Meyve', 'emoji': '🍅'},
    {'isim': 'Hasat', 'emoji': '🧺'},
  ];

  int get _aktifAsama {
    final hafta = widget.bitki['hafta'] as int? ?? 1;
    if (hafta <= 2) return 0;
    if (hafta <= 6) return 1;
    if (hafta <= 10) return 2;
    if (hafta <= 13) return 3;
    if (hafta <= 16) return 4;
    return 5;
  }

  // Latince isim map — tur_id'den latince'ye
  static const Map<String, String> _latinceMap = {
    'salkım': 'Solanum lycopersicum',
    'silindir': 'Solanum lycopersicum',
    'cherry': 'Solanum lycopersicum var. cerasiforme',
    'beef': 'Solanum lycopersicum',
    'pembe': 'Solanum lycopersicum',
    'ayas': 'Solanum lycopersicum',
    'yumurta': 'Solanum lycopersicum',
    'datca': 'Solanum lycopersicum',
    'sivri': 'Capsicum annuum',
    'carliston': 'Capsicum annuum',
    'kapya': 'Capsicum annuum',
    'dolmalik': 'Capsicum annuum',
    'aci': 'Capsicum annuum',
    'cin': 'Capsicum annuum',
    'egzotik_aci': 'Capsicum chinense',
    'sofralik': 'Cucumis sativus',
    'tursulik': 'Cucumis sativus',
    'bodur': 'Cucumis sativus',
    'acur': 'Cucumis flexuosus',
    'kemer': 'Solanum melongena',
    'bostan': 'Solanum melongena',
    'halkapinar': 'Solanum melongena',
    'aydın_siyahi': 'Solanum melongena',
    'kirmasti': 'Solanum melongena',
    'sirik': 'Phaseolus vulgaris',
    'ayse_kadin': 'Phaseolus vulgaris',
    'seker': 'Zea mays var. saccharata',
    'cin_misir': 'Zea mays var. everta',
    'kirkagac': 'Cucumis melo',
    'yuva': 'Cucumis melo',
    'cantaloup': 'Cucumis melo var. cantalupensis',
    'uzun': 'Citrullus lanatus',
    'yuvarlak': 'Citrullus lanatus',
    'mini': 'Citrullus lanatus',
    'tohumsuz': 'Citrullus lanatus',
    'sakiz': 'Cucurbita pepo',
    'bal': 'Cucurbita moschata',
    'balkabagi': 'Cucurbita maxima',
    'zucchini': 'Cucurbita pepo var. cylindrica',
  };

  String get _latinceIsim {
    final turId = widget.bitki['tur_id'] as String?;
    if (turId == null) return '';
    return _latinceMap[turId] ?? '';
  }

  Color _zorlaKoyulastir(Color renk) {
    final hsl = HSLColor.fromColor(renk);
    return hsl
        .withLightness(0.20)
        .withSaturation((hsl.saturation * 1.2).clamp(0.0, 1.0))
        .toColor();
  }

  @override
  void initState() {
    super.initState();
    _yukle();
  }

  Future<void> _yukle() async {
    final bitkiId = widget.bitki['bitki_id'] as String? ?? '';
    final hafta = widget.bitki['hafta'] as int? ?? 1;
    final baslangic = widget.bitki['baslangic'] as String? ?? 'tohum';
    final turId = widget.bitki['tur_id'] as String?;
    final fotografYolu = turFotografGetir(turId);

    final results = await Future.wait([
      GorevServisi.gorevleriGetir(bitkiId: bitkiId, hafta: hafta, baslangic: baslangic),
      GorevServisi.tamamlananGorevler(bitkiId, hafta),
    ]);

    if (fotografYolu != null) {
      try {
        final palette = await PaletteGenerator.fromImageProvider(
          AssetImage(fotografYolu),
          size: const Size(200, 200),
        );
        if (mounted) {
          final raw1 = palette.darkVibrantColor?.color ??
              palette.vibrantColor?.color ??
              palette.dominantColor?.color ??
              const Color(0xFF2D5A27);
          final raw2 = palette.darkMutedColor?.color ??
              palette.mutedColor?.color ??
              const Color(0xFF1B4332);
          setState(() {
            _dominantRenk = _zorlaKoyulastir(raw1);
            _ikincilRenk = _zorlaKoyulastir(raw2);
          });
        }
      } catch (_) {}
    }

    if (mounted) {
      setState(() {
        _gorevler = results[0] as List<Map<String, dynamic>>;
        _tamamlananlar = results[1] as List<String>;
        _yukleniyor = false;
      });
    }
  }

  Future<void> _gorevToggle(String gorevId) async {
    final bitkiId = widget.bitki['bitki_id'] as String? ?? '';
    final hafta = widget.bitki['hafta'] as int? ?? 1;
    if (_tamamlananlar.contains(gorevId)) {
      await GorevServisi.gorevGeriAl(bitkiId, hafta, gorevId);
      setState(() => _tamamlananlar.remove(gorevId));
    } else {
      await GorevServisi.gorevTamamla(bitkiId, hafta, gorevId);
      setState(() => _tamamlananlar.add(gorevId));
    }
  }

  Future<void> _bitkiSil() async {
    final onay = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Bitkiyi Sil', style: GoogleFonts.dmSans(fontWeight: FontWeight.bold)),
        content: Text('${widget.bitki['tur']} bitkisini silmek istediğinden emin misin?', style: GoogleFonts.dmSans()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('İptal', style: GoogleFonts.dmSans())),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text('Sil', style: GoogleFonts.dmSans(color: Colors.red, fontWeight: FontWeight.bold))),
        ],
      ),
    );
    if (onay == true) {
      await BitkiServisi.bitkiSil(widget.bitki['id'] as String);
      if (mounted) Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final turId = widget.bitki['tur_id'] as String?;
    final fotografYolu = turFotografGetir(turId);
    final tur = widget.bitki['tur'] as String? ?? widget.bitki['ad'] as String? ?? '';
    final hafta = widget.bitki['hafta'] as int? ?? 1;
    final topPadding = MediaQuery.of(context).padding.top;
    final screenHeight = MediaQuery.of(context).size.height;
    final heroHeight = screenHeight * 0.36;
    final aiBtnRenk = HSLColor.fromColor(_dominantRenk).withLightness(0.24).toColor();

    return Scaffold(
      backgroundColor: const Color(0xFF17180F),
      body: Stack(
        children: [
          // 1. BG atmosphere
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg_atmosphere.png',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),

          // 2. Koyu warm gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.00),
                    Colors.black.withOpacity(0.18),
                    const Color(0xFF1E1B14).withOpacity(0.72),
                  ],
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
            ),
          ),

          // 3. Hero fotoğraf
          Positioned(
            top: 0, left: 0, right: 0,
            height: heroHeight,
            child: ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.white, Colors.white, Colors.transparent],
                stops: const [0.0, 0.50, 1.0],
              ).createShader(bounds),
              blendMode: BlendMode.dstIn,
              child: SizedBox(
                width: double.infinity,
                height: heroHeight,
                child: fotografYolu != null
                    ? ColorFiltered(
                        colorFilter: const ColorFilter.matrix([
                          0.92, 0, 0, 0, -4,
                          0, 0.92, 0, 0, -4,
                          0, 0, 0.88, 0, -6,
                          0, 0, 0, 1, 0,
                        ]),
                        child: Image.asset(fotografYolu, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(color: _accent)),
                      )
                    : Container(color: _accent),
              ),
            ),
          ),

          // 4. Hero okunabilirlik
          Positioned(
            top: 0, left: 0, right: 0,
            height: heroHeight,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.12),
                      Colors.transparent,
                      const Color(0xFF1E1B14).withOpacity(0.55),
                    ],
                    stops: const [0.0, 0.60, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // 5. İçerik
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: SizedBox(height: heroHeight * 0.62)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Latince isim
                      if (_latinceIsim.isNotEmpty)
                        Text(
                          _latinceIsim,
                          style: GoogleFonts.cormorantGaramond(
                            fontSize: 15,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withOpacity(0.72),
                            letterSpacing: 0.2,
                          ),
                        ),
                      const SizedBox(height: 2),
                      // Tür adı
                      Text(tur, style: GoogleFonts.dmSans(
                        fontSize: 29,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.0,
                        shadows: [
                          Shadow(color: Colors.black.withOpacity(0.35), blurRadius: 12, offset: const Offset(0, 4)),
                        ],
                      )),
                      // Hafta pill
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.28),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: Colors.white.withOpacity(0.24)),
                        ),
                        child: Text(
                          '$hafta. hafta · ${_asamalar[_aktifAsama]['isim']} Aşaması',
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacity(0.92),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  color: Colors.transparent,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 2, 20, 40),
                    child: Column(
                      children: [
                        _buildAsamaTimeline(),
                        const SizedBox(height: 16),
                        if (_yukleniyor)
                          const Center(child: Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(color: Colors.white),
                          ))
                        else
                          _buildGorevler(),
                        const SizedBox(height: 16),
                        _buildAltButonlar(aiBtnRenk),
                        const SizedBox(height: 180),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // 6. Geri butonu
          Positioned(
            top: topPadding + 12, left: 20,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.20),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.25), width: 1),
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
              ),
            ),
          ),

          // 7. Çöp kutusu
          Positioned(
            top: topPadding + 12, right: 20,
            child: GestureDetector(
              onTap: _bitkiSil,
              child: Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.20),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.25), width: 1),
                ),
                child: const Icon(Icons.delete_outline, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAsamaTimeline() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: BoxDecoration(
        color: _matteKart.withOpacity(0.92),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.55), width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.10), blurRadius: 24, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Gelişim Aşaması', style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w700, color: _koyu)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _asamalar.asMap().entries.map((e) {
              final i = e.key;
              final asama = e.value;
              final aktif = i == _aktifAsama;
              final gecmis = i < _aktifAsama;
              return Column(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: aktif ? _accent : gecmis ? _accent.withOpacity(0.2) : Colors.white,
                      border: Border.all(
                        color: aktif ? _accent : gecmis ? _accent.withOpacity(0.4) : _koyu.withOpacity(0.15),
                        width: aktif ? 2 : 1,
                      ),
                    ),
                    child: Center(child: Text(asama['emoji'] as String, style: TextStyle(fontSize: aktif ? 18 : 14))),
                  ),
                  const SizedBox(height: 4),
                  Text(asama['isim'] as String, style: GoogleFonts.dmSans(
                    fontSize: 9,
                    fontWeight: aktif ? FontWeight.w700 : FontWeight.normal,
                    color: aktif ? _accent : _koyu.withOpacity(0.5),
                  )),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildGorevler() {
    if (_gorevler.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _matteKart.withOpacity(0.92),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.55), width: 1),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.10), blurRadius: 24, offset: const Offset(0, 10))],
        ),
        child: Center(child: Text('Bu hafta için görev bulunamadı.',
            style: GoogleFonts.dmSans(fontSize: 13, color: _koyu.withOpacity(0.55)))),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Bu Hafta Yapılacaklar',
                style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white,
                    shadows: [Shadow(color: Colors.black.withOpacity(0.3), blurRadius: 8)])),
            Text('${_tamamlananlar.length} / ${_gorevler.length} tamamlandı',
                style: GoogleFonts.dmSans(fontSize: 12, color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: _matteKart.withOpacity(0.92),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.55), width: 1),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.10), blurRadius: 24, offset: const Offset(0, 10))],
          ),
          child: Column(
            children: _gorevler.asMap().entries.map((e) {
              final i = e.key;
              final g = e.value;
              return Column(
                children: [
                  _buildGorevSatiri(g),
                  if (i < _gorevler.length - 1)
                    Divider(height: 1, color: _koyu.withOpacity(0.08), indent: 60),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildGorevSatiri(Map<String, dynamic> gorev) {
    final gorevId = gorev['id'] as String;
    final tamamlandi = _tamamlananlar.contains(gorevId);
    final nasil = gorev['nasil_yapilir'] as String?;
    final not = gorev['not'] as String?;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => _gorevToggle(gorevId),
            child: Container(
              width: 28, height: 28,
              margin: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: tamamlandi ? _accent : Colors.white,
                border: Border.all(
                  color: tamamlandi ? _accent : _koyu.withOpacity(0.25),
                  width: 1.5,
                ),
              ),
              child: tamamlandi ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(gorev['ad'] as String, style: GoogleFonts.dmSans(
                  fontSize: 14, fontWeight: FontWeight.w600,
                  color: tamamlandi ? _koyu.withOpacity(0.4) : _koyu,
                  decoration: tamamlandi ? TextDecoration.lineThrough : null,
                  decorationColor: _koyu.withOpacity(0.4),
                )),
                if (gorev['aciklama'] != null && (gorev['aciklama'] as String).isNotEmpty)
                  Text(gorev['aciklama'] as String,
                      style: GoogleFonts.dmSans(fontSize: 11.5, height: 1.45, color: _koyu.withOpacity(0.55))),
                if (not != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text('📝 $not',
                        style: GoogleFonts.dmSans(fontSize: 11, color: _koyu.withOpacity(0.72))),
                  ),
              ],
            ),
          ),
          if (nasil != null)
            GestureDetector(
              onTap: () => _nasilYapilirGoster(gorev['ad'] as String, nasil),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _koyu.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _koyu.withOpacity(0.15)),
                ),
                child: Text('Nasıl?', style: GoogleFonts.dmSans(fontSize: 11, color: _accent, fontWeight: FontWeight.w600)),
              ),
            ),
        ],
      ),
    );
  }

  void _nasilYapilirGoster(String baslik, String icerik) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(baslik, style: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            ...icerik.split('\n').map((adim) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ', style: TextStyle(color: _accent, fontSize: 14)),
                  Expanded(child: Text(adim, style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textPrimary, height: 1.5))),
                ],
              ),
            )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildAltButonlar(Color aiBtnRenk) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: Icon(Icons.note_add_outlined, size: 16, color: _koyu),
            label: Text('Not Ekle', style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600, color: _koyu)),
            style: OutlinedButton.styleFrom(
              backgroundColor: _matteKart.withOpacity(0.90),
              foregroundColor: _koyu,
              side: BorderSide(color: Colors.white.withOpacity(0.45)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.auto_awesome, size: 16),
            label: Text('Sorun Bildir (AI)', style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600)),
            style: ElevatedButton.styleFrom(
              backgroundColor: aiBtnRenk,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              elevation: 2,
              shadowColor: Colors.black.withOpacity(0.18),
            ),
          ),
        ),
      ],
    );
  }
}