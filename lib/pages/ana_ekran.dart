import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';
import 'bitki_detay.dart';

class AnaEkranPage extends StatelessWidget {
  const AnaEkranPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                _buildHavaDurumu(),
                _buildBitkilerim(context),
                _buildHaftalikGorevler(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Günaydın,',
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              Row(
                children: [
                  Text(
                    'Mustafa',
                    style: GoogleFonts.dmSans(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('🌿', style: TextStyle(fontSize: 24)),
                ],
              ),
              Text(
                'Bahçende 4 görev seni bekliyor.',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          Row(
            children: [
              _buildIconButton(Icons.notifications_outlined),
              const SizedBox(width: 8),
              _buildAddButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Icon(icon, size: 20, color: AppColors.textPrimary),
    );
  }

  Widget _buildAddButton() {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.add, size: 20, color: Colors.white),
    );
  }

  Widget _buildHavaDurumu() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          const Text('☀️', style: TextStyle(fontSize: 36)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '22°C',
                style: GoogleFonts.dmSans(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'Ankara · Güneşli',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHavaDetay('💧', 'Nem %48'),
              const SizedBox(height: 4),
              _buildHavaDetay('💨', 'Rüzgar 12 km/s'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHavaDetay(String emoji, String text) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 13)),
        const SizedBox(width: 4),
        Text(
          text,
          style: GoogleFonts.dmSans(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildBitkilerim(BuildContext context) {
    final bitkiler = [
      {'isim': 'Cherry Domates', 'asama': 'Büyüme Aşaması', 'yuzde': 0.72, 'renk': AppColors.buyume},
      {'isim': 'Salatalık', 'asama': 'Büyüme Aşaması', 'yuzde': 0.45, 'renk': AppColors.tarla},
      {'isim': 'Fesleğen', 'asama': 'Hasada Hazır', 'yuzde': 0.90, 'renk': AppColors.hasat},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Bitkilerim',
                style: GoogleFonts.dmSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'Tümü →',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: bitkiler.length,
            itemBuilder: (context, index) {
              final bitki = bitkiler[index];
              return _buildBitkiKarti(context, bitki);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBitkiKarti(BuildContext context, Map<String, dynamic> bitki) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const BitkiDetayPage()),
      ),
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: const Center(
                child: Text('🌱', style: TextStyle(fontSize: 40)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bitki['isim'] as String,
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    bitki['asama'] as String,
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                      value: bitki['yuzde'] as double,
                      backgroundColor: AppColors.background,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        bitki['renk'] as Color,
                      ),
                      minHeight: 4,
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

  Widget _buildHaftalikGorevler() {
    final gorevler = [
      {'baslik': 'Sulama', 'bitki': 'Cherry Domates', 'durum': 'Bugün', 'tamamlandi': true},
      {'baslik': 'Gübreleme', 'bitki': 'Fesleğen', 'durum': 'Yarın', 'tamamlandi': false},
      {'baslik': 'Destek Çubuğu Ekle', 'bitki': 'Salatalık', 'durum': '2 Gün Kaldı', 'tamamlandi': false},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Bu Haftanın Görevleri',
                style: GoogleFonts.dmSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '2 / 4 tamam',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
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
            itemCount: gorevler.length,
            separatorBuilder: (_, __) => Divider(
              height: 1,
              color: AppColors.cardBorder,
            ),
            itemBuilder: (context, index) {
              final gorev = gorevler[index];
              return _buildGorevSatiri(gorev);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGorevSatiri(Map<String, dynamic> gorev) {
    final tamamlandi = gorev['tamamlandi'] as bool;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.water_drop_outlined, size: 18, color: AppColors.secondary),
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
                  gorev['bitki'] as String,
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            gorev['durum'] as String,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              color: tamamlandi ? AppColors.secondary : AppColors.textSecondary,
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
    );
  }
}