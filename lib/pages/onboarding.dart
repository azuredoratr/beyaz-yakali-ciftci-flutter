import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';
import '../services/tercihler_servisi.dart';


class OnboardingPage extends StatefulWidget {
  final VoidCallback onTamamla;
  const OnboardingPage({super.key, required this.onTamamla});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  int _adim = 0;
  String _secilenSehir = '';
  String _secilenBahce = '';
  final _aramaController = TextEditingController();

  final List<String> _sehirler = [
    'Adana', 'Ankara', 'Antalya', 'Bursa', 'Diyarbakır',
    'Eskişehir', 'Gaziantep', 'İstanbul', 'İzmir', 'Kayseri',
    'Konya', 'Mersin', 'Samsun', 'Trabzon', 'Van',
  ];

  final List<Map<String, dynamic>> _bahceTipleri = [
    {'isim': 'Balkon / Teras', 'aciklama': 'Saksı ve kaplarda, sınırlı alan', 'ikon': '🏢'},
    {'isim': 'Hobi Bahçesi', 'aciklama': 'Küçük-orta boy açık alan', 'ikon': '🏡'},
    {'isim': 'Tarla / Arazi', 'aciklama': 'Geniş açık alan, çok sayıda bitki', 'ikon': '🌾'},
  ];

  List<String> get _filtrelenmis => _sehirler
      .where((s) => s.toLowerCase().contains(_aramaController.text.toLowerCase()))
      .toList();

  @override
  void dispose() {
    _aramaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: i == _adim ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i <= _adim ? AppColors.primary : AppColors.cardBorder,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  );
                }),
              ),
            ),
            Expanded(
              child: IndexedStack(
                index: _adim,
                children: [
                  _buildAdim1(),
                  _buildAdim2(),
                  _buildAdim3(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdim1() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('🌱', style: TextStyle(fontSize: 80)),
            ),
          ),
          const SizedBox(height: 40),
          Text(
            'Kendi doğanı\nyetiştir.',
            style: GoogleFonts.dmSans(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Tohumdan hasada, bitkilerinle birlikte büyü.',
            style: GoogleFonts.dmSans(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 60),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => setState(() => _adim = 1),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'Başlayalım →',
                style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdim2() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hangi şehirdesin?',
            style: GoogleFonts.dmSans(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'İklime göre ekim takviminizi ayarlayalım',
            style: GoogleFonts.dmSans(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _aramaController,
            onChanged: (_) => setState(() {}),
            style: GoogleFonts.dmSans(fontSize: 14, color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Şehir ara...',
              hintStyle: GoogleFonts.dmSans(color: AppColors.textSecondary),
              prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
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
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: _filtrelenmis.length,
              itemBuilder: (context, index) {
                final sehir = _filtrelenmis[index];
                final secili = _secilenSehir == sehir;
                return GestureDetector(
                  onTap: () => setState(() => _secilenSehir = sehir),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: secili ? AppColors.primary.withOpacity(0.1) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: secili ? AppColors.primary : AppColors.cardBorder,
                        width: secili ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          sehir,
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            fontWeight: secili ? FontWeight.w600 : FontWeight.normal,
                            color: secili ? AppColors.primary : AppColors.textPrimary,
                          ),
                        ),
                        if (secili)
                          const Icon(Icons.check_circle, color: AppColors.primary, size: 20),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _secilenSehir.isNotEmpty ? () => setState(() => _adim = 2) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.cardBorder,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'Devam et →',
                style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdim3() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bahçen nasıl?',
            style: GoogleFonts.dmSans(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Öneriler buna göre ayarlanır',
            style: GoogleFonts.dmSans(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              itemCount: _bahceTipleri.length,
              itemBuilder: (context, index) {
                final tip = _bahceTipleri[index];
                final secili = _secilenBahce == tip['isim'];
                return GestureDetector(
                  onTap: () => setState(() => _secilenBahce = tip['isim'] as String),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: secili ? AppColors.primary.withOpacity(0.08) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: secili ? AppColors.primary : AppColors.cardBorder,
                        width: secili ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(tip['ikon'] as String, style: const TextStyle(fontSize: 32)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tip['isim'] as String,
                                style: GoogleFonts.dmSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: secili ? AppColors.primary : AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                tip['aciklama'] as String,
                                style: GoogleFonts.dmSans(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (secili)
                          const Icon(Icons.check_circle, color: AppColors.primary, size: 22),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _secilenBahce.isNotEmpty ? () async {
  await TercihlerServisi.sehirKaydet(_secilenSehir);
  await TercihlerServisi.bahceTipiKaydet(_secilenBahce);
  widget.onTamamla();
} : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.cardBorder,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'Bahçemi Kur 🌱',
                style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}