import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../main.dart';
import '../services/tercihler_servisi.dart';
import 'ana_ekran.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  String _sehir = 'Ankara';
  String _bahceTipi = 'Hobi Bahçesi';
  bool _bildirimler = true;
  bool _yukleniyor = true;
  String? _avatarYolu;

  static const Color _koyu = Color(0xFF24281F);
  static const Color _baslikYesil = Color(0xFF2D3A2F);
  static const Color _zeytinKoyu = Color(0xFF2D5A27);
  static const Color _zeytinAcik = Color(0xFFE8F0E0);
  static const Color _ikonYesil = Color(0xFF5C7A5A);
  static const Color _ikonBg = Color(0xFFEDF4EB);
  static const Color _kagit = Color(0xFFF5F1E9);
  static const Color _sinir = Color(0xFFE8E2D8);

  @override
  void initState() {
    super.initState();
    _yukle();
  }

  Future<void> _yukle() async {
    final sehir = await TercihlerServisi.sehirGetir();
    final bahce = await TercihlerServisi.bahceTipiGetir();
    if (mounted) setState(() {
      _sehir = sehir;
      _bahceTipi = _bahceTipiMetin(bahce);
      _yukleniyor = false;
    });
  }

  String _bahceTipiMetin(String tip) {
    final t = tip.toLowerCase();
    if (t.contains('tarla') || t.contains('arazi')) return 'Tarla / Arazi';
    if (t.contains('saksı') || t.contains('saksi') || t.contains('balkon')) return 'Saksı / Balkon';
    return 'Hobi Bahçesi';
  }

  Future<void> _avatarSec() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked != null && mounted) setState(() => _avatarYolu = picked.path);
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
                SliverToBoxAdapter(child: _buildHeroVeKimlik(topPadding)),
                SliverToBoxAdapter(child: _buildHesapKarti()),
                SliverToBoxAdapter(child: _buildTercihlerKarti()),
                SliverToBoxAdapter(child: _buildDestekKarti()),
                SliverToBoxAdapter(child: _buildCikisButonu()),
                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            ),
    );
  }

  // ── HERO + KİMLİK ────────────────────────────────────────────
  Widget _buildHeroVeKimlik(double topPadding) {
    final heroH = topPadding + 220.0;
    const kartH = 82.0;
    const overlap = 32.0;

    return SizedBox(
      height: heroH + kartH - overlap,
      child: Stack(clipBehavior: Clip.none, children: [
        // Hero tam genişlik
        Positioned(
          top: 0, left: 0, right: 0, height: heroH,
          child: Stack(children: [
            Positioned.fill(
              child: Image.asset(
                heroImajGetir(_bahceTipi),
                fit: BoxFit.cover,
                alignment: const Alignment(-0.45, -0.25),
                errorBuilder: (_, __, ___) => Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                      colors: [_zeytinKoyu.withOpacity(0.35), _zeytinAcik]))),
              ),
            ),
            // Alttan fade
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.42)],
                    stops: const [0.30, 1.0],
                  ),
                ),
              ),
            ),
            // Soldan sağa overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft, end: Alignment.centerRight,
                    colors: [
                      Colors.black.withOpacity(0.55),
                      Colors.black.withOpacity(0.28),
                      Colors.black.withOpacity(0.05),
                    ],
                    stops: const [0.0, 0.45, 1.0],
                  ),
                ),
              ),
            ),
            // Üst: Profil başlığı
            Positioned(
              top: topPadding + 16,
              left: 24, right: 24,
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Profil', style: GoogleFonts.cormorantGaramond(
                    fontSize: 34, fontWeight: FontWeight.w700,
                    color: Colors.white, height: 1.0,
                    shadows: [Shadow(color: Colors.black.withOpacity(0.30), blurRadius: 10)])),
                  const SizedBox(height: 3),
                  Text('Hesabını ve tercihlerini yönet', style: GoogleFonts.dmSans(
                    fontSize: 13, color: Colors.white.withOpacity(0.78))),
                ])),
                Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.20),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.30))),
                  child: Icon(Icons.notifications_outlined, size: 18,
                    color: Colors.white.withOpacity(0.90))),
              ]),
            ),
            // Alt: bahçe adı + 3 bilgi bloğu
            Positioned(
              left: 24, right: 24, bottom: overlap + 14,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Mustafa\'nın Bahçesi', style: GoogleFonts.cormorantGaramond(
                  fontSize: 26, fontWeight: FontWeight.w700, color: Colors.white, height: 1.0,
                  shadows: [Shadow(color: Colors.black.withOpacity(0.25), blurRadius: 8)])),
                const SizedBox(height: 4),
                Text('Mart 2026\'dan beri yetiştiriyor', style: GoogleFonts.dmSans(
                  fontSize: 12, color: Colors.white.withOpacity(0.80))),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(12)),
                  child: IntrinsicHeight(
                    child: Row(children: [
                      _heroStatBlok(Icons.yard_outlined, _bahceTipi, 'Alan'),
                      _heroDivider(),
                      _heroStatBlok(Icons.location_on_outlined, _sehir, 'Konum'),
                      _heroDivider(),
                      _heroStatBlok(Icons.calendar_today_outlined, 'Mar 2026', 'Üyelik'),
                    ]),
                  ),
                ),
              ]),
            ),
          ]),
        ),

        // Kimlik kartı
        Positioned(
          left: 24, right: 24,
          top: heroH - overlap,
          child: _buildKimlikKarti(),
        ),
      ]),
    );
  }

  Widget _heroStatBlok(IconData icon, String deger, String etiket) {
    return Expanded(child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Icon(icon, size: 11, color: Colors.white.withOpacity(0.65)),
          const SizedBox(width: 4),
          Expanded(child: Text(deger,
            maxLines: 1, overflow: TextOverflow.ellipsis,
            style: GoogleFonts.dmSans(
              fontSize: 11, fontWeight: FontWeight.w700,
              color: Colors.white, height: 1.2))),
        ]),
        const SizedBox(height: 1),
        Text(etiket, style: GoogleFonts.dmSans(
          fontSize: 9.5, color: Colors.white.withOpacity(0.55))),
      ],
    ));
  }

  Widget _heroDivider() => Container(
    width: 1, height: 28, margin: const EdgeInsets.symmetric(horizontal: 10),
    color: Colors.white.withOpacity(0.22));

  Widget _buildKimlikKarti() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.97),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _sinir.withOpacity(0.8)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 7)),
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(children: [
        Stack(children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: _zeytinAcik, shape: BoxShape.circle,
              border: Border.all(color: _zeytinKoyu.withOpacity(0.20), width: 1.5)),
            child: ClipOval(
              child: _avatarYolu != null
                  ? Image.file(File(_avatarYolu!), fit: BoxFit.cover)
                  : Center(child: Text('M', style: GoogleFonts.cormorantGaramond(
                      fontSize: 21, fontWeight: FontWeight.w700, color: _zeytinKoyu))),
            ),
          ),
          Positioned(bottom: 0, right: 0,
            child: GestureDetector(
              onTap: _avatarSec,
              child: Container(
                width: 17, height: 17,
                decoration: BoxDecoration(
                  color: _zeytinKoyu, shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5)),
                child: const Icon(Icons.add_a_photo, size: 8, color: Colors.white)),
            )),
        ]),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Mustafa Kocaman', style: GoogleFonts.dmSans(
            fontSize: 14, fontWeight: FontWeight.w800, color: _koyu)),
          const SizedBox(height: 1),
          Text('$_bahceTipi · $_sehir', style: GoogleFonts.dmSans(
            fontSize: 11.5, color: AppColors.textSecondary)),
          const SizedBox(height: 1),
          Text('Mart 2026\'dan beri bizimle', style: GoogleFonts.dmSans(
            fontSize: 10.5, color: AppColors.textSecondary.withOpacity(0.65))),
        ])),
        GestureDetector(
          onTap: _profilDuzenle,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _zeytinAcik, borderRadius: BorderRadius.circular(99),
              border: Border.all(color: _zeytinKoyu.withOpacity(0.20))),
            child: Text('Düzenle', style: GoogleFonts.dmSans(
              fontSize: 10.5, fontWeight: FontWeight.w700, color: _zeytinKoyu)),
          ),
        ),
      ]),
    );
  }

  // ── HESABIM ───────────────────────────────────────────────────
  Widget _buildHesapKarti() {
    return _buildSection('Hesabım', [
      _buildSatir('Kişisel Bilgiler', Icons.person_outline,
        altyazi: 'Ad, soyad, telefon', onTap: _kisiselBilgilerAc),
      _buildAyrac(),
      _buildSatir('E-posta', Icons.mail_outline,
        altyazi: 'mustafa@example.com', onTap: _epostaAc),
      _buildAyrac(),
      _buildSatir('Şifre', Icons.lock_outline,
        altyazi: 'Şifreni değiştir', onTap: _sifreDegistirAc),
    ], topPadding: 22);
  }

  // ── TERCİHLERİM ───────────────────────────────────────────────
  Widget _buildTercihlerKarti() {
    return _buildSection('Tercihlerim', [
      _buildSatirToggle('Bildirimler', Icons.notifications_outlined,
        altyazi: 'Bildirim ayarlarını yönet',
        deger: _bildirimler, onDegisti: (v) => setState(() => _bildirimler = v)),
      _buildAyrac(),
      _buildSatir('Konum', Icons.location_on_outlined, altyazi: _sehir, onTap: _konumAc),
      _buildAyrac(),
      _buildSatir('Tema', Icons.palette_outlined, altyazi: 'Sistem varsayılanı', onTap: _temaAc),
      _buildAyrac(),
      _buildSatir('Yetiştirme Alanı', Icons.yard_outlined, altyazi: _bahceTipi, onTap: _yetistirmeAlaniAc),
    ]);
  }

  // ── DESTEK ────────────────────────────────────────────────────
  Widget _buildDestekKarti() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 8),
          child: Text('Destek', style: GoogleFonts.cormorantGaramond(
            fontSize: 22, fontWeight: FontWeight.w700, color: _baslikYesil)),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _sinir.withOpacity(0.7)),
            boxShadow: [BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 16, offset: const Offset(0, 5))]),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            child: Row(children: [
              _destekItem(Icons.help_outline, 'Yardım\nMerkezi', null,
                () => _snack('Yardım Merkezi yakında')),
              _destekDivider(),
              _destekItem(Icons.headset_mic_outlined, 'Bize\nUlaşın', null,
                () => _snack('destek@beyazyakaliciftci.com')),
              _destekDivider(),
              _destekItem(Icons.privacy_tip_outlined, 'Gizlilik\nPolitikası', null,
                () => _snack('Gizlilik yakında')),
              _destekDivider(),
              _destekItem(Icons.info_outline, 'Hakkında', 'v1.0.0', null),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _destekItem(IconData icon, String metin, String? altMetin, VoidCallback? onTap) {
    return Expanded(child: GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 30, height: 30,
          decoration: BoxDecoration(color: _ikonBg, borderRadius: BorderRadius.circular(9)),
          child: Icon(icon, size: 15, color: _ikonYesil)),
        const SizedBox(height: 5),
        Text(metin, textAlign: TextAlign.center, style: GoogleFonts.dmSans(
          fontSize: 10, fontWeight: FontWeight.w600,
          color: onTap != null ? _koyu : AppColors.textSecondary, height: 1.3)),
        if (altMetin != null) ...[
          const SizedBox(height: 1),
          Text(altMetin, style: GoogleFonts.dmSans(
            fontSize: 9.5, color: AppColors.textSecondary, height: 1.2)),
        ],
      ]),
    ));
  }

  Widget _destekDivider() => Container(
    width: 1, height: 44, color: _sinir.withOpacity(0.7));

  // ── ÇIKIŞ ─────────────────────────────────────────────────────
  Widget _buildCikisButonu() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: GestureDetector(
        onTap: _cikisOnayla,
        child: Container(
          width: double.infinity, height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFFFDF8F6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFEED8D4).withOpacity(0.8))),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.logout_rounded, size: 16, color: const Color(0xFFB84040).withOpacity(0.80)),
            const SizedBox(width: 8),
            Text('Çıkış Yap', style: GoogleFonts.dmSans(
              fontSize: 14, fontWeight: FontWeight.w600,
              color: const Color(0xFFB84040))),
          ]),
        ),
      ),
    );
  }

  // ── YARDIMCI WIDGET'LAR ───────────────────────────────────────
  Widget _buildSection(String baslik, List<Widget> satirlar, {double topPadding = 20}) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24, topPadding, 24, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 8),
          child: Text(baslik, style: GoogleFonts.cormorantGaramond(
            fontSize: 22, fontWeight: FontWeight.w700, color: _baslikYesil)),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _sinir.withOpacity(0.7)),
            boxShadow: [BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 16, offset: const Offset(0, 5))]),
          child: Column(children: satirlar)),
      ]),
    );
  }

  Widget _buildSatir(String baslik, IconData icon, {
    String? altyazi, VoidCallback? onTap, bool okGoster = true,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(children: [
          Container(
            width: 30, height: 30,
            decoration: BoxDecoration(color: _ikonBg, borderRadius: BorderRadius.circular(9)),
            child: Icon(icon, size: 15, color: _ikonYesil)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(baslik, style: GoogleFonts.dmSans(
              fontSize: 13.5, fontWeight: FontWeight.w600, color: _koyu)),
            if (altyazi != null) ...[
              const SizedBox(height: 1),
              Text(altyazi, style: GoogleFonts.dmSans(
                fontSize: 11.5, color: AppColors.textSecondary)),
            ],
          ])),
          if (okGoster)
            Icon(Icons.chevron_right, size: 16, color: AppColors.textSecondary.withOpacity(0.4)),
        ]),
      ),
    );
  }

  Widget _buildSatirToggle(String baslik, IconData icon, {
    String? altyazi, required bool deger, required ValueChanged<bool> onDegisti,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      child: Row(children: [
        Container(
          width: 30, height: 30,
          decoration: BoxDecoration(color: _ikonBg, borderRadius: BorderRadius.circular(9)),
          child: Icon(icon, size: 15, color: _ikonYesil)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(baslik, style: GoogleFonts.dmSans(
            fontSize: 13.5, fontWeight: FontWeight.w600, color: _koyu)),
          if (altyazi != null) ...[
            const SizedBox(height: 1),
            Text(altyazi, style: GoogleFonts.dmSans(
              fontSize: 11.5, color: AppColors.textSecondary)),
          ],
        ])),
        Transform.scale(
          scale: 0.85,
          child: Switch.adaptive(value: deger, onChanged: onDegisti, activeColor: _zeytinKoyu)),
      ]),
    );
  }

  Widget _buildAyrac() => Padding(
    padding: const EdgeInsets.only(left: 58),
    child: Divider(height: 1, color: _sinir.withOpacity(0.6)),
  );

  // ── FONKSİYONEL AKSIYONLAR ───────────────────────────────────
  void _snack(String mesaj) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(mesaj, style: GoogleFonts.dmSans()),
      behavior: SnackBarBehavior.floating, backgroundColor: _koyu,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  void _profilDuzenle() {
    final adCtrl = TextEditingController(text: 'Mustafa Kocaman');
    _bottomSheet('Profili Düzenle', [
      _formAlani('Ad Soyad', adCtrl),
      const SizedBox(height: 20),
      _kaydetButonu(() { Navigator.pop(context); _snack('Profil güncellendi'); }),
    ]);
  }

  void _kisiselBilgilerAc() {
    final adCtrl = TextEditingController(text: 'Mustafa Kocaman');
    _bottomSheet('Kişisel Bilgiler', [
      _formAlani('Ad Soyad', adCtrl),
      const SizedBox(height: 20),
      _kaydetButonu(() { Navigator.pop(context); _snack('Bilgiler güncellendi'); }),
    ]);
  }

  void _epostaAc() {
    final ctrl = TextEditingController(text: 'mustafa@example.com');
    _bottomSheet('E-posta', [
      _formAlani('E-posta adresi', ctrl, keyboard: TextInputType.emailAddress),
      const SizedBox(height: 20),
      _kaydetButonu(() { Navigator.pop(context); _snack('E-posta güncellendi'); }),
    ]);
  }

  void _sifreDegistirAc() {
    final mevcutCtrl = TextEditingController();
    final yeniCtrl = TextEditingController();
    final tekrarCtrl = TextEditingController();
    _bottomSheet('Şifre Değiştir', [
      _formAlani('Mevcut şifre', mevcutCtrl, gizli: true),
      const SizedBox(height: 10),
      _formAlani('Yeni şifre', yeniCtrl, gizli: true),
      const SizedBox(height: 10),
      _formAlani('Yeni şifre (tekrar)', tekrarCtrl, gizli: true),
      const SizedBox(height: 20),
      _kaydetButonu(() {
        if (yeniCtrl.text != tekrarCtrl.text) { _snack('Şifreler eşleşmiyor'); return; }
        Navigator.pop(context); _snack('Şifre güncellendi');
      }, etiket: 'Güncelle'),
    ]);
  }

  void _yetistirmeAlaniAc() {
    const secenekler = ['Hobi Bahçesi', 'Tarla / Arazi', 'Saksı / Balkon'];
    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          _handle(),
          Text('Yetiştirme Alanı', style: GoogleFonts.dmSans(
            fontSize: 16, fontWeight: FontWeight.w800, color: _koyu)),
          const SizedBox(height: 14),
          ...secenekler.map((s) => GestureDetector(
            onTap: () async {
              await TercihlerServisi.bahceTipiKaydet(s);
              if (mounted) setState(() => _bahceTipi = s);
              if (context.mounted) Navigator.pop(ctx);
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: _bahceTipi == s ? _zeytinAcik : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _bahceTipi == s ? _zeytinKoyu.withOpacity(0.25) : _sinir)),
              child: Row(children: [
                Expanded(child: Text(s, style: GoogleFonts.dmSans(
                  fontSize: 13, fontWeight: FontWeight.w600,
                  color: _bahceTipi == s ? _zeytinKoyu : _koyu))),
                if (_bahceTipi == s) Icon(Icons.check, size: 16, color: _zeytinKoyu),
              ]),
            ),
          )),
        ]),
      ),
    );
  }

  void _konumAc() {
    const sehirler = [
      'Ankara', 'İstanbul', 'İzmir', 'Antalya', 'Bursa',
      'Eskişehir', 'Konya', 'Adana', 'Gaziantep', 'Mersin',
      'Diyarbakır', 'Kayseri', 'Samsun', 'Trabzon', 'Van',
    ];
    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent, isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.55, maxChildSize: 0.85, minChildSize: 0.4,
        builder: (ctx, scroll) => Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
          child: Column(children: [
            Padding(padding: const EdgeInsets.fromLTRB(20, 18, 20, 12), child: Column(children: [
              _handle(),
              Align(alignment: Alignment.centerLeft,
                child: Text('Konum Seç', style: GoogleFonts.dmSans(
                  fontSize: 16, fontWeight: FontWeight.w800, color: _koyu))),
            ])),
            Expanded(child: ListView.builder(
              controller: scroll,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              itemCount: sehirler.length,
              itemBuilder: (ctx, i) {
                final s = sehirler[i];
                final secili = s == _sehir;
                return GestureDetector(
                  onTap: () async {
                    await TercihlerServisi.sehirKaydet(s);
                    if (mounted) setState(() => _sehir = s);
                    if (context.mounted) Navigator.pop(ctx);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
                    margin: const EdgeInsets.only(bottom: 6),
                    decoration: BoxDecoration(
                      color: secili ? _zeytinAcik : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: secili ? _zeytinKoyu.withOpacity(0.25) : _sinir)),
                    child: Row(children: [
                      Expanded(child: Text(s, style: GoogleFonts.dmSans(
                        fontSize: 13, fontWeight: FontWeight.w600,
                        color: secili ? _zeytinKoyu : _koyu))),
                      if (secili) Icon(Icons.check, size: 16, color: _zeytinKoyu),
                    ]),
                  ),
                );
              },
            )),
          ]),
        ),
      ),
    );
  }

  void _temaAc() {
    const temalar = ['Sistem varsayılanı', 'Açık tema', 'Koyu tema'];
    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          _handle(),
          Text('Tema', style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w800, color: _koyu)),
          const SizedBox(height: 14),
          ...temalar.map((t) => GestureDetector(
            onTap: () { Navigator.pop(ctx); _snack('$t seçildi'); },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: t == 'Sistem varsayılanı' ? _zeytinAcik : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: t == 'Sistem varsayılanı' ? _zeytinKoyu.withOpacity(0.25) : _sinir)),
              child: Row(children: [
                Expanded(child: Text(t, style: GoogleFonts.dmSans(
                  fontSize: 13, fontWeight: FontWeight.w600,
                  color: t == 'Sistem varsayılanı' ? _zeytinKoyu : _koyu))),
                if (t == 'Sistem varsayılanı') Icon(Icons.check, size: 16, color: _zeytinKoyu),
              ]),
            ),
          )),
        ]),
      ),
    );
  }

  void _cikisOnayla() {
    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          _handle(),
          Text('Çıkış Yap', style: GoogleFonts.dmSans(
            fontSize: 16, fontWeight: FontWeight.w800, color: _koyu)),
          const SizedBox(height: 8),
          Text('Hesabından çıkmak istediğine emin misin?',
            style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textSecondary),
            textAlign: TextAlign.center),
          const SizedBox(height: 24),
          Row(children: [
            Expanded(child: OutlinedButton(
              onPressed: () => Navigator.pop(ctx),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(color: _sinir),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              child: Text('Vazgeç', style: GoogleFonts.dmSans(
                fontSize: 14, fontWeight: FontWeight.w600, color: _koyu)),
            )),
            const SizedBox(width: 12),
            Expanded(child: ElevatedButton(
              onPressed: () { Navigator.pop(ctx); _snack('Çıkış yapıldı'); },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB84040), foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0),
              child: Text('Çıkış Yap', style: GoogleFonts.dmSans(
                fontSize: 14, fontWeight: FontWeight.w700)),
            )),
          ]),
        ]),
      ),
    );
  }

  void _bottomSheet(String baslik, List<Widget> icerik) {
    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent, isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            _handle(),
            Text(baslik, style: GoogleFonts.dmSans(
              fontSize: 16, fontWeight: FontWeight.w800, color: _koyu)),
            const SizedBox(height: 18),
            ...icerik,
          ]),
        ),
      ),
    );
  }

  Widget _handle() => Center(child: Container(
    width: 36, height: 4, margin: const EdgeInsets.only(bottom: 16),
    decoration: BoxDecoration(color: _sinir, borderRadius: BorderRadius.circular(99))));

  Widget _formAlani(String hint, TextEditingController ctrl, {
    bool gizli = false, TextInputType keyboard = TextInputType.text,
  }) {
    return TextField(
      controller: ctrl, obscureText: gizli, keyboardType: keyboard,
      style: GoogleFonts.dmSans(fontSize: 14, color: _koyu),
      decoration: InputDecoration(
        labelText: hint,
        labelStyle: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textSecondary),
        filled: true, fillColor: _kagit,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _sinir)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _sinir)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _zeytinKoyu)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12)),
    );
  }

  Widget _kaydetButonu(VoidCallback onTap, {String etiket = 'Kaydet'}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: _zeytinKoyu, foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0),
        child: Text(etiket, style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w700)),
      ),
    );
  }
}