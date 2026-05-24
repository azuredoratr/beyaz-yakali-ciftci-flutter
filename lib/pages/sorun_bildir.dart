import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';

class SorunBildirPage extends StatefulWidget {
  const SorunBildirPage({super.key});

  @override
  State<SorunBildirPage> createState() => _SorunBildirPageState();
}

class _SorunBildirPageState extends State<SorunBildirPage> {
  int? _secilenKategori;
  final _aciklamaController = TextEditingController();
  bool _yukleniyor = false;
  String? _sonuc;

  final List<Map<String, dynamic>> _kategoriler = [
    {'isim': 'Yapraklar', 'ikon': Icons.eco_outlined},
    {'isim': 'Gövde', 'ikon': Icons.grass_outlined},
    {'isim': 'Meyve', 'ikon': Icons.circle_outlined},
    {'isim': 'Kök / Toprak', 'ikon': Icons.landslide_outlined},
    {'isim': 'Zararlı / Böcek', 'ikon': Icons.bug_report_outlined},
    {'isim': 'Genel', 'ikon': Icons.help_outline},
  ];

  @override
  void initState() {
    super.initState();
    _aciklamaController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _aciklamaController.dispose();
    super.dispose();
  }

  Future<void> _teshisYap() async {
    setState(() {
      _yukleniyor = true;
      _sonuc = null;
    });
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _yukleniyor = false;
      _sonuc = '🔍 Olası sebep: Yapraklardaki sararma aşırı sulama veya besin eksikliğinden kaynaklanıyor olabilir.\n\n✅ Ne yapmalısın:\n• Toprağın nemini kontrol et — 2-3 cm derinlikte kuru hissediyorsa sulama zamanı\n• Azotlu gübre uygula — haftada bir\n• Yapraklara değdirmeden sadece kök bölgesini sula\n\n⚠️ Uyarı: Belirti devam ederse yakın bir ziraat mühendisine danış.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildBitkiKarti(),
            _buildFotograf(),
            _buildKategoriler(),
            _buildAciklama(),
            _buildTeshisButonu(),
            if (_sonuc != null) _buildSonuc(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sorun Bildir',
                style: GoogleFonts.dmSans(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'AI ile teşhis et',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBitkiKarti() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          const Text('🍅', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cherry Domates',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '7. hafta · Büyüme Aşaması',
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const Spacer(),
          const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        ],
      ),
    );
  }

  Widget _buildFotograf() {
    return GestureDetector(
      onTap: () {},
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.camera_alt_outlined, size: 22, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Text(
              'Fotoğraf Ekle',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              'Sorunlu bölgeyi fotoğrafla',
              style: GoogleFonts.dmSans(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKategoriler() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Text(
            'Sorun Nerede?',
            style: GoogleFonts.dmSans(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.4,
          ),
          itemCount: _kategoriler.length,
          itemBuilder: (context, index) {
            final secili = _secilenKategori == index;
            return GestureDetector(
              onTap: () => setState(() => _secilenKategori = index),
              child: Container(
                decoration: BoxDecoration(
                  color: secili ? AppColors.primary.withOpacity(0.1) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: secili ? AppColors.primary : AppColors.cardBorder,
                    width: secili ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _kategoriler[index]['ikon'] as IconData,
                      size: 22,
                      color: secili ? AppColors.primary : AppColors.textSecondary,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _kategoriler[index]['isim'] as String,
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        fontWeight: secili ? FontWeight.w600 : FontWeight.normal,
                        color: secili ? AppColors.primary : AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAciklama() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Açıklama',
            style: GoogleFonts.dmSans(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _aciklamaController,
            maxLines: 4,
            style: GoogleFonts.dmSans(fontSize: 14, color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Örn: Yapraklar sararıyor, alt yapraklarda kahverengi lekeler var...',
              hintStyle: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textSecondary),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.cardBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.cardBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeshisButonu() {
    final aktif = _aciklamaController.text.isNotEmpty || _secilenKategori != null;
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: aktif && !_yukleniyor ? _teshisYap : null,
        icon: _yukleniyor
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.auto_awesome, size: 18),
        label: Text(
          _yukleniyor ? 'Analiz ediliyor...' : 'AI ile Teşhis Et',
          style: GoogleFonts.dmSans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.cardBorder,
          disabledForegroundColor: AppColors.textSecondary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  Widget _buildSonuc() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, size: 16, color: AppColors.secondary),
              const SizedBox(width: 6),
              Text(
                'AI Teşhis',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _sonuc!,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: AppColors.textPrimary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Bu bir öneri niteliğindedir. Emin değilsen bir ziraat mühendisine danış.',
            style: GoogleFonts.dmSans(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}