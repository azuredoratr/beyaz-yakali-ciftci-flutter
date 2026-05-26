import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';
import 'ana_ekran.dart';

class BitkiDetayPage extends StatefulWidget {
  final Map<String, dynamic> bitki;
  const BitkiDetayPage({super.key, required this.bitki});

  @override
  State<BitkiDetayPage> createState() => _BitkiDetayPageState();
}

class _BitkiDetayPageState extends State<BitkiDetayPage> {
  final List<Map<String, dynamic>> _gorevler = [
    {'baslik': 'Sulama', 'aciklama': 'Toprağın nemini kontrol et ve sulama yap.', 'tamamlandi': true, 'nasil': true},
    {'baslik': 'Gübreleme', 'aciklama': 'Organik sıvı gübre ile besle.', 'tamamlandi': false, 'nasil': false},
    {'baslik': 'Destek Çubuğu Ekle', 'aciklama': 'Bitki için destek çubuğu yerleştir.', 'tamamlandi': false, 'nasil': true},
  ];

  final List<Map<String, dynamic>> _asamalar = [
    {'isim': 'Tohum', 'ikon': '🌱', 'renk': AppColors.tohum},
    {'isim': 'Fide', 'ikon': '🪴', 'renk': AppColors.fide},
    {'isim': 'Büyüme', 'ikon': '🌿', 'renk': AppColors.buyume},
    {'isim': 'Çiçeklenme', 'ikon': '🌸', 'renk': AppColors.ciceklenme},
    {'isim': 'Meyve', 'ikon': '🍅', 'renk': AppColors.meyve},
    {'isim': 'Hasat', 'ikon': '🧺', 'renk': AppColors.hasat},
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
  Widget build(BuildContext context) {
    final turId = widget.bitki['tur_id'] as String?;
    final fotografYolu = turFotografGetir(turId);
    final tur = widget.bitki['tur'] as String? ?? widget.bitki['ad'] as String? ?? '';
    final hafta = widget.bitki['hafta'] as int? ?? 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Üst fotoğraf alanı
          SliverToBoxAdapter(
            child: Stack(
              children: [
                // Fotoğraf
                SizedBox(
                  height: 300,
                  width: double.infinity,
                  child: fotografYolu != null
                      ? Image.asset(
                          fotografYolu,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: const Color(0xFF1B4332),
                            child: Center(
                              child: Text(
                                widget.bitki['emoji'] as String? ?? '🌱',
                                style: const TextStyle(fontSize: 80),
                              ),
                            ),
                          ),
                        )
                      : Container(
                          color: const Color(0xFF1B4332),
                          child: Center(
                            child: Text(
                              widget.bitki['emoji'] as String? ?? '🌱',
                              style: const TextStyle(fontSize: 80),
                            ),
                          ),
                        ),
                ),
                // Alt gradient
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 120,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.6),
                        ],
                      ),
                    ),
                  ),
                ),
                // Geri butonu
                Positioned(
                  top: 52,
                  left: 20,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                    ),
                  ),
                ),
                // Bitki adı — alt sol
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tur,
                        style: GoogleFonts.dmSans(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '$hafta. hafta · ${_asamalar[_aktifAsama]['isim']} Aşaması',
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

          // İçerik
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAsamaTimeline(),
                  const SizedBox(height: 24),
                  _buildGorevler(),
                  const SizedBox(height: 24),
                  _buildAltButonlar(),
                  const SizedBox(height: 100),
                ],
              ),
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
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gelişim Aşaması',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
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
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: aktif
                          ? AppColors.primary
                          : gecmis
                              ? AppColors.secondary.withOpacity(0.2)
                              : AppColors.background,
                      border: Border.all(
                        color: aktif
                            ? AppColors.primary
                            : gecmis
                                ? AppColors.secondary
                                : AppColors.cardBorder,
                        width: aktif ? 2 : 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        asama['ikon'] as String,
                        style: TextStyle(fontSize: aktif ? 18 : 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    asama['isim'] as String,
                    style: GoogleFonts.dmSans(
                      fontSize: 9,
                      fontWeight: aktif ? FontWeight.w700 : FontWeight.normal,
                      color: aktif ? AppColors.primary : AppColors.textSecondary,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildGorevler() {
    final tamamlanan = _gorevler.where((g) => g['tamamlandi'] as bool).length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Bu Hafta Yapılacaklar',
              style: GoogleFonts.dmSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              '$tamamlanan / ${_gorevler.length} tamamlandı',
              style: GoogleFonts.dmSans(
                fontSize: 12,
                color: AppColors.secondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: _gorevler.asMap().entries.map((e) {
              final i = e.key;
              final g = e.value;
              return Column(
                children: [
                  _buildGorevSatiri(i, g),
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

  Widget _buildGorevSatiri(int index, Map<String, dynamic> gorev) {
    final tamamlandi = gorev['tamamlandi'] as bool;
    final nasil = gorev['nasil'] as bool;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => setState(() => gorev['tamamlandi'] = !tamamlandi),
            child: Container(
              width: 28,
              height: 28,
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
                  style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          if (nasil)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Text(
                'Nasıl?',
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAltButonlar() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.note_outlined, size: 16),
            label: Text('Notlarım', style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600)),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textPrimary,
              side: const BorderSide(color: AppColors.cardBorder),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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