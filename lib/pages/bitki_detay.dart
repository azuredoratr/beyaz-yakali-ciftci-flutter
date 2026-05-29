import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
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
  int _seciliSeyirIndex = 0;
  late final PageController _seyirController;

  static const double _seyirKartW = 104;
  static const double _seyirKartH = 132;
  static const double _seyirRadius = 20;
  static const _matteKart = Color(0xFFF2EBDD);
  static const _koyu = Color(0xFF24281F);

  Color get _accent => _dominantRenk;

  static const List<Map<String, String>> _moodListesi = [
    {'isim': 'Mutlu', 'emoji': '🌞'},
    {'isim': 'Umutlu', 'emoji': '🌱'},
    {'isim': 'Heyecanlı', 'emoji': '✨'},
    {'isim': 'Sakin', 'emoji': '🍃'},
    {'isim': 'Meraklı', 'emoji': '🔍'},
    {'isim': 'Enerjik', 'emoji': '☀️'},
    {'isim': 'Minnettar', 'emoji': '🙏'},
    {'isim': 'Sabırlı', 'emoji': '🌊'},
    {'isim': 'Düşünceli', 'emoji': '💧'},
    {'isim': 'Karamsar', 'emoji': '🌧️'},
  ];

  final List<Map<String, dynamic>> _seyirKayitlari = [];

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
    return hsl.withLightness(0.20).withSaturation((hsl.saturation * 1.2).clamp(0.0, 1.0)).toColor();
  }

  Map<String, String>? _moodBul(String? moodIsim) {
    if (moodIsim == null) return null;
    try { return _moodListesi.firstWhere((m) => m['isim'] == moodIsim); } catch (_) { return null; }
  }

  String _asamaEmoji(String? asama) =>
      _asamalar.firstWhere((a) => a['isim'] == asama, orElse: () => {'emoji': '🌱'})['emoji'] as String;

  @override
  void initState() {
    super.initState();
    _seyirController = PageController(viewportFraction: 0.27);
    _yukle();
  }

  @override
  void dispose() {
    _seyirController.dispose();
    super.dispose();
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
        final palette = await PaletteGenerator.fromImageProvider(AssetImage(fotografYolu), size: const Size(200, 200));
        if (mounted) {
          final raw1 = palette.darkVibrantColor?.color ?? palette.vibrantColor?.color ?? palette.dominantColor?.color ?? const Color(0xFF2D5A27);
          final raw2 = palette.darkMutedColor?.color ?? palette.mutedColor?.color ?? const Color(0xFF1B4332);
          setState(() { _dominantRenk = _zorlaKoyulastir(raw1); _ikincilRenk = _zorlaKoyulastir(raw2); });
        }
      } catch (_) {}
    }
    if (mounted) setState(() {
      _gorevler = results[0] as List<Map<String, dynamic>>;
      _tamamlananlar = results[1] as List<String>;
      _yukleniyor = false;
    });
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
    final onay = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: Text('Bitkiyi Sil', style: GoogleFonts.dmSans(fontWeight: FontWeight.bold)),
      content: Text('${widget.bitki['tur']} bitkisini silmek istediğinden emin misin?', style: GoogleFonts.dmSans()),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('İptal', style: GoogleFonts.dmSans())),
        TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text('Sil', style: GoogleFonts.dmSans(color: Colors.red, fontWeight: FontWeight.bold))),
      ],
    ));
    if (onay == true) { await BitkiServisi.bitkiSil(widget.bitki['id'] as String); if (mounted) Navigator.pop(context, true); }
  }

  String _ayAdi(int ay) {
    const aylar = ['Ocak','Şubat','Mart','Nisan','Mayıs','Haziran','Temmuz','Ağustos','Eylül','Ekim','Kasım','Aralık'];
    return aylar[ay - 1];
  }

  void _yeniSeyirKaydiAc() {
    final baslikCtrl = TextEditingController();
    final notCtrl = TextEditingController();
    final accent = _accent;
    final asama = _asamalar[_aktifAsama]['isim'] as String;
    final hafta = widget.bitki['hafta'] as int? ?? 1;
    String? secilenMood;
    File? secilenFoto;

    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent, isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setModalState) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.88),
          decoration: BoxDecoration(color: const Color(0xFF1A1C14), borderRadius: BorderRadius.circular(28), border: Border.all(color: Colors.white.withOpacity(0.10))),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Center(child: Container(width: 36, height: 4, margin: const EdgeInsets.only(bottom: 18),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.18), borderRadius: BorderRadius.circular(99)))),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Yeni Seyir Kaydı', style: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text('$hafta. hafta · $asama', style: GoogleFonts.dmSans(fontSize: 12, color: Colors.white.withOpacity(0.45))),
                ])),
                Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: accent.withOpacity(0.18), borderRadius: BorderRadius.circular(99), border: Border.all(color: accent.withOpacity(0.35))),
                  child: Text(_asamalar[_aktifAsama]['emoji'] as String, style: const TextStyle(fontSize: 16))),
              ]),
              const SizedBox(height: 18),
              GestureDetector(
                onTap: () async {
                  final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80);
                  if (picked != null) setModalState(() => secilenFoto = File(picked.path));
                },
                child: Container(
                  width: double.infinity, height: 160,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.04), borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: secilenFoto != null ? accent.withOpacity(0.6) : accent.withOpacity(0.25), width: secilenFoto != null ? 1.5 : 1),
                    boxShadow: [BoxShadow(color: accent.withOpacity(0.10), blurRadius: 18, spreadRadius: -4)],
                  ),
                  child: secilenFoto != null
                      ? ClipRRect(borderRadius: BorderRadius.circular(17), child: Stack(children: [
                          Positioned.fill(child: Image.file(secilenFoto!, fit: BoxFit.cover, alignment: const Alignment(0.0, -0.15))),
                          Positioned(bottom: 8, right: 8, child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: Colors.black.withOpacity(0.55), borderRadius: BorderRadius.circular(8)),
                            child: Text('Değiştir', style: GoogleFonts.dmSans(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600)))),
                        ]))
                      : Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Container(width: 52, height: 52,
                            decoration: BoxDecoration(color: accent.withOpacity(0.14), shape: BoxShape.circle, border: Border.all(color: accent.withOpacity(0.30))),
                            child: Icon(Icons.add_a_photo_outlined, color: accent, size: 24)),
                          const SizedBox(height: 10),
                          Text('Fotoğraf Ekle', style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600, color: accent)),
                          const SizedBox(height: 3),
                          Text('Galeriden seç • opsiyonel', style: GoogleFonts.dmSans(fontSize: 11, color: Colors.white.withOpacity(0.30))),
                        ])),
                ),
              ),
              const SizedBox(height: 14),
              _inputField(baslikCtrl, 'Ne oldu bugün? (ör. Kabaklar hızla büyüyor)', accent, maxLines: 1),
              const SizedBox(height: 10),
              _inputField(notCtrl, 'Notun...', accent, maxLines: 3),
              const SizedBox(height: 16),
              Text('Bugün nasıl hissediyorsun?', style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.65))),
              const SizedBox(height: 10),
              Wrap(spacing: 8, runSpacing: 8, children: _moodListesi.map((mood) {
                final secili = secilenMood == mood['isim'];
                return GestureDetector(
                  onTap: () => setModalState(() => secilenMood = mood['isim']),
                  child: AnimatedContainer(duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: secili ? accent.withOpacity(0.22) : Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(color: secili ? accent.withOpacity(0.7) : Colors.white.withOpacity(0.14), width: secili ? 1.5 : 1)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text(mood['emoji']!, style: const TextStyle(fontSize: 13)),
                      const SizedBox(width: 5),
                      Text(mood['isim']!, style: GoogleFonts.dmSans(fontSize: 12, fontWeight: secili ? FontWeight.w700 : FontWeight.w500, color: secili ? Colors.white : Colors.white.withOpacity(0.60))),
                    ])),
                );
              }).toList()),
              const SizedBox(height: 20),
              SizedBox(width: double.infinity, child: ElevatedButton(
                onPressed: () {
                  if (baslikCtrl.text.isEmpty) return;
                  final now = DateTime.now();
                  setState(() {
                    _seyirKayitlari.add({'hafta': widget.bitki['hafta'], 'baslik': baslikCtrl.text, 'not': notCtrl.text,
                      'tarih': '${now.day} ${_ayAdi(now.month)} ${now.year}',
                      'saat': '${now.hour.toString().padLeft(2,'0')}:${now.minute.toString().padLeft(2,'0')}',
                      'asama': asama, 'mood': secilenMood, 'fotoPath': secilenFoto?.path});
                    _seciliSeyirIndex = _seyirKayitlari.length - 1;
                  });
                  Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6B7A1E), foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)), elevation: 0),
                child: Text('Kaydet', style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w700)),
              )),
            ]),
          ),
        ),
      )),
    );
  }

  Widget _inputField(TextEditingController ctrl, String hint, Color accent, {int maxLines = 1}) {
    return TextField(controller: ctrl, maxLines: maxLines,
      style: GoogleFonts.dmSans(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint, hintStyle: GoogleFonts.dmSans(color: Colors.white.withOpacity(0.25), fontSize: 13),
        filled: true, fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.white.withOpacity(0.10))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.white.withOpacity(0.10))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: accent.withOpacity(0.55))),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      ));
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
      body: Stack(children: [
        Positioned.fill(child: Image.asset('assets/images/bg_atmosphere.png', fit: BoxFit.cover, alignment: Alignment.topCenter)),
        Positioned.fill(child: Container(decoration: BoxDecoration(gradient: LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [Colors.black.withOpacity(0.00), Colors.black.withOpacity(0.20), const Color(0xFF1E1B14).withOpacity(0.88)],
          stops: const [0.0, 0.40, 1.0])))),
        Positioned(top: 0, left: 0, right: 0, height: heroHeight,
          child: ShaderMask(
            shaderCallback: (bounds) => LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
              colors: [Colors.white, Colors.white, Colors.transparent], stops: const [0.0, 0.50, 1.0]).createShader(bounds),
            blendMode: BlendMode.dstIn,
            child: SizedBox(width: double.infinity, height: heroHeight,
              child: fotografYolu != null
                  ? ColorFiltered(colorFilter: const ColorFilter.matrix([0.92,0,0,0,-4, 0,0.92,0,0,-4, 0,0,0.88,0,-6, 0,0,0,1,0]),
                      child: Image.asset(fotografYolu, fit: BoxFit.cover, alignment: const Alignment(0.0, -0.15),
                          errorBuilder: (_, __, ___) => Container(color: _accent)))
                  : Container(color: _accent)))),
        Positioned(top: 0, left: 0, right: 0, height: heroHeight,
          child: IgnorePointer(child: Container(decoration: BoxDecoration(gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Colors.black.withOpacity(0.15), Colors.transparent, const Color(0xFF1E1B14).withOpacity(0.60)],
            stops: const [0.0, 0.55, 1.0]))))),
        CustomScrollView(slivers: [
          SliverToBoxAdapter(child: SizedBox(height: heroHeight * 0.62)),
          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (_latinceIsim.isNotEmpty) Text(_latinceIsim, style: GoogleFonts.cormorantGaramond(
                fontSize: 15, fontStyle: FontStyle.italic, fontWeight: FontWeight.w500,
                color: Colors.white.withOpacity(0.65), letterSpacing: 0.3)),
              const SizedBox(height: 2),
              Text(tur, style: GoogleFonts.dmSans(fontSize: 29, fontWeight: FontWeight.w800, color: Colors.white, height: 1.0,
                shadows: [Shadow(color: Colors.black.withOpacity(0.40), blurRadius: 14, offset: const Offset(0, 4))])),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.30), borderRadius: BorderRadius.circular(999), border: Border.all(color: Colors.white.withOpacity(0.20))),
                child: Text('$hafta. hafta · ${_asamalar[_aktifAsama]['isim']} Aşaması',
                    style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.88))),
              ),
            ]),
          )),
          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
            child: Column(children: [
              _buildAsamaTimeline(),
              const SizedBox(height: 16),
              if (_yukleniyor) const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(color: Colors.white)))
              else _buildGorevler(),
              const SizedBox(height: 22),
              _buildSeyirDefteri(),
              const SizedBox(height: 30),
              _buildAiButonuTamGenislik(aiBtnRenk),
              const SizedBox(height: 120),
            ]),
          )),
        ]),
        Positioned(top: topPadding + 12, left: 20,
          child: GestureDetector(onTap: () => Navigator.pop(context),
            child: Container(width: 42, height: 42,
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.30), shape: BoxShape.circle, border: Border.all(color: Colors.white.withOpacity(0.22))),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 20)))),
        Positioned(top: topPadding + 12, right: 20,
          child: GestureDetector(onTap: _bitkiSil,
            child: Container(width: 42, height: 42,
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.30), shape: BoxShape.circle, border: Border.all(color: Colors.white.withOpacity(0.22))),
              child: const Icon(Icons.delete_outline, color: Colors.white, size: 20)))),
      ]),
    );
  }

  Widget _buildAsamaTimeline() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: _matteKart.withOpacity(0.93), borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.50), width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.18), blurRadius: 30, offset: const Offset(0, 12))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Gelişim Aşaması', style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w800, color: _koyu)),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _asamalar.asMap().entries.map((e) {
            final i = e.key; final asama = e.value;
            final aktif = i == _aktifAsama; final gecmis = i < _aktifAsama;
            return Column(children: [
              Container(width: 40, height: 40,
                decoration: BoxDecoration(shape: BoxShape.circle,
                  color: aktif ? _accent : gecmis ? _accent.withOpacity(0.2) : Colors.white,
                  border: Border.all(color: aktif ? _accent : gecmis ? _accent.withOpacity(0.4) : _koyu.withOpacity(0.12), width: aktif ? 2 : 1),
                  boxShadow: aktif ? [BoxShadow(color: _accent.withOpacity(0.30), blurRadius: 10, offset: const Offset(0, 4))] : []),
                child: Center(child: Text(asama['emoji'] as String, style: TextStyle(fontSize: aktif ? 18 : 14)))),
              const SizedBox(height: 5),
              Text(asama['isim'] as String, style: GoogleFonts.dmSans(fontSize: 9, fontWeight: aktif ? FontWeight.w800 : FontWeight.w400, color: aktif ? _accent : _koyu.withOpacity(0.45))),
            ]);
          }).toList()),
      ]),
    );
  }

  Widget _buildGorevler() {
    if (_gorevler.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _matteKart.withOpacity(0.93), borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.50), width: 1),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.18), blurRadius: 30, offset: const Offset(0, 12))],
        ),
        child: Center(child: Text('Bu hafta için görev bulunamadı.', style: GoogleFonts.dmSans(fontSize: 13, color: _koyu.withOpacity(0.55)))));
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('Bu Hafta Yapılacaklar', style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white,
            shadows: [Shadow(color: Colors.black.withOpacity(0.35), blurRadius: 10)])),
        Text('${_tamamlananlar.length} / ${_gorevler.length} tamamlandı',
            style: GoogleFonts.dmSans(fontSize: 11.5, color: Colors.white.withOpacity(0.65), fontWeight: FontWeight.w500)),
      ]),
      const SizedBox(height: 10),
      Container(
        decoration: BoxDecoration(
          color: _matteKart.withOpacity(0.93), borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.50), width: 1),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.18), blurRadius: 30, offset: const Offset(0, 12))],
        ),
        child: Column(children: _gorevler.asMap().entries.map((e) {
          final i = e.key; final g = e.value;
          return Column(children: [
            _buildGorevSatiri(g),
            if (i < _gorevler.length - 1) Divider(height: 1, color: _koyu.withOpacity(0.07), indent: 58),
          ]);
        }).toList()),
      ),
    ]);
  }

  Widget _buildGorevSatiri(Map<String, dynamic> gorev) {
    final gorevId = gorev['id'] as String;
    final tamamlandi = _tamamlananlar.contains(gorevId);
    final nasil = gorev['nasil_yapilir'] as String?;
    final not = gorev['not'] as String?;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        GestureDetector(onTap: () => _gorevToggle(gorevId),
          child: Container(width: 28, height: 28, margin: const EdgeInsets.only(top: 1),
            decoration: BoxDecoration(shape: BoxShape.circle,
              color: tamamlandi ? _accent : Colors.white,
              border: Border.all(color: tamamlandi ? _accent : _koyu.withOpacity(0.22), width: 1.5)),
            child: tamamlandi ? const Icon(Icons.check, size: 14, color: Colors.white) : null)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(gorev['ad'] as String, style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w700,
            color: tamamlandi ? _koyu.withOpacity(0.38) : _koyu,
            decoration: tamamlandi ? TextDecoration.lineThrough : null, decorationColor: _koyu.withOpacity(0.38))),
          if (gorev['aciklama'] != null && (gorev['aciklama'] as String).isNotEmpty)
            Padding(padding: const EdgeInsets.only(top: 2),
              child: Text(gorev['aciklama'] as String, style: GoogleFonts.dmSans(fontSize: 11.5, height: 1.45, color: _koyu.withOpacity(0.52)))),
          if (not != null) Padding(padding: const EdgeInsets.only(top: 4),
            child: Text('📝 $not', style: GoogleFonts.dmSans(fontSize: 11, color: _koyu.withOpacity(0.68)))),
        ])),
        if (nasil != null) GestureDetector(onTap: () => _nasilYapilirGoster(gorev['ad'] as String, nasil),
          child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: _koyu.withOpacity(0.07), borderRadius: BorderRadius.circular(8), border: Border.all(color: _koyu.withOpacity(0.12))),
            child: Text('Nasıl?', style: GoogleFonts.dmSans(fontSize: 11, color: _accent, fontWeight: FontWeight.w600)))),
      ]),
    );
  }

  void _nasilYapilirGoster(String baslik, String icerik) {
    showModalBottomSheet(context: context, backgroundColor: Colors.transparent,
      builder: (ctx) => Container(margin: const EdgeInsets.all(16), padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(baslik, style: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          ...icerik.split('\n').map((adim) => Padding(padding: const EdgeInsets.only(bottom: 8),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('• ', style: TextStyle(color: _accent, fontSize: 14)),
              Expanded(child: Text(adim, style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textPrimary, height: 1.5))),
            ]))),
          const SizedBox(height: 8),
        ])));
  }

  Widget _buildSeyirDefteri() {
    final secili = _seyirKayitlari.isNotEmpty ? _seyirKayitlari[_seciliSeyirIndex] : null;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('Seyir Defteri', style: GoogleFonts.dmSans(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white,
            shadows: [Shadow(color: Colors.black.withOpacity(0.30), blurRadius: 10)])),
        if (_seyirKayitlari.isNotEmpty) GestureDetector(onTap: () {},
          child: Row(children: [
            Text('Tümünü Gör', style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w700, color: _accent.withOpacity(0.90))),
            const SizedBox(width: 3),
            Icon(Icons.chevron_right, size: 17, color: _accent.withOpacity(0.90)),
          ])),
      ]),
      const SizedBox(height: 12),
      if (_seyirKayitlari.isEmpty)
        GestureDetector(onTap: _yeniSeyirKaydiAc,
          child: Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 32),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04), borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.10)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 20, offset: const Offset(0, 8))],
            ),
            child: Column(children: [
              Container(width: 50, height: 50,
                decoration: BoxDecoration(color: _accent.withOpacity(0.14), shape: BoxShape.circle, border: Border.all(color: _accent.withOpacity(0.32))),
                child: Icon(Icons.auto_stories_outlined, color: _accent, size: 24)),
              const SizedBox(height: 12),
              Text('Henüz seyir kaydı yok', style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.68))),
              const SizedBox(height: 4),
              Text('İlk kaydını eklemek için dokun', style: GoogleFonts.dmSans(fontSize: 12, color: Colors.white.withOpacity(0.35))),
            ])))
      else
        SizedBox(
          height: _seyirKartH + 20,
          child: PageView.builder(
            controller: _seyirController,
            padEnds: false,
            clipBehavior: Clip.none,
            itemCount: _seyirKayitlari.length + 1,
            onPageChanged: (index) {
              if (index < _seyirKayitlari.length) setState(() => _seciliSeyirIndex = index);
            },
            itemBuilder: (context, index) {
              if (index == _seyirKayitlari.length) {
                return Padding(padding: const EdgeInsets.only(right: 12), child: _buildYeniSeyirKart());
              }
              final kayit = _seyirKayitlari[index];
              final aktif = index == _seciliSeyirIndex;
              return Padding(padding: const EdgeInsets.only(right: 12),
                child: _buildSeyirKart(kayit: kayit, aktif: aktif, onTap: () {
                  setState(() => _seciliSeyirIndex = index);
                  _seyirController.animateToPage(index, duration: const Duration(milliseconds: 260), curve: Curves.easeOutCubic);
                }));
            },
          )),
      if (secili != null) ...[const SizedBox(height: 18), _buildSeyirOzetKart(secili)],
    ]);
  }

  Widget _buildSeyirKart({required Map<String, dynamic> kayit, required bool aktif, required VoidCallback onTap}) {
    final fotoPath = kayit['fotoPath'] as String?;
    final mood = _moodBul(kayit['mood'] as String?);
    return GestureDetector(onTap: onTap,
      child: SizedBox(width: _seyirKartW,
        child: Stack(clipBehavior: Clip.none, children: [
          AnimatedContainer(duration: const Duration(milliseconds: 220), curve: Curves.easeOut,
            width: _seyirKartW, height: _seyirKartH,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(_seyirRadius),
              border: Border.all(
                color: aktif ? Colors.white.withOpacity(0.98) : Colors.white.withOpacity(0.62),
                width: aktif ? 2.2 : 1.15),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.20), blurRadius: 16, offset: const Offset(0, 6)),
                if (aktif) BoxShadow(color: _accent.withOpacity(0.10), blurRadius: 18, offset: const Offset(0, 8)),
              ]),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(_seyirRadius - 1),
              child: Stack(children: [
                Positioned.fill(child: fotoPath != null
                    ? Image.file(File(fotoPath), fit: BoxFit.cover, alignment: const Alignment(0.0, -0.15),
                        errorBuilder: (_, __, ___) => _seyirPlaceholder(mood))
                    : _seyirPlaceholder(mood)),
                Positioned(bottom: 0, left: 0, right: 0,
                  child: Container(height: 64, decoration: const BoxDecoration(
                    gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter,
                      colors: [Color(0xDD000000), Colors.transparent])))),
                Positioned(bottom: 10, left: 8, right: 8, child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                  Text('${kayit['hafta']}. Hafta', style: GoogleFonts.dmSans(fontSize: 10.5, fontWeight: FontWeight.w800, color: Colors.white,
                      shadows: [Shadow(color: Colors.black.withOpacity(0.5), blurRadius: 4)])),
                  Text(kayit['baslik'] as String, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.dmSans(fontSize: 9, fontWeight: FontWeight.w500, color: Colors.white.withOpacity(0.76))),
                ])),
                if (mood != null) Positioned(top: 6, right: 6,
                  child: Container(padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(color: Colors.black.withOpacity(0.32), borderRadius: BorderRadius.circular(7)),
                    child: Text(mood['emoji']!, style: const TextStyle(fontSize: 12)))),
              ]),
            )),
          // Aktif kart alt vurgu
          if (aktif) Positioned(
            bottom: -8, left: 0, right: 0,
            child: Center(child: Container(
              width: 28, height: 4,
              decoration: BoxDecoration(color: _accent.withOpacity(0.85), borderRadius: BorderRadius.circular(99)),
            )),
          ),
        ]),
      ),
    );
  }

  Widget _seyirPlaceholder(Map<String, String>? mood) {
    return Container(
      decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [_accent.withOpacity(0.28), _accent.withOpacity(0.10)])),
      child: Center(child: Text(mood?['emoji'] ?? '🌱', style: const TextStyle(fontSize: 30))));
  }

  Widget _buildYeniSeyirKart() {
    return SizedBox(width: _seyirKartW,
      child: GestureDetector(onTap: _yeniSeyirKaydiAc,
        child: Container(width: _seyirKartW, height: _seyirKartH,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04), borderRadius: BorderRadius.circular(_seyirRadius),
            border: Border.all(color: Colors.white.withOpacity(0.32), width: 1.1),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 12, offset: const Offset(0, 4))],
          ),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(width: 44, height: 44, decoration: BoxDecoration(color: _accent, shape: BoxShape.circle),
              child: const Icon(Icons.add, color: Colors.white, size: 24)),
            const SizedBox(height: 8),
            Text('Yeni\nKayıt', textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white.withOpacity(0.72), height: 1.18)),
          ])),
      ),
    );
  }

  Widget _buildSeyirOzetKart(Map<String, dynamic> kayit) {
    final mood = _moodBul(kayit['mood'] as String?);
    final asama = kayit['asama'] as String?;
    final fotoPath = kayit['fotoPath'] as String?;
    final tarihSaat = '${kayit['tarih']} • ${kayit['saat']}';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _matteKart.withOpacity(0.96),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.55), width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.22), blurRadius: 34, offset: const Offset(0, 16))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Hero foto
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(29)),
          child: SizedBox(width: double.infinity, height: 175,
            child: fotoPath != null
                ? Image.file(File(fotoPath), fit: BoxFit.cover, alignment: const Alignment(0.0, -0.15),
                    errorBuilder: (_, __, ___) => _ozetPlaceholder(mood))
                : _ozetPlaceholder(mood))),

        Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // GÜNLÜK NOT etiketi + menü
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: _accent.withOpacity(0.10), borderRadius: BorderRadius.circular(99)),
                child: Text('🌿 GÜNLÜK NOT', style: GoogleFonts.dmSans(
                    fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.2, color: _accent)),
              ),
              const Spacer(),
              Icon(Icons.more_horiz, color: _koyu.withOpacity(0.38), size: 20),
            ]),

            const SizedBox(height: 18),

            // Büyük hafta
            Text('${kayit['hafta']}. Hafta', style: GoogleFonts.cormorantGaramond(
              fontSize: 34, fontWeight: FontWeight.w700, color: _accent, height: 1.0)),
            const SizedBox(height: 2),

            // Başlık
            Text(kayit['baslik'] as String, maxLines: 2, overflow: TextOverflow.ellipsis,
                style: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.w800, color: _koyu, height: 1.15)),

            const SizedBox(height: 14),

            // Not — sol accent çizgi
            if ((kayit['not'] as String).isNotEmpty)
              IntrinsicHeight(
                child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Container(width: 3,
                    decoration: BoxDecoration(color: _accent.withOpacity(0.35), borderRadius: BorderRadius.circular(99))),
                  const SizedBox(width: 12),
                  Expanded(child: Text(kayit['not'] as String, maxLines: 4, overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.dmSans(fontSize: 13, height: 1.45, fontWeight: FontWeight.w500, color: _koyu.withOpacity(0.68)))),
                ]),
              ),

            const SizedBox(height: 16),

            // Capsule row
            Wrap(spacing: 8, runSpacing: 8, children: [
              if (mood != null) _buildCapsule('Bugün: ${mood['emoji']} ${mood['isim']}', _accent.withOpacity(0.12)),
              _buildCapsule('${_asamaEmoji(asama)} $asama Aşaması', _koyu.withOpacity(0.06)),
            ]),

            const SizedBox(height: 14),

            // Tarih tek satır + paylaş
            Row(children: [
              Icon(Icons.calendar_today_outlined, size: 13, color: _koyu.withOpacity(0.38)),
              const SizedBox(width: 5),
              Text(tarihSaat, style: GoogleFonts.dmSans(fontSize: 10.5, fontWeight: FontWeight.w500, color: _koyu.withOpacity(0.38))),
              const Spacer(),
              _buildPaylasChip(),
            ]),
          ]),
        ),
      ]),
    );
  }

  Widget _ozetPlaceholder(Map<String, String>? mood) {
    return Container(
      decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [_accent.withOpacity(0.22), _accent.withOpacity(0.08)])),
      child: Center(child: Text(mood?['emoji'] ?? '🌱', style: const TextStyle(fontSize: 40))));
  }

  Widget _buildCapsule(String text, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(99), border: Border.all(color: _koyu.withOpacity(0.08))),
      child: Text(text, style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w700, color: _koyu.withOpacity(0.72))),
    );
  }

  Widget _buildPaylasChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: _accent.withOpacity(0.10),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: _accent.withOpacity(0.16)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.ios_share, size: 14, color: _accent),
        const SizedBox(width: 6),
        Text('Paylaş', style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w800, color: _accent)),
      ]),
    );
  }

  Widget _buildAiButonuTamGenislik(Color aiBtnRenk) {
    return SizedBox(width: double.infinity,
      child: ElevatedButton.icon(onPressed: () {},
        icon: const Icon(Icons.auto_awesome, size: 17),
        label: Text('Sorun Bildir (AI)', style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w700)),
        style: ElevatedButton.styleFrom(backgroundColor: aiBtnRenk, foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          elevation: 2, shadowColor: Colors.black.withOpacity(0.22))));
  }
}