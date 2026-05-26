import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pages/ana_ekran.dart';
import 'pages/takvim.dart';
import 'pages/sorun_bildir.dart';
import 'pages/onboarding.dart';
import 'services/tercihler_servisi.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarBrightness: Brightness.dark,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Colors.transparent,
  ));
  runApp(const BeyazYakaliCiftciApp());
}

class BeyazYakaliCiftciApp extends StatelessWidget {
  const BeyazYakaliCiftciApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Beyaz Yakalı Çiftçi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2D5A27),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F2EC),
        cardColor: Colors.white,
        useMaterial3: true,
        textTheme: GoogleFonts.dmSansTextTheme(),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
          ),
        ),
      ),
      home: const GirisKontrol(),
    );
  }
}

class AppColors {
  static const background = Color(0xFFFFFFFF);
  static const surface = Colors.white;
  static const primary = Color(0xFF2D5A27);
  static const secondary = Color(0xFF7A9A3A);
  static const accent = Color(0xFFC4622D);
  static const textPrimary = Color(0xFF1A1A1A);
  static const textSecondary = Color(0xFF888888);
  static const cardBorder = Color(0xFFE8E2D8);
  static const tohum = Color(0xFFAED6A0);
  static const fide = Color(0xFF66BB6A);
  static const tarla = Color(0xFF388E3C);
  static const buyume = Color(0xFF1B5E20);
  static const ciceklenme = Color(0xFFFDD835);
  static const meyve = Color(0xFFFB8C00);
  static const hasat = Color(0xFFE53935);
}

class GirisKontrol extends StatefulWidget {
  const GirisKontrol({super.key});

  @override
  State<GirisKontrol> createState() => _GirisKontrolState();
}

class _GirisKontrolState extends State<GirisKontrol> {
  bool? _onboardingTamamlandi;

  @override
  void initState() {
    super.initState();
    _kontrol();
  }

  Future<void> _kontrol() async {
    final tamamlandi = await TercihlerServisi.onboardingTamamlandiMi();
    setState(() => _onboardingTamamlandi = tamamlandi);
  }

  @override
  Widget build(BuildContext context) {
    if (_onboardingTamamlandi == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (!_onboardingTamamlandi!) {
      return OnboardingPage(
        onTamamla: () => setState(() => _onboardingTamamlandi = true),
      );
    }
    return const AnaSayfa();
  }
}

class AnaSayfa extends StatefulWidget {
  const AnaSayfa({super.key});

  @override
  State<AnaSayfa> createState() => _AnaSayfaState();
}

class _AnaSayfaState extends State<AnaSayfa> {
  int _secilenIndex = 0;

  final List<Widget> _sayfalar = [
    const AnaEkranPage(),
    const TakvimPage(),
    const Scaffold(body: Center(child: Text('Bitkilerim'))),
    const SorunBildirPage(),
    const Scaffold(body: Center(child: Text('Profil'))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  extendBody: true,
  extendBodyBehindAppBar: true,
  backgroundColor: AppColors.background,
  body: _sayfalar[_secilenIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          border: Border(top: BorderSide(color: AppColors.cardBorder, width: 1)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2)),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home_outlined, Icons.home, 'Ana Sayfa'),
                _buildNavItem(1, Icons.calendar_today_outlined, Icons.calendar_today, 'Takvim'),
                _buildNavItem(2, Icons.local_florist_outlined, Icons.local_florist, 'Bitkilerim'),
                _buildNavItem(3, Icons.auto_awesome_outlined, Icons.auto_awesome, 'AI Destek'),
                _buildNavItem(4, Icons.person_outline, Icons.person, 'Profil'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon, String label) {
    final isSelected = _secilenIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _secilenIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isSelected ? activeIcon : icon, size: 22, color: isSelected ? AppColors.primary : AppColors.textSecondary),
            const SizedBox(height: 3),
            Text(label, style: GoogleFonts.dmSans(
              fontSize: 10,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            )),
          ],
        ),
      ),
    );
  }
}