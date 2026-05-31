import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';
import '../services/bitki_servisi.dart';
import 'ana_ekran.dart';

class TakvimPage extends StatefulWidget {
  const TakvimPage({super.key});

  @override
  State<TakvimPage> createState() => _TakvimPageState();
}

class _TakvimPageState extends State<TakvimPage> {
  List<Map<String, dynamic>> _bitkiler = [];
  bool _yukleniyor = true;
  String _filtre = 'Tümü';

  static const List<String> _asamaIsimleri = [
    'Tohum', 'Fide', 'Büyüme', 'Çiçek', 'Meyve', 'Hasat'
  ];
  static const List<String> _filtreler = ['Tümü', 'Yakın Hasat'];

  static const Color _koyu = Color(0xFF24281F);
  static const Color _zeytinKoyu = Color(0xFF2D5A27);
  static const Color _zeytinAcik = Color(0xFFE8F0E0);
  static const Color _kagit = Color(0xFFF5F1E9);
  static const Color _sinir = Color(0xFFE8E2D8);

  @override
  void initState() {
    super.initState();
    _yukle();
  }

  Future<void> _yukle() async {
    final bitkiler = await BitkiServisi.bitkileriGuncelleVeGetir();
    if (mounted) setState(() { _bitkiler = bitkiler; _yukleniyor = false; });
  }

  int _aktifAsamaIndex(int hafta) {
    if (hafta <= 2) return 0;
    if (hafta <= 6) return 1;
    if (hafta <= 10) return 2;
    if (hafta <= 13) return 3;
    if (hafta <= 16) return 4;
    return 5;
  }

  int _toplamHafta(Map<String, dynamic> b) => (b['toplam_hafta'] as int?) ?? 18;

  int _kalanHafta(Map<String, dynamic> b) {
    final hafta = (b['hafta'] as int?) ?? 1;
    return (_toplamHafta(b) - hafta).clamp(0, 999);
  }

  double _ilerleme(Map<String, dynamic> b) {
    final hafta = (b['hafta'] as int?) ?? 1;
    return (hafta / _toplamHafta(b)).clamp(0.0, 1.0);
  }

  List<Map<String, dynamic>> _filtreliListe() {
    final sirali = List<Map<String, dynamic>>.from(_bitkiler)
      ..sort((a, b) => _kalanHafta(a).compareTo(_kalanHafta(b)));
    if (_filtre == 'Yakın Hasat') return sirali.where((b) => _kalanHafta(b) <= 6).toList();
    return sirali;
  }

  List<Map<String, dynamic>> _yaklasanlar() {
    final liste = <Map<String, dynamic>>[];
    for (final b in _bitkiler) {
      final kalan = _kalanHafta(b);
      final aktif = _aktifAsamaIndex((b['hafta'] as int?) ?? 1);
      final tur = b['tur'] as String? ?? b['ad'] as String? ?? '';
      final turId = b['tur_id'] as String?;
      if (kalan == 0) {
        liste.add({'metin': 'Hasat zamanı geldi', 'bitki': tur, 'gun': 0, 'turId': turId});
      } else if (kalan <= 2) {
        liste.add({'metin': 'Hasat yaklaşıyor', 'bitki': tur, 'gun': kalan * 7, 'turId': turId});
      } else if (aktif < 5) {
        final sonraki = _asamaIsimleri[aktif + 1];
        final gecisHafta = _asamaGecisHafta(aktif);
        final buHafta = (b['hafta'] as int?) ?? 1;
        final kalanGecis = ((gecisHafta - buHafta) * 7).clamp(1, 999);
        liste.add({'metin': '$sonraki aşaması başlayacak', 'bitki': tur, 'gun': kalanGecis, 'turId': turId});
      }
    }
    liste.sort((a, b) => (a['gun'] as int).compareTo(b['gun'] as int));
    return liste.take(5).toList();
  }

  int _asamaGecisHafta(int asama) {
    const gecisler = [2, 6, 10, 13, 16, 20];
    return asama + 1 < gecisler.length ? gecisler[asama + 1] : 20;
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: _kagit,
      body: _yukleniyor
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildHeader(topPadding)),
                SliverToBoxAdapter(child: _buildHeroKart()),
                SliverToBoxAdapter(child: _buildYaklasanlar()),
                SliverToBoxAdapter(child: _buildBitkiListesi()),
                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            ),
    );
  }

  // ── HEADER ───────────────────────────────────────────────────
  Widget _buildHeader(double topPadding) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24, topPadding + 24, 24, 0),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Sezon Takvimi', style: GoogleFonts.cormorantGaramond(
            fontSize: 34, fontWeight: FontWeight.w700, color: _koyu, height: 1.0)),
          const SizedBox(height: 4),
          Text('2026 sezonu · Ankara', style: GoogleFonts.dmSans(
            fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
        ])),
        GestureDetector(
          onTap: _filtrePanelAc,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: _filtre != 'Tümü' ? _zeytinAcik : Colors.white.withOpacity(0.88),
              borderRadius: BorderRadius.circular(99),
              border: Border.all(
                color: _filtre != 'Tümü' ? _zeytinKoyu.withOpacity(0.25) : _sinir),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 3))],
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.tune_rounded, size: 14,
                color: _filtre != 'Tümü' ? _zeytinKoyu : AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(_filtre, style: GoogleFonts.dmSans(
                fontSize: 12, fontWeight: FontWeight.w600,
                color: _filtre != 'Tümü' ? _zeytinKoyu : AppColors.textSecondary)),
            ]),
          ),
        ),
      ]),
    );
  }

  void _filtrePanelAc() {
    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 36, height: 4, margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(color: _sinir, borderRadius: BorderRadius.circular(99)))),
          Text('Filtrele', style: GoogleFonts.dmSans(
            fontSize: 16, fontWeight: FontWeight.w800, color: _koyu)),
          const SizedBox(height: 14),
          ..._filtreler.map((f) => GestureDetector(
            onTap: () { setState(() => _filtre = f); Navigator.pop(ctx); },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: _filtre == f ? _zeytinAcik : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _filtre == f ? _zeytinKoyu.withOpacity(0.25) : _sinir)),
              child: Text(f, style: GoogleFonts.dmSans(
                fontSize: 13, fontWeight: FontWeight.w600,
                color: _filtre == f ? _zeytinKoyu : _koyu)),
            ),
          )),
        ]),
      ),
    );
  }

  // ── HERO KART ────────────────────────────────────────────────
  Widget _buildHeroKart() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
      child: Container(
        height: 148,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Image.asset(
            'assets/images/hero_takvim.png',
            fit: BoxFit.cover,
            alignment: const Alignment(0.0, -0.2),
            errorBuilder: (_, __, ___) => Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    _zeytinKoyu.withOpacity(0.25),
                    _zeytinAcik,
                    _zeytinKoyu.withOpacity(0.15)])),
              child: const Center(child: Text('🌱 → 🌿 → 🧺',
                style: TextStyle(fontSize: 28, letterSpacing: 8)))),
          ),
        ),
      ),
    );
  }

  // ── YAKLAŞANLAR ──────────────────────────────────────────────
  Widget _buildYaklasanlar() {
    final liste = _yaklasanlar();
    if (liste.isEmpty) return const SizedBox(height: 8);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: _sinir.withOpacity(0.7)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 7))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('YAKLAŞANLAR', style: GoogleFonts.dmSans(
            fontSize: 10, fontWeight: FontWeight.w800,
            letterSpacing: 1.2, color: _zeytinKoyu)),
          const SizedBox(height: 16),
          ...liste.asMap().entries.map((e) {
            final i = e.key;
            final item = e.value;
            final gun = item['gun'] as int;
            final zamanMetni = gun == 0
                ? 'Bu hafta'
                : gun <= 6
                    ? '$gun gün sonra'
                    : gun <= 13
                        ? '${(gun / 7).ceil()} hafta sonra'
                        : '$gun gün sonra';
            final vurgu = gun <= 7;

            return Column(children: [
              if (i > 0) Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Divider(color: _sinir.withOpacity(0.6), height: 1)),
              Row(children: [
                // Zaman badge
                Container(
                  width: 82,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: vurgu ? _zeytinAcik : _sinir.withOpacity(0.40),
                    borderRadius: BorderRadius.circular(10)),
                  child: Text(zamanMetni, textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(
                      fontSize: 10, fontWeight: FontWeight.w700,
                      color: vurgu ? _zeytinKoyu : AppColors.textSecondary)),
                ),
                const SizedBox(width: 14),
                // İçerik — ikon yok
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(item['bitki'] as String, style: GoogleFonts.dmSans(
                    fontSize: 13, fontWeight: FontWeight.w700, color: _koyu)),
                  const SizedBox(height: 2),
                  Text(item['metin'] as String, style: GoogleFonts.dmSans(
                    fontSize: 11.5, color: AppColors.textSecondary, height: 1.3)),
                ])),
              ]),
            ]);
          }),
        ]),
      ),
    );
  }

  // ── BİTKİ LİSTESİ ────────────────────────────────────────────
  Widget _buildBitkiListesi() {
    final liste = _filtreliListe();
    if (liste.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.90),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _sinir)),
          child: Center(child: Text(
            _filtre == 'Yakın Hasat' ? 'Yakın hasatlı bitki yok.' : 'Henüz bitki eklemedin.',
            style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textSecondary)))));
    }
    return Column(children: liste.map((b) => Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: _buildBitkiKarti(b),
    )).toList());
  }

  Widget _buildBitkiKarti(Map<String, dynamic> bitki) {
    final tur = bitki['tur'] as String? ?? bitki['ad'] as String? ?? 'Bitki';
    final turId = bitki['tur_id'] as String?;
    final fotografYolu = turFotografGetir(turId);
    final hafta = (bitki['hafta'] as int?) ?? 1;
    final toplam = _toplamHafta(bitki);
    final kalan = _kalanHafta(bitki);
    final aktif = _aktifAsamaIndex(hafta);
    final ilerleme = _ilerleme(bitki);
    final asamaAdi = _asamaIsimleri[aktif.clamp(0, _asamaIsimleri.length - 1)];

    final kalanRenk = kalan == 0
        ? _zeytinKoyu
        : kalan <= 2
            ? const Color(0xFFB85C2C)
            : kalan <= 5
                ? const Color(0xFF8A7340)
                : AppColors.textSecondary;
    final kalanBg = kalan == 0
        ? _zeytinAcik
        : kalan <= 2
            ? const Color(0xFFFFF3ED)
            : kalan <= 5
                ? const Color(0xFFFFF9ED)
                : _kagit.withOpacity(0.7);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _sinir.withOpacity(0.7)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 18, offset: const Offset(0, 6))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // ── Üst: foto + bilgi ──────────────────────────────
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Fotoğraf — %25 büyük: 125x125
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              width: 125, height: 125,
              child: fotografYolu != null
                  ? Image.asset(fotografYolu, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _fotoPH(bitki))
                  : _fotoPH(bitki),
            ),
          ),
          const SizedBox(width: 14),
          // Bilgi
          Expanded(child: SizedBox(height: 125, child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // İsim + badge
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(tur, style: GoogleFonts.dmSans(
                  fontSize: 15, fontWeight: FontWeight.w800, color: _koyu),
                  maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text('$hafta. hafta · $toplam haftalık süreç',
                  style: GoogleFonts.dmSans(
                    fontSize: 11, color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                // Aktif aşama badge — belirgin
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _zeytinKoyu,
                    borderRadius: BorderRadius.circular(99)),
                  child: Text(asamaAdi, style: GoogleFonts.dmSans(
                    fontSize: 11, fontWeight: FontWeight.w700,
                    color: Colors.white)),
                ),
              ]),
              // Hasada kalan
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: kalanBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: kalanRenk.withOpacity(0.15))),
                child: Row(children: [
                  Icon(Icons.hourglass_bottom_outlined, size: 12, color: kalanRenk),
                  const SizedBox(width: 6),
                  Expanded(child: Text(
                    kalan == 0
                        ? 'Hasat zamanı!'
                        : kalan == 1
                            ? '1 hafta kaldı'
                            : '$kalan hafta kaldı',
                    style: GoogleFonts.dmSans(
                      fontSize: 11.5, fontWeight: FontWeight.w700, color: kalanRenk))),
                  Text('%${(ilerleme * 100).round()}',
                    style: GoogleFonts.dmSans(
                      fontSize: 10.5, fontWeight: FontWeight.w600,
                      color: kalanRenk.withOpacity(0.60))),
                ]),
              ),
            ],
          ))),
        ]),

        const SizedBox(height: 14),

        // ── Progress bar ───────────────────────────────────
        Stack(children: [
          Container(height: 3, decoration: BoxDecoration(
            color: _sinir, borderRadius: BorderRadius.circular(99))),
          FractionallySizedBox(
            widthFactor: ilerleme,
            child: Container(height: 3, decoration: BoxDecoration(
              color: _zeytinKoyu, borderRadius: BorderRadius.circular(99)))),
        ]),

        const SizedBox(height: 7),

        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Başlangıç', style: GoogleFonts.dmSans(
            fontSize: 9, color: _sinir, fontWeight: FontWeight.w500)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(color: _zeytinAcik, borderRadius: BorderRadius.circular(5)),
            child: Text('Bugün', style: GoogleFonts.dmSans(
              fontSize: 9, fontWeight: FontWeight.w700, color: _zeytinKoyu))),
          Text('Hasat', style: GoogleFonts.dmSans(
            fontSize: 9, color: _sinir, fontWeight: FontWeight.w500)),
        ]),

        const SizedBox(height: 14),

        // ── Timeline ───────────────────────────────────────
        _buildTimeline(aktif),
      ]),
    );
  }

  Widget _fotoPH(Map<String, dynamic> bitki) {
    return Container(
      color: _zeytinAcik,
      child: Center(child: Text(
        bitki['emoji'] as String? ?? '🌱',
        style: const TextStyle(fontSize: 36))));
  }

  Widget _buildTimeline(int aktifIndex) {
    return Row(children: List.generate(_asamaIsimleri.length, (i) {
      final gecmis = i < aktifIndex;
      final aktif = i == aktifIndex;

      return Expanded(child: Column(children: [
        Row(children: [
          if (i > 0) Expanded(child: Container(height: 1.5,
            color: gecmis ? _zeytinKoyu.withOpacity(0.35) : _sinir)),
          Container(
            width: aktif ? 12 : 7, height: aktif ? 12 : 7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: aktif
                  ? _zeytinKoyu
                  : gecmis
                      ? _zeytinKoyu.withOpacity(0.30)
                      : _sinir,
              border: aktif
                  ? Border.all(color: _zeytinKoyu.withOpacity(0.20), width: 3)
                  : null),
          ),
          if (i < _asamaIsimleri.length - 1) Expanded(child: Container(height: 1.5,
            color: gecmis ? _zeytinKoyu.withOpacity(0.35) : _sinir)),
        ]),
        const SizedBox(height: 5),
        // Timeline etiketi — aktif daha büyük
        Text(_asamaIsimleri[i], style: GoogleFonts.dmSans(
          fontSize: aktif ? 10 : 9,
          fontWeight: aktif ? FontWeight.w800 : FontWeight.w400,
          color: aktif
              ? _zeytinKoyu
              : gecmis
                  ? AppColors.textSecondary.withOpacity(0.55)
                  : _sinir)),
      ]));
    }));
  }
}