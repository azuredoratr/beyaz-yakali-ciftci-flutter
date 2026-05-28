import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';

class BitkiEklePage extends StatefulWidget {
  final Function(Map<String, dynamic>) onBitkiEklendi;
  const BitkiEklePage({super.key, required this.onBitkiEklendi});

  @override
  State<BitkiEklePage> createState() => _BitkiEklePageState();
}

class _BitkiEklePageState extends State<BitkiEklePage> {
  Map<String, dynamic>? _bitkilerData;
  Map<String, dynamic>? _secilenBitki;
  Map<String, dynamic>? _secilenTur;
  String? _baslangic;
  String? _fideAlt;
  String _ekimTarihi = '';
  Map<String, dynamic>? _secilenBoy;

  @override
  void initState() {
    super.initState();
    _jsonYukle();
  }

  Future<void> _jsonYukle() async {
    final str = await rootBundle.loadString('lib/data/bitkiler.json');
    setState(() => _bitkilerData = jsonDecode(str));
  }

  List<Map<String, dynamic>> get _bitkiler {
    if (_bitkilerData == null) return [];
    return (_bitkilerData!['bitkiler'] as Map).values.map((v) => v as Map<String, dynamic>).toList();
  }

  List<Map<String, dynamic>> get _turler {
    if (_secilenBitki == null) return [];
    return (_secilenBitki!['alt_turler'] as List).map((v) => v as Map<String, dynamic>).toList();
  }

  List<Map<String, dynamic>> get _fideRehberi {
    if (_secilenBitki == null) return [];
    final rehber = _secilenBitki!['fide_boy_rehberi'];
    if (rehber == null) return [];
    return (rehber as List).map((v) => v as Map<String, dynamic>).toList();
  }

  int get _dikimHaftasi {
    if (_secilenBitki == null) return 7;
    return (_secilenBitki!['asama_sureleri']?['tohum_fide_hafta'] ?? 6) + 1;
  }

  int _haftaHesapla() {
    if (_baslangic == 'tohum' && _ekimTarihi.isNotEmpty) {
      final ekim = DateTime.parse(_ekimTarihi);
      final fark = DateTime.now().difference(ekim).inDays;
      return (fark / 7).floor() + 1;
    }
    if (_baslangic == 'fide') {
      if (_fideAlt == 'boy' && _secilenBoy != null) return _secilenBoy!['hafta'] as int;
      if (_fideAlt == 'tohum' && _ekimTarihi.isNotEmpty) {
        final ekim = DateTime.parse(_ekimTarihi);
        final fark = DateTime.now().difference(ekim).inDays;
        return (fark / 7).floor() + 1;
      }
      if (_fideAlt == 'tarla') return _dikimHaftasi;
    }
    return 1;
  }

  String _hesaplaEkimTarihi() {
    if (_ekimTarihi.isNotEmpty) return _ekimTarihi;
    if (_baslangic == 'fide' && _fideAlt == 'boy' && _secilenBoy != null) {
      final hafta = _secilenBoy!['hafta'] as int;
      final ekim = DateTime.now().subtract(Duration(days: hafta * 7));
      return ekim.toIso8601String().split('T')[0];
    }
    if (_baslangic == 'fide' && _fideAlt == 'tarla') {
      final ekim = DateTime.now().subtract(Duration(days: _dikimHaftasi * 7));
      return ekim.toIso8601String().split('T')[0];
    }
    return DateTime.now().toIso8601String().split('T')[0];
  }

  bool get _hazirMi {
    if (_secilenBitki == null || _secilenTur == null || _baslangic == null) return false;
    if (_baslangic == 'tohum') return _ekimTarihi.isNotEmpty;
    if (_baslangic == 'fide') {
      if (_fideAlt == null) return false;
      if (_fideAlt == 'boy') return _secilenBoy != null;
      if (_fideAlt == 'tohum') return _ekimTarihi.isNotEmpty;
      if (_fideAlt == 'tarla') return true;
    }
    return false;
  }

  void _bitkiEkle() {
    if (!_hazirMi) return;
    final baslangicHafta = _haftaHesapla();
    final ekimTarihi = _hesaplaEkimTarihi();
    final yeniBitki = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'bitki_id': _secilenBitki!['genel']['id'],
      'ad': _secilenBitki!['genel']['ad'],
      'tur': _secilenTur!['ad'],
      'tur_id': _secilenTur!['id'],
      'emoji': _secilenBitki!['genel']['emoji'],
      'baslangic': _baslangic,
      'ekim_tarihi': ekimTarihi,
      'kayit_tarihi': DateTime.now().toIso8601String(),
      'baslangic_hafta': baslangicHafta,
      'hafta': baslangicHafta,
      'yuzde': baslangicHafta / 18.0,
    };
    widget.onBitkiEklendi(yeniBitki);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (_bitkilerData == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionLabel('Sebze Seç'),
                    const SizedBox(height: 8),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 2.2,
                      ),
                      itemCount: _bitkiler.length,
                      itemBuilder: (context, index) {
                        final bitki = _bitkiler[index];
                        final secili = _secilenBitki?['genel']['id'] == bitki['genel']['id'];
                        return GestureDetector(
                          onTap: () => setState(() {
                            _secilenBitki = bitki; _secilenTur = null; _baslangic = null;
                            _fideAlt = null; _ekimTarihi = ''; _secilenBoy = null;
                          }),
                          child: Container(
                            decoration: BoxDecoration(
                              color: secili ? AppColors.primary.withOpacity(0.08) : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: secili ? AppColors.primary : AppColors.cardBorder, width: secili ? 2 : 1),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(bitki['genel']['emoji'] ?? '🌱', style: const TextStyle(fontSize: 20)),
                                const SizedBox(width: 8),
                                Text(bitki['genel']['ad'], style: GoogleFonts.dmSans(fontSize: 13, fontWeight: secili ? FontWeight.bold : FontWeight.normal, color: secili ? AppColors.primary : AppColors.textPrimary)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    if (_secilenBitki != null) ...[
                      const SizedBox(height: 24),
                      _buildSectionLabel('Çeşit Seç'),
                      const SizedBox(height: 8),
                      ..._turler.map((tur) {
                        final secili = _secilenTur?['id'] == tur['id'];
                        return GestureDetector(
                          onTap: () => setState(() { _secilenTur = tur; _baslangic = null; _fideAlt = null; _ekimTarihi = ''; _secilenBoy = null; }),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 6),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: secili ? AppColors.primary.withOpacity(0.08) : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: secili ? AppColors.primary : AppColors.cardBorder, width: secili ? 2 : 1),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(tur['ad'] ?? '', style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.bold, color: secili ? AppColors.primary : AppColors.textPrimary)),
                                if (tur['halk_adi'] != null && (tur['halk_adi'] as List).isNotEmpty)
                                  Text((tur['halk_adi'] as List).join(', '), style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textSecondary)),
                                if (tur['aciklama'] != null)
                                  Text(tur['aciklama'], style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                    if (_secilenTur != null) ...[
                      const SizedBox(height: 24),
                      _buildSectionLabel('Başlangıç Noktası'),
                      const SizedBox(height: 8),
                      Row(children: [
                        Expanded(child: _buildBaslangicKart('tohum', '🌱', 'Tohumdan')),
                        const SizedBox(width: 8),
                        Expanded(child: _buildBaslangicKart('fide', '🪴', 'Fideden')),
                      ]),
                    ],
                    if (_baslangic == 'tohum') ...[
                      const SizedBox(height: 24),
                      _buildSectionLabel('Tohumu Ne Zaman Ektin?'),
                      const SizedBox(height: 8),
                      _buildTarihSecici(),
                      if (_ekimTarihi.isNotEmpty)
                        Padding(padding: const EdgeInsets.only(top: 8), child: Text('✓ Takvimin ${_haftaHesapla()}. haftadan başlayacak', style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.primary))),
                    ],
                    if (_baslangic == 'fide') ...[
                      const SizedBox(height: 24),
                      _buildSectionLabel('Fiden Hakkında'),
                      const SizedBox(height: 8),
                      _buildFideAltKart('boy', '📏', 'Boy ölç — haftayı tahmin et', 'Fideyi ölç, en yakın boya tıkla'),
                      const SizedBox(height: 6),
                      _buildFideAltKart('tohum', '📅', 'Tohum tarihini biliyorum', 'Tohumlandığı tarihi seç, hafta otomatik hesaplanır'),
                      const SizedBox(height: 6),
                      _buildFideAltKart('tarla', '🌾', 'Tarlaya dikim aşamasından başla', 'Önceki fide aşamaları atlanır, $_dikimHaftasi. haftadan başlar'),
                    ],
                    if (_baslangic == 'fide' && _fideAlt == 'boy' && _fideRehberi.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _buildSectionLabel('Fideni Ölç'),
                      const SizedBox(height: 8),
                      ..._fideRehberi.map((secenek) {
                        final secili = _secilenBoy?['hafta'] == secenek['hafta'];
                        final ideal = secenek['durum'] == 'ideal';
                        return GestureDetector(
                          onTap: () => setState(() => _secilenBoy = secenek),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: secili ? AppColors.primary.withOpacity(0.08) : ideal ? AppColors.secondary.withOpacity(0.05) : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: secili ? AppColors.primary : ideal ? AppColors.secondary.withOpacity(0.5) : AppColors.cardBorder, width: secili ? 2 : 1),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  Text('~${secenek['boy_cm']} cm', style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.bold, color: secili ? AppColors.primary : AppColors.textPrimary)),
                                  const Spacer(),
                                  if (ideal) Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(99)), child: Text('ideal', style: GoogleFonts.dmSans(fontSize: 10, color: Colors.white))),
                                  const SizedBox(width: 6),
                                  Text('${secenek['hafta']}. hafta', style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textSecondary)),
                                ]),
                                const SizedBox(height: 4),
                                Text(secenek['aciklama'] ?? '', style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.textPrimary)),
                                if (secenek['ortam_notu'] != null)
                                  Padding(padding: const EdgeInsets.only(top: 4), child: Text('ℹ️ ${secenek['ortam_notu']}', style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textSecondary, fontStyle: FontStyle.italic))),
                              ],
                            ),
                          ),
                        );
                      }),
                      if (_secilenBoy != null)
                        Text('✓ Takvimin ${_secilenBoy!['hafta']}. haftadan başlayacak', style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.primary)),
                    ],
                    if (_baslangic == 'fide' && _fideAlt == 'tohum') ...[
                      const SizedBox(height: 24),
                      _buildSectionLabel('Tohum Ekim Tarihi'),
                      const SizedBox(height: 8),
                      _buildTarihSecici(),
                      if (_ekimTarihi.isNotEmpty)
                        Padding(padding: const EdgeInsets.only(top: 8), child: Text('✓ Takvimin ${_haftaHesapla()}. haftadan başlayacak', style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.primary))),
                    ],
                    if (_baslangic == 'fide' && _fideAlt == 'tarla') ...[
                      const SizedBox(height: 8),
                      Text('✓ Takvimin $_dikimHaftasi. haftadan (tarlaya dikim) başlayacak', style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.primary)),
                    ],
                    if (_hazirMi) ...[
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _bitkiEkle,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary, foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: Text('Takvimi Oluştur ✓', style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                    const SizedBox(height: 40),
                  ],
                ),
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
            onTap: () => Navigator.pop(context),
            child: Container(width: 42, height: 42, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.cardBorder)), child: const Icon(Icons.arrow_back, size: 20)),
          ),
          const SizedBox(width: 16),
          Text('Bitki Ekle', style: GoogleFonts.dmSans(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(label.toUpperCase(), style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.5));
  }

  Widget _buildBaslangicKart(String deger, String emoji, String baslik) {
    final secili = _baslangic == deger;
    return GestureDetector(
      onTap: () => setState(() { _baslangic = deger; _fideAlt = null; _ekimTarihi = ''; _secilenBoy = null; }),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: secili ? AppColors.primary.withOpacity(0.08) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: secili ? AppColors.primary : AppColors.cardBorder, width: secili ? 2 : 1),
        ),
        child: Column(children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 6),
          Text(baslik, style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.bold, color: secili ? AppColors.primary : AppColors.textPrimary)),
        ]),
      ),
    );
  }

  Widget _buildFideAltKart(String deger, String emoji, String baslik, String aciklama) {
    final secili = _fideAlt == deger;
    return GestureDetector(
      onTap: () => setState(() { _fideAlt = deger; _ekimTarihi = ''; _secilenBoy = null; }),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: secili ? AppColors.primary.withOpacity(0.08) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: secili ? AppColors.primary : AppColors.cardBorder, width: secili ? 2 : 1),
        ),
        child: Row(children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(baslik, style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.bold, color: secili ? AppColors.primary : AppColors.textPrimary)),
            Text(aciklama, style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textSecondary)),
          ])),
        ]),
      ),
    );
  }

  Widget _buildTarihSecici() {
    return GestureDetector(
      onTap: () async {
        final secilen = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime.now());
        if (secilen != null) setState(() => _ekimTarihi = secilen.toIso8601String().split('T')[0]);
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _ekimTarihi.isNotEmpty ? AppColors.primary : AppColors.cardBorder, width: _ekimTarihi.isNotEmpty ? 2 : 1),
        ),
        child: Row(children: [
          const Icon(Icons.calendar_today_outlined, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          Text(_ekimTarihi.isNotEmpty ? _ekimTarihi : 'Tarih seç...', style: GoogleFonts.dmSans(fontSize: 14, color: _ekimTarihi.isNotEmpty ? AppColors.textPrimary : AppColors.textSecondary)),
        ]),
      ),
    );
  }
}