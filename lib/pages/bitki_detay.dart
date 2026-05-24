import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';

class BitkiDetayPage extends StatefulWidget {
  const BitkiDetayPage({super.key});

  @override
  State<BitkiDetayPage> createState() => _BitkiDetayPageState();
}

class _BitkiDetayPageState extends State<BitkiDetayPage> {
  final List<bool> _tamamlananlar = [true, false, false];

  final List<Map<String, dynamic>> _gorevler = [
    {'baslik': 'Sulama', 'aciklama': 'Toprağın nemini kontrol et ve sulama yap.', 'icon': Icons.water_drop_outlined},
    {'baslik': 'Gübreleme', 'aciklama': 'Organik sıvı gübre ile besle.', 'icon': Icons.eco_outlined},
    {'baslik': 'Destek Çubuğu Ekle', 'aciklama': 'Bitkini için destek çubuğu yerleştir.', 'icon': Icons.architecture_outlined},
  ];

  final List<Map<String, String>> _asamalar = [
    {'isim': 'Tohum', 'ikon': '💧'},
    {'isim': 'Fide', 'ikon': '🌿'},
    {'isim': 'Büyüme', 'ikon': '📈'},
    {'isim': 'Çiçek', 'ikon': '🌼'},
    {'isim': 'Meyve', 'ikon': '🫐'},
    {'isim': 'Hasat', 'ikon': '🧺'},
  ];

  int _aktifAsama = 2; // Büyüme aşamasında

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAsamaTimeline(),
                _buildBeklenenGelisim(),
                _buildGorevler(),
                _buildSorunBildir(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: AppColors.background,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.more_horiz, color: AppColors.textPrimary),
            onPressed: () {},
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Bitki fotoğrafı placeholder
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF4A7C59), Color(0xFF2D5A27)],
                ),
              ),
              child: const Center(
                child: Text('🍅', style: TextStyle(fontSize: 100)),
              ),
            ),
            // Gradient overlay
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      AppColors.background,
                    ],
                  ),
                ),
              ),
            ),
            // Bitki bilgisi
            Positioned(
              bottom: 16,
              left: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cherry Domates',
                    style: GoogleFonts.dmSans(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Solanum lycopersicum · 7. Hafta',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAsamaTimeline() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Gelişim Aşaması',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.buyume.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  '📈 Büyüme',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.buyume,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: List.generate(_asamalar.length, (index) {
              final aktif = index == _aktifAsama;
              final gecmis = index < _aktifAsama;
              return Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            width: aktif ? 36 : 28,
                            height: aktif ? 36 : 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: aktif
                                  ? AppColors.buyume
                                  : gecmis
                                      ? AppColors.secondary.withOpacity(0.3)
                                      : Colors.white,
                              border: Border.all(
                                color: aktif
                                    ? AppColors.buyume
                                    : gecmis
                                        ? AppColors.secondary
                                        : AppColors.cardBorder,
                                width: aktif ? 2 : 1.5,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                _asamalar[index]['ikon']!,
                                style: TextStyle(fontSize: aktif ? 16 : 12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _asamalar[index]['isim']!,
                            style: GoogleFonts.dmSans(
                              fontSize: 9,
                              color: aktif ? AppColors.buyume : AppColors.textSecondary,
                              fontWeight: aktif ? FontWeight.bold : FontWeight.normal,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    if (index < _asamalar.length - 1)
                      Container(
                        height: 1.5,
                        width: 8,
                        color: gecmis ? AppColors.secondary : AppColors.cardBorder,
                      ),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: 0.45,
              backgroundColor: AppColors.background,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.buyume),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBeklenenGelisim() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.secondary.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🌱', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bu Hafta Beklenen Durum',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Bitki hızlı büyüme döneminde. Destek ve düzenli sulama meyve kalitesini artırır.',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    color: AppColors.primary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGorevler() {
    final tamamlanan = _tamamlananlar.where((t) => t).length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Bu Hafta Yapılacaklar',
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '$tamamlanan / ${_gorevler.length} tamamlandı',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        // Progress bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: tamamlanan / _gorevler.length,
              backgroundColor: AppColors.cardBorder,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondary),
              minHeight: 4,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _gorevler.length,
            separatorBuilder: (_, __) => Divider(height: 1, color: AppColors.cardBorder),
            itemBuilder: (context, index) => _buildGorevSatiri(index),
          ),
        ),
      ],
    );
  }

  Widget _buildGorevSatiri(int index) {
    final gorev = _gorevler[index];
    final tamamlandi = _tamamlananlar[index];
    return InkWell(
      onTap: () => setState(() => _tamamlananlar[index] = !_tamamlananlar[index]),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(gorev['icon'] as IconData, size: 18, color: AppColors.secondary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    gorev['baslik'] as String,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: tamamlandi ? AppColors.textSecondary : AppColors.textPrimary,
                      decoration: tamamlandi ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  Text(
                    gorev['aciklama'] as String,
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Nasıl Yapılır? →',
              style: GoogleFonts.dmSans(
                fontSize: 11,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: tamamlandi ? AppColors.secondary : Colors.transparent,
                border: Border.all(
                  color: tamamlandi ? AppColors.secondary : AppColors.cardBorder,
                  width: 1.5,
                ),
              ),
              child: tamamlandi
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSorunBildir() {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.note_alt_outlined),
              label: Text(
                'Notlarım',
                style: GoogleFonts.dmSans(fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                side: const BorderSide(color: AppColors.cardBorder),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.auto_awesome, size: 18),
              label: Text(
                'Sorun Bildir (AI)',
                style: GoogleFonts.dmSans(fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}