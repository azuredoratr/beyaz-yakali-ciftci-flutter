import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';
import '../services/bitki_servisi.dart';

class TakvimPage extends StatefulWidget {
  const TakvimPage({super.key});

  @override
  State<TakvimPage> createState() => _TakvimPageState();
}

class _TakvimPageState extends State<TakvimPage> {
  List<Map<String, dynamic>> _bitkiler = [];
  bool _yukleniyor = true;
  int _seciliAyIndex = DateTime.now().month - 1;
  String _filtre = 'Tümü';

  static const List<String> _aylar = [
    'Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz',
    'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara'
  ];

  static const List<String> _asamaIsimleri = [
    'Tohum', 'Fide', 'Büyüme', 'Çiçek', 'Meyve', 'Hasat'
  ];

  static const List<String> _filtreler = ['Tümü', 'Aktif', 'Yakın Hasat'];

  final List<Map<String, dynamic>> _asamalar = [
    {'isim': 'Tohum', 'emoji': '🌱'},
    {'isim': 'Fide', 'emoji': '🪴'},
    {'isim': 'Büyüme', 'emoji': '🌿'},
    {'isim': 'Çiçeklenme', 'emoji': '🌸'},
    {'isim': 'Meyve', 'emoji': '🍅'},
    {'isim': 'Hasat', 'emoji': '🧺'},
  ];

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

  int _toplamHafta(Map<String, dynamic> bitki) {
    return (bitki['toplam_hafta'] as int?) ?? 18;
  }

  int _kalanHafta(Map<String, dynamic> bitki) {
    final hafta = (bitki['hafta'] as int?) ?? 1;
    final toplam = _toplamHafta(bitki);
    return (toplam - hafta).clamp(0, toplam);
  }

  double _ilerleme(Map<String, dynamic> bitki) {
    final hafta = (bitki['hafta'] as int?) ?? 1;
    final toplam = _toplamHafta(bitki);
    return (hafta / toplam).clamp(0.0, 1.0);
  }

  Map<String, dynamic>? _enYakinHasat() {
    if (_bitkiler.isEmpty) return null;
    final sirali = List<Map<String, dynamic>>.from(_bitkiler)
      ..sort((a, b) => _kalanHafta(a).compareTo(_kalanHafta(b)));
    return sirali.first;
  }

  double _sezonIlerlemesi() {
    if (_bitkiler.isEmpty) return 0;
    final toplam = _bitkiler.fold<double>(0, (s, b) => s + _ilerleme(b));
    return toplam / _bitkiler.length;
  }

  List<Map<String, dynamic>> _filtreliListe() {
    if (_filtre == 'Yakın Hasat') {
      return _bitkiler.where((b) => _kalanHafta(b) <= 4).toList();
    }
    return _bitkiler;
  }

  List<Map<String, dynamic>> _yaklasanlar() {
    final liste = <Map<String, dynamic>>[];
    for (final b in _bitkiler) {
      final kalan = _kalanHafta(b);
      final aktif = _aktifAsamaIndex((b['hafta'] as int?) ?? 1);
      final tur = b['tur'] as String? ?? b['ad'] as String? ?? '';
      if (kalan == 0) {
        liste.add({'metin': 'Hasat zamanı', 'bitki': tur, 'hafta': 0});
      } else if (kalan <= 2) {
        liste.add({'metin': 'Hasat yaklaşıyor', 'bitki': tur, 'hafta': kalan});
      } else if (aktif < 5) {
        final sonrakiAsama = _asamaIsimleri[aktif + 1];
        liste.add({'metin': '$sonrakiAsama aşamasına geçecek', 'bitki': tur, 'hafta': _asamaGecisHafta(aktif)});
      }
    }
    liste.sort((a, b) => (a['hafta'] as int).compareTo(b['hafta'] as int));
    return liste.take(4).toList();
  }

  int _asamaGecisHafta(int mevcutAsama) {
    const gecisler = [2, 6, 10, 13, 16, 20];
    if (mevcutAsama + 1 < gecisler.length) return gecisler[mevcutAsama + 1];
    return 20;
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E9),
      body: _yukleniyor
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildHeader(topPadding)),
                SliverToBoxAdapter(child: _buildAySecici()),
                SliverToBoxAdapter(child: _buildSezonOzeti()),
                SliverToBoxAdapter(child: _buildBitkiListesi()),
                SliverToBoxAdapter(child: _buildYaklasanlar()),
                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            ),
    );
  }

  // ── HEADER ───────────────────────────────────────────────────
  Widget _buildHeader(double topPadding) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24, topPadding + 20, 24, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Sezon Takvimi', style: GoogleFonts.cormorantGaramond(
                fontSize: 32, fontWeight: FontWeight.w700,
                color: AppColors.textPrimary, height: 1.0)),
              const SizedBox(height: 4),
              Text('2026 sezonu · Ankara', style: GoogleFonts.dmSans(
                fontSize: 13, color: AppColors.textSecondary,
                fontWeight: FontWeight.w500)),
            ]),
          ),
          // Filtre
          GestureDetector(
            onTap: () => _filtrePanelAc(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: _filtre != 'Tümü'
                    ? AppColors.primary.withOpacity(0.10)
                    : Colors.white.withOpacity(0.88),
                borderRadius: BorderRadius.circular(99),
                border: Border.all(
                  color: _filtre != 'Tümü'
                      ? AppColors.primary.withOpacity(0.30)
                      : AppColors.cardBorder),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 3))],
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.tune_rounded, size: 14,
                  color: _filtre != 'Tümü' ? AppColors.primary : AppColors.textSecondary),
                const SizedBox(width: 6),
                Text(_filtre, style: GoogleFonts.dmSans(
                  fontSize: 12, fontWeight: FontWeight.w600,
                  color: _filtre != 'Tümü' ? AppColors.primary : AppColors.textSecondary)),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _filtrePanelAc() {
    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Filtrele', style: GoogleFonts.dmSans(
            fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const SizedBox(height: 16),
          ..._filtreler.map((f) => GestureDetector(
            onTap: () { setState(() => _filtre = f); Navigator.pop(ctx); },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: _filtre == f ? AppColors.primary.withOpacity(0.08) : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _filtre == f ? AppColors.primary.withOpacity(0.25) : AppColors.cardBorder)),
              child: Text(f, style: GoogleFonts.dmSans(
                fontSize: 14, fontWeight: FontWeight.w600,
                color: _filtre == f ? AppColors.primary : AppColors.textPrimary)),
            ),
          )),
        ]),
      ),
    );
  }

  // ── AY SEÇİCİ ────────────────────────────────────────────────
  Widget _buildAySecici() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
      child: SizedBox(
        height: 36,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: _aylar.length,
          itemBuilder: (context, i) {
            final secili = i == _seciliAyIndex;
            return GestureDetector(
              onTap: () => setState(() => _seciliAyIndex = i),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: secili ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(
                    color: secili ? AppColors.primary : AppColors.cardBorder,
                    width: secili ? 0 : 1)),
                child: Text(_aylar[i], style: GoogleFonts.dmSans(
                  fontSize: 12, fontWeight: FontWeight.w600,
                  color: secili ? Colors.white : AppColors.textSecondary)),
              ),
            );
          },
        ),
      ),
    );
  }

  // ── SEZON ÖZETİ ──────────────────────────────────────────────
  Widget _buildSezonOzeti() {
    final enYakin = _enYakinHasat();
    final ilerleme = _sezonIlerlemesi();
    final yuzde = (ilerleme * 100).round();

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.94),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.cardBorder.withOpacity(0.6)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('2026 İlkbahar Sezonu', style: GoogleFonts.dmSans(
                fontSize: 11, fontWeight: FontWeight.w800,
                letterSpacing: 1.1, color: AppColors.primary)),
              const SizedBox(height: 6),
              Text('Bugün · ${_aylar[DateTime.now().month - 1]} ${DateTime.now().year}',
                style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textSecondary)),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(99)),
              child: Text('%$yuzde tamamlandı', style: GoogleFonts.dmSans(
                fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
            ),
          ]),
          const SizedBox(height: 16),
          // Sezon progress
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Sezon başlangıcı', style: GoogleFonts.dmSans(
                fontSize: 10, color: AppColors.textSecondary)),
              Text('Tahmini hasat dönemi', style: GoogleFonts.dmSans(
                fontSize: 10, color: AppColors.textSecondary)),
            ]),
            const SizedBox(height: 6),
            Stack(children: [
              Container(height: 6, decoration: BoxDecoration(
                color: AppColors.cardBorder.withOpacity(0.6),
                borderRadius: BorderRadius.circular(99))),
              FractionallySizedBox(
                widthFactor: ilerleme,
                child: Container(height: 6, decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(99)))),
            ]),
          ]),
          const SizedBox(height: 16),
          Divider(color: AppColors.cardBorder.withOpacity(0.55), height: 1),
          const SizedBox(height: 14),
          Row(children: [
            _ozetChip('🌱', '${_bitkiler.length} aktif bitki'),
            const SizedBox(width: 12),
            if (enYakin != null)
              _ozetChip('🧺',
                'En yakın: ${enYakin['tur'] ?? enYakin['ad'] ?? ''} · ${_kalanHafta(enYakin)} hf'),
          ]),
        ]),
      ),
    );
  }

  Widget _ozetChip(String emoji, String metin) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Text(emoji, style: const TextStyle(fontSize: 13)),
      const SizedBox(width: 6),
      Text(metin, style: GoogleFonts.dmSans(
        fontSize: 11.5, fontWeight: FontWeight.w600,
        color: AppColors.textPrimary.withOpacity(0.75))),
    ]);
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
            border: Border.all(color: AppColors.cardBorder.withOpacity(0.6))),
          child: Center(child: Text('Henüz bitki eklemedin.',
            style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textSecondary)))));
    }
    return Column(
      children: liste.map((b) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
        child: _buildBitkiKarti(b),
      )).toList(),
    );
  }

  Widget _buildBitkiKarti(Map<String, dynamic> bitki) {
    final tur = bitki['tur'] as String? ?? bitki['ad'] as String? ?? 'Bitki';
    final hafta = (bitki['hafta'] as int?) ?? 1;
    final toplam = _toplamHafta(bitki);
    final kalan = _kalanHafta(bitki);
    final aktif = _aktifAsamaIndex(hafta);
    final ilerleme = _ilerleme(bitki);
    final asamaAdi = _asamaIsimleri[aktif.clamp(0, _asamaIsimleri.length - 1)];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.94),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cardBorder.withOpacity(0.6)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 18, offset: const Offset(0, 6))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Üst: isim + aşama badge
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(tur, style: GoogleFonts.dmSans(
              fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            const SizedBox(height: 3),
            Text('$hafta. hafta · $toplam haftalık süreç',
              style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.textSecondary)),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F0E0),
              borderRadius: BorderRadius.circular(99)),
            child: Text(asamaAdi, style: GoogleFonts.dmSans(
              fontSize: 11, fontWeight: FontWeight.w700,
              color: const Color(0xFF2D5A27))),
          ),
        ]),

        const SizedBox(height: 14),

        // Hasada kalan
        Row(children: [
          Icon(Icons.schedule_outlined, size: 13, color: AppColors.textSecondary),
          const SizedBox(width: 5),
          Text(
            kalan == 0 ? 'Hasat zamanı!' : 'Hasada $kalan hafta kaldı',
            style: GoogleFonts.dmSans(
              fontSize: 12, fontWeight: FontWeight.w600,
              color: kalan <= 2 ? AppColors.accent : AppColors.textSecondary)),
        ]),

        const SizedBox(height: 12),

        // İnce progress bar
        Stack(children: [
          Container(height: 4, decoration: BoxDecoration(
            color: AppColors.cardBorder.withOpacity(0.6),
            borderRadius: BorderRadius.circular(99))),
          FractionallySizedBox(
            widthFactor: ilerleme,
            child: Container(height: 4, decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(99)))),
        ]),

        const SizedBox(height: 12),

        // Timeline noktaları
        _buildMiniTimeline(aktif),
      ]),
    );
  }

  Widget _buildMiniTimeline(int aktifIndex) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(_asamaIsimleri.length, (i) {
        final gecmis = i < aktifIndex;
        final aktif = i == aktifIndex;
        final gelecek = i > aktifIndex;

        return Expanded(
          child: Column(children: [
            Row(children: [
              if (i > 0) Expanded(child: Container(height: 1.5,
                color: gecmis || aktif
                    ? AppColors.primary.withOpacity(0.4)
                    : AppColors.cardBorder)),
              Container(
                width: aktif ? 10 : 7, height: aktif ? 10 : 7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: aktif
                      ? AppColors.primary
                      : gecmis
                          ? AppColors.primary.withOpacity(0.35)
                          : AppColors.cardBorder,
                  border: aktif ? Border.all(color: AppColors.primary.withOpacity(0.3), width: 2.5) : null,
                ),
              ),
              if (i < _asamaIsimleri.length - 1) Expanded(child: Container(height: 1.5,
                color: gecmis
                    ? AppColors.primary.withOpacity(0.4)
                    : AppColors.cardBorder)),
            ]),
            const SizedBox(height: 5),
            Text(_asamaIsimleri[i], style: GoogleFonts.dmSans(
              fontSize: 8.5,
              fontWeight: aktif ? FontWeight.w700 : FontWeight.w400,
              color: aktif
                  ? AppColors.primary
                  : gelecek
                      ? AppColors.cardBorder
                      : AppColors.textSecondary.withOpacity(0.7))),
          ]),
        );
      }),
    );
  }

  // ── YAKLAŞANLAR ──────────────────────────────────────────────
  Widget _buildYaklasanlar() {
    final liste = _yaklasanlar();
    if (liste.isEmpty) return const SizedBox(height: 20);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.94),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.cardBorder.withOpacity(0.6)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Yaklaşanlar', style: GoogleFonts.dmSans(
            fontSize: 11, fontWeight: FontWeight.w800,
            letterSpacing: 1.1, color: AppColors.primary)),
          const SizedBox(height: 14),
          ...liste.asMap().entries.map((e) {
            final i = e.key;
            final item = e.value;
            final hafta = item['hafta'] as int;
            final zaman = hafta == 0
                ? 'Bu hafta'
                : hafta == 1
                    ? '1 hafta sonra'
                    : '$hafta hafta sonra';

            return Padding(
              padding: EdgeInsets.only(bottom: i < liste.length - 1 ? 14 : 0),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    shape: BoxShape.circle),
                  child: Icon(Icons.event_outlined, size: 16, color: AppColors.primary)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: Text(item['bitki'] as String,
                      style: GoogleFonts.dmSans(
                        fontSize: 13, fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary))),
                    Text(zaman, style: GoogleFonts.dmSans(
                      fontSize: 11, color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500)),
                  ]),
                  const SizedBox(height: 2),
                  Text(item['metin'] as String, style: GoogleFonts.dmSans(
                    fontSize: 12, color: AppColors.textSecondary)),
                ])),
              ]),
            );
          }),
        ]),
      ),
    );
  }
}