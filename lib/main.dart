import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pages/ana_ekran.dart';

void main() {
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
      ),
      home: const AnaEkranPage(),
    );
  }
}

class AppColors {
  static const background = Color(0xFFF5F2EC);
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