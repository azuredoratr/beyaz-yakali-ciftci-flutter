import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';

class TakvimPage extends StatefulWidget {
  const TakvimPage({super.key});

  @override
  State<TakvimPage> createState() => _TakvimPageState();
}

class _TakvimPageState extends State<TakvimPage> {
  final List<Map<String, dynamic>> _bitkiler = [
    {
      'isim': 'Cherry Domates',
      'emoji': '🍅',
      'hafta': 7,
      'toplamHafta': 18,
      'aktifAsama': 2,
      'asamalar': [
        {'isim': 'Tohum', 'ikon': '💧', 'renk': 0xFFAED6A0},
        {'isim': 'Fide', 'ikon': '🌿', 'renk': 0xFF66BB6A},
        {'isim': 'Büyüme', 'ikon': '📈', 'renk': 0xFF1B5E20},
        {'isim': 'Çiçek', 'ikon': '🌼', 'renk': 0xFFFDD835},
        {'isim': 'Meyve', 'ikon': '🫐', 'renk': 0xFFFB8C00},
        {'isim': 'Hasat', 'ikon': '🧺', 'renk': 0xFFE53935},
      ],
    },
    {
      'isim': 'Salatalık',
      'emoji': '🥒',
      'hafta': 4,
      'toplamHafta': 12,
      'aktifAsama': 1,
      'asamalar': [
        {'isim': 'Tohum', 'ikon': '💧', 'renk': 0xFFAED6A0},
        {'isim': 'Fide', 'ikon': '🌿', 'renk': 0xFF66BB6A},
        {'isim': 'Büyüme', 'ikon': '📈', 'renk': 0xFF1B5E20},
        {'isim': 'Çiçek', 'ikon': '🌼', 'renk': 0xFFFDD835},
        {'isim': 'Meyve', 'ikon': '🫐', 'renk': 0xFFFB8C00},
        {'isim': 'Hasat', 'ikon': '🧺', 'renk': 0xFFE53935},
      ],
    },
    {
      'isim': 'Fesleğen',
      'emoji': '🌿',
      'hafta': 10,
      'toplamHafta': 12,
      'aktifAsama': 5,
      'asamalar': [
        {'isim': 'Tohum', 'ikon': '💧', 'renk': 0xFFAED6A0},
        {'isim': 'Fide', 'ikon': '🌿', 'renk': 0xFF66BB6A},
        {'isim': 'Büyüme', 'ikon': '📈', 'renk': 0xFF1B5E20},
        {'isim': 'Çiçek', 'ikon': '🌼', 'renk': 0xFFFDD835},
        {'isim': 'Meyve', 'ikon': '🫐', 'renk': 0xFFFB8C00},
        {'isim': 'Hasat', 'ikon': '🧺', 'renk': 0xFFE53935},
      ],
    },
  ];

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
                _buildAylar(),
                ..._bitkiler.map((bitki) => _buildBitkiKarti(bitki)),
                _buildRenkAciklamasi(),
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
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sezon Takvimi',
                style: GoogleFonts.dmSans(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '2026 sezonu · Ankara',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: const Icon(Icons.filter_list, size: 20, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildAylar() {
    final aylar = ['Mar', 'Nis', 'May', 'Haz', 'Tem', 'Ağu', 'Eyl', 'Eki'];
    final bugunAy = DateTime.now().month - 3; // Mart = 0

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Row(
        children: List.generate(aylar.length, (i) {
          final aktif = i == bugunAy;
          return Expanded(
            child: Text(
              aylar[i],
              style: GoogleFonts.dmSans(
                fontSize: 10,
                color: aktif ? AppColors.accent : AppColors.textSecondary,
                fontWeight: aktif ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBitkiKarti(Map<String, dynamic> bitki) {
    final asamalar = bitki['asamalar'] as List<Map<String, dynamic>>;
    final aktifAsama = bitki['aktifAsama'] as int;
    final hafta = bitki['hafta'] as int;
    final toplamHafta = bitki['toplamHafta'] as int;
    final ilerleme = hafta / toplamHafta;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bitki başlık
          Row(
            children: [
              Text(bitki['emoji'] as String, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bitki['isim'] as String,
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${bitki['hafta']}. hafta',
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Color(asamalar[aktifAsama]['renk'] as int).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  '${asamalar[aktifAsama]['ikon']} ${asamalar[aktifAsama]['isim']}',
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(asamalar[aktifAsama]['renk'] as int),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Aşama ikonları
          Stack(
            children: [
              // Bağlantı çizgisi
              Positioned(
                top: 14,
                left: 14,
                right: 14,
                child: Container(height: 1, color: AppColors.cardBorder),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(asamalar.length, (i) {
                  final aktif = i == aktifAsama;
                  final gecmis = i < aktifAsama;
                  final renk = Color(asamalar[i]['renk'] as int);
                  return Column(
                    children: [
                      Container(
                        width: aktif ? 30 : 24,
                        height: aktif ? 30 : 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: aktif ? renk : gecmis ? renk.withOpacity(0.3) : Colors.white,
                          border: Border.all(
                            color: aktif ? renk : gecmis ? renk : AppColors.cardBorder,
                            width: aktif ? 2 : 1.5,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            asamalar[i]['ikon'] as String,
                            style: TextStyle(fontSize: aktif ? 14 : 10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        asamalar[i]['isim'] as String,
                        style: GoogleFonts.dmSans(
                          fontSize: 8,
                          color: aktif ? renk : AppColors.textSecondary,
                          fontWeight: aktif ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Sezon şeridi
          Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: SizedBox(
                  height: 8,
                  child: Row(
                    children: List.generate(asamalar.length, (i) {
                      return Expanded(
                        child: Container(
                          color: Color(asamalar[i]['renk'] as int),
                        ),
                      );
                    }),
                  ),
                ),
              ),
              // İlerleme noktası
              Positioned(
                left: (MediaQuery.of(context).size.width - 80) * ilerleme - 6,
                top: -3,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(
                      color: Color(asamalar[aktifAsama]['renk'] as int),
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 4,
                      ),
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

  Widget _buildRenkAciklamasi() {
    final asamalar = [
      {'isim': 'Tohum', 'renk': AppColors.tohum},
      {'isim': 'Fide', 'renk': AppColors.fide},
      {'isim': 'Büyüme', 'renk': AppColors.buyume},
      {'isim': 'Çiçek', 'renk': AppColors.ciceklenme},
      {'isim': 'Meyve', 'renk': AppColors.meyve},
      {'isim': 'Hasat', 'renk': AppColors.hasat},
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        children: asamalar.map((a) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: a['renk'] as Color,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                a['isim'] as String,
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}