import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

  final List<Map<String, dynamic>> _asamalar = [
    {'isim': 'Tohum', 'emoji': '🌱', 'renk': AppColors.tohum},
    {'isim': 'Fide', 'emoji': '🪴', 'renk': AppColors.fide},
    {'isim': 'Büyüme', 'emoji': '🌿', 'renk': AppColors.buyume},
    {'isim': 'Çiçeklenme', 'emoji': '🌸', 'renk': AppColors.ciceklenme},
    {'isim': 'Meyve', 'emoji': '🍅', 'renk': AppColors.meyve},
    {'isim': 'Hasat', 'emoji': '🧺', 'renk': AppColors.hasat},
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

  @override
  void initState() {
    super.initState();
    _yukle();
  }

  Future<void> _yukle() async {
    final bitkiId = widget.bitki['bitki_id'] as String? ?? '';
    final hafta = widget.bitki['hafta'] as int? ?? 1;
    final baslangic = widget.bitki['baslangic'] as String? ?? 'tohum';

    final gorevler = await GorevServisi.gorevleriGetir(
      bitkiId: bitkiId,
      hafta: hafta,
      baslangic: baslangic,
    );

    final tamamlananlar = await GorevServisi.tamamlananGorevler(bitkiId, hafta);

    setState(() {
      _gorevler = gorevler;
      _tamamlananlar = tamamlananlar;
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
    final onay = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Bitkiyi Sil', style: GoogleFonts.dmSans(fontWeight: FontWeight.bold)),
        content: Text('${widget.bitki['tur']} bitkisini silmek istediğinden emin misin?', style: GoogleFonts.dmSans()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('İptal', style: GoogleFonts.dmSans())),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Sil', style: GoogleFonts.dmSans(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
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

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Arka plan — bitkinin kendi fotoğrafı
          if (fotografYolu != null)
            Positioned.fill(
              child: Image.asset(fotografYolu, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(color: const Color(0xFF1B4332))),
            )
          else
            Positioned.fill(child: Container(color: const Color(0xFF1B4332))),

          // Beyaz overlay — ana ekrandaki gibi
          Positioned.fill(
            child: Container(color: Colors.white.withOpacity(0.55)),
          ),

          CustomScrollView(
            slivers: [
              // Üst alan — fotoğraf + bitki adı
              SliverToBoxAdapter(child: _buildUstAlan(tur, hafta, fotografYolu)),
              // İçerik
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAsamaTimeline(),
                      const SizedBox(height: 20),
                      if (_yukleniyor)
                        const Center(child: CircularProgressIndicator())
                      else
                        _buildGorevler(),
                      const SizedBox(height: 20),
                      _buildAltButonlar(),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUstAlan(String tur, int hafta, String? fotografYolu) {
    final topPadding = MediaQuery.of(context).padding.top;
    return SizedBox(
      height: 280,
      child: Stack(
        children: [
          // Fotoğraf
          Positioned.fill(
            child: fotografYolu != null
                ? Image.asset(fotografYolu, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: const Color(0xFF1B4332)))
                : Container(color: const Color(0xFF1B4332)),
          ),
          // Alt gradient
          Positioned(
            bottom: 0, left: 0, right: 0, height: 140,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.65)],
                ),
              ),
            ),
          ),
          // Geri butonu — sol üst
          Positioned(
            top: topPadding + 12, left: 20,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.4), width: 1),
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
              ),
            ),
          ),
          // Çöp kutusu — sağ üst
          Positioned(
            top: topPadding + 12, right: 20,
            child: GestureDetector(
              onTap: _bitkiSil,
              child: Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.4), width: 1),
                ),
                child: const Icon(Icons.delete_outline, color: Colors.white, size: 20),
              ),
            ),
          ),
          // Bitki adı — alt sol
          Positioned(
            bottom: 20, left: 20, right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tur, style: GoogleFonts.dmSans(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white)),
                Text('$hafta. hafta · ${_asamalar[_aktifAsama]['isim']} Aşaması',
                    style: GoogleFonts.dmSans(fontSize: 13, color: Colors.white.withOpacity(0.85))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAsamaTimeline() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.75),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.9), width: 1.5),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Gelişim Aşaması', style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 14),
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
                    width: 38, height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: aktif ? AppColors.primary : gecmis ? AppColors.secondary.withOpacity(0.2) : Colors.white,
                      border: Border.all(
                        color: aktif ? AppColors.primary : gecmis ? AppColors.secondary : AppColors.cardBorder,
                        width: aktif ? 2 : 1,
                      ),
                    ),
                    child: Center(child: Text(asama['emoji'] as String, style: TextStyle(fontSize: aktif ? 18 : 14))),
                  ),
                  const SizedBox(height: 4),
                  Text(asama['isim'] as String, style: GoogleFonts.dmSans(
                    fontSize: 9,
                    fontWeight: aktif ? FontWeight.w700 : FontWeight.normal,
                    color: aktif ? AppColors.primary : AppColors.textSecondary,
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
          color: Colors.white.withOpacity(0.75),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.9), width: 1.5),
        ),
        child: Center(
          child: Text('Bu hafta için görev bulunamadı.', style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textSecondary)),
        ),
      );
    }

    final tamamlanan = _tamamlananlar.length;
    final toplam = _gorevler.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Bu Hafta Yapılacaklar', style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            Text('$tamamlanan / $toplam tamamlandı', style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.secondary, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.75),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.9), width: 1.5),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 16, offset: const Offset(0, 4))],
          ),
          child: Column(
            children: _gorevler.asMap().entries.map((e) {
              final i = e.key;
              final g = e.value;
              return Column(
                children: [
                  _buildGorevSatiri(g),
                  if (i < _gorevler.length - 1)
                    Divider(height: 1, color: AppColors.cardBorder.withOpacity(0.5), indent: 60),
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
                color: tamamlandi ? AppColors.secondary : Colors.white,
border: Border.all(color: tamamlandi ? AppColors.secondary : AppColors.primary.withOpacity(0.4), width: 1.5),
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
                  color: tamamlandi ? AppColors.textSecondary : AppColors.textPrimary,
                  decoration: tamamlandi ? TextDecoration.lineThrough : null,
                )),
                if (gorev['aciklama'] != null && (gorev['aciklama'] as String).isNotEmpty)
                  Text(gorev['aciklama'] as String, style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.textSecondary)),
                if (not != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text('📝 $not', style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.primary, fontStyle: FontStyle.italic)),
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
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Text('Nasıl?', style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600)),
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
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
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
                  const Text('• ', style: TextStyle(color: AppColors.primary, fontSize: 14)),
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

  Widget _buildAltButonlar() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.note_add_outlined, size: 16),
            label: Text('Not Ekle', style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600)),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textPrimary,
              side: const BorderSide(color: AppColors.cardBorder),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              backgroundColor: Colors.white.withOpacity(0.75),
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
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
          ),
        ),
      ],
    );
  }
}