import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';

class BitkiEklePage extends StatefulWidget {
  final Function(Map<String, dynamic>) onBitkiEklendi;
  const BitkiEklePage({super.key, required this.onBitkiEklendi});

  @override
  State<BitkiEklePage> createState() => _BitkiEklePageState();
}

class _BitkiEklePageState extends State<BitkiEklePage> {
  String? _secilenBitki;
  String? _secilenTur;
  String _baslangic = 'tohum';
  int _adim = 0;

  final List<Map<String, dynamic>> _bitkiler = [
    {
      'id': 'domates',
      'isim': 'Domates',
      'emoji': '🍅',
      'turler': ['Cherry Domates', 'Silindir Domates', 'Beef Domates', 'Yumurta Domates'],
    },
    {
      'id': 'biber',
      'isim': 'Biber',
      'emoji': '🌶️',
      'turler': ['Kapya Biber', 'Sivri Biber', 'Dolmalık Biber', 'Carliston Biber'],
    },
    {
      'id': 'salatalik',
      'isim': 'Salatalık',
      'emoji': '🥒',
      'turler': ['Kıtır Salatalık', 'Bornova Salatalık', 'Mini Salatalık'],
    },
    {
      'id': 'patlican',
      'isim': 'Patlıcan',
      'emoji': '🍆',
      'turler': ['Kemer Patlıcan', 'Silindir Patlıcan', 'Baladi Patlıcan'],
    },
    {
      'id': 'fasulye',
      'isim': 'Fasulye',
      'emoji': '🫘',
      'turler': ['Taze Fasulye', 'Sırık Fasulye', 'Bodur Fasulye'],
    },
    {
      'id': 'misir',
      'isim': 'Mısır',
      'emoji': '🌽',
      'turler': ['Şeker Mısır', 'Cin Mısır', 'At Dişi Mısır'],
    },
    {
      'id': 'kavun',
      'isim': 'Kavun',
      'emoji': '🍈',
      'turler': ['Ananas Kavun', 'Kırkağaç Kavun', 'Cantaloup Kavun'],
    },
    {
      'id': 'karpuz',
      'isim': 'Karpuz',
      'emoji': '🍉',
      'turler': ['Crimson Sweet', 'Mini Karpuz', 'Sarı Karpuz'],
    },
    {
      'id': 'kabak',
      'isim': 'Kabak',
      'emoji': '🥬',
      'turler': ['Sakız Kabak', 'Bal Kabak', 'Zucchini'],
    },
  ];

  Map<String, dynamic>? get _secilenBitkiData =>
      _bitkiler.firstWhere((b) => b['id'] == _secilenBitki, orElse: () => {});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildAdimGostergesi(),
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

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (_adim > 0) {
                setState(() => _adim--);
              } else {
                Navigator.pop(context);
              }
            },
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: const Icon(Icons.arrow_back, size: 20, color: AppColors.textPrimary),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            _adim == 0 ? 'Bitki Seç' : _adim == 1 ? 'Tür Seç' : 'Başlangıç',
            style: GoogleFonts.dmSans(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdimGostergesi() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
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
    );
  }

  Widget _buildAdim1() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hangi bitkiyi ekleyeceksin?',
            style: GoogleFonts.dmSans(
              fontSize: 15,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1,
              ),
              itemCount: _bitkiler.length,
              itemBuilder: (context, index) {
                final bitki = _bitkiler[index];
                final secili = _secilenBitki == bitki['id'];
                return GestureDetector(
                  onTap: () => setState(() => _secilenBitki = bitki['id'] as String),
                  child: Container(
                    decoration: BoxDecoration(
                      color: secili ? AppColors.primary.withOpacity(0.1) : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: secili ? AppColors.primary : AppColors.cardBorder,
                        width: secili ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(bitki['emoji'] as String, style: const TextStyle(fontSize: 32)),
                        const SizedBox(height: 6),
                        Text(
                          bitki['isim'] as String,
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            fontWeight: secili ? FontWeight.w600 : FontWeight.normal,
                            color: secili ? AppColors.primary : AppColors.textPrimary,
                          ),
                        ),
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
              onPressed: _secilenBitki != null ? () => setState(() => _adim = 1) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.cardBorder,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(
                'Devam et →',
                style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdim2() {
    final turler = (_secilenBitkiData?['turler'] as List?)?.cast<String>() ?? [];
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hangi türü ekleyeceksin?',
            style: GoogleFonts.dmSans(fontSize: 15, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: turler.length,
              itemBuilder: (context, index) {
                final tur = turler[index];
                final secili = _secilenTur == tur;
                return GestureDetector(
                  onTap: () => setState(() => _secilenTur = tur),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: secili ? AppColors.primary.withOpacity(0.1) : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: secili ? AppColors.primary : AppColors.cardBorder,
                        width: secili ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          _secilenBitkiData?['emoji'] as String? ?? '🌱',
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            tur,
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              fontWeight: secili ? FontWeight.w600 : FontWeight.normal,
                              color: secili ? AppColors.primary : AppColors.textPrimary,
                            ),
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
              onPressed: _secilenTur != null ? () => setState(() => _adim = 2) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.cardBorder,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(
                'Devam et →',
                style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdim3() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nereden başlıyorsun?',
            style: GoogleFonts.dmSans(fontSize: 15, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),
          _buildBaslangicKarti(
            'tohum',
            '🌱',
            'Tohumdan başlıyorum',
            'Henüz toprağa ektim veya ekeceksiniz',
          ),
          const SizedBox(height: 10),
          _buildBaslangicKarti(
            'fide',
            '🪴',
            'Fide aldım',
            'Hazır fide satın aldım',
          ),
          const SizedBox(height: 10),
          _buildBaslangicKarti(
            'tarla',
            '🌿',
            'Tarlaya diktim',
            'Fideyi yerine diktim',
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final yeniBitki = {
                  'id': DateTime.now().millisecondsSinceEpoch.toString(),
                  'bitki_id': _secilenBitki,
                  'isim': _secilenBitkiData?['isim'],
                  'tur': _secilenTur,
                  'emoji': _secilenBitkiData?['emoji'],
                  'hafta': 1,
                  'baslangic': _baslangic,
                  'kayit_tarihi': DateTime.now().toIso8601String(),
                };
                widget.onBitkiEklendi(yeniBitki);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(
                'Bitkimi Ekle 🌱',
                style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBaslangicKarti(String deger, String emoji, String baslik, String aciklama) {
    final secili = _baslangic == deger;
    return GestureDetector(
      onTap: () => setState(() => _baslangic = deger),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: secili ? AppColors.primary.withOpacity(0.08) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: secili ? AppColors.primary : AppColors.cardBorder,
            width: secili ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    baslik,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: secili ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    aciklama,
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
  }
}