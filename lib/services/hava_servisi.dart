import 'dart:convert';
import 'package:http/http.dart' as http;

class HavaServisi {
  static const Map<String, Map<String, double>> koordinatlar = {
    'Adana': {'lat': 37.00, 'lon': 35.32},
    'Ankara': {'lat': 39.93, 'lon': 32.85},
    'Antalya': {'lat': 36.90, 'lon': 30.70},
    'Bursa': {'lat': 40.18, 'lon': 29.06},
    'Diyarbakır': {'lat': 37.91, 'lon': 40.23},
    'Eskişehir': {'lat': 39.78, 'lon': 30.52},
    'Gaziantep': {'lat': 37.06, 'lon': 37.38},
    'İstanbul': {'lat': 41.01, 'lon': 28.97},
    'İzmir': {'lat': 38.42, 'lon': 27.14},
    'Kayseri': {'lat': 38.73, 'lon': 35.49},
    'Konya': {'lat': 37.87, 'lon': 32.49},
    'Mersin': {'lat': 36.80, 'lon': 34.63},
    'Samsun': {'lat': 41.29, 'lon': 36.33},
    'Trabzon': {'lat': 41.00, 'lon': 39.72},
    'Van': {'lat': 38.50, 'lon': 43.38},
  };

  static Future<Map<String, dynamic>?> havaGetir(String sehir) async {
    final koord = koordinatlar[sehir] ?? koordinatlar['Ankara']!;
    final lat = koord['lat']!;
    final lon = koord['lon']!;

    try {
      final url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast'
        '?latitude=$lat&longitude=$lon'
        '&current=temperature_2m,weathercode,windspeed_10m,relativehumidity_2m'
        '&daily=temperature_2m_max,temperature_2m_min,precipitation_sum,weathercode'
        '&timezone=Europe%2FIstanbul'
        '&forecast_days=3',
      );

      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (e) {
      print('Hava durumu hatası: $e');
    }
    return null;
  }

  static String havaDurumuMetin(int kod) {
    if (kod == 0) return 'Açık';
    if (kod <= 3) return 'Parçalı bulutlu';
    if (kod <= 48) return 'Bulutlu';
    if (kod <= 67) return 'Yağmurlu';
    if (kod <= 77) return 'Karlı';
    if (kod <= 82) return 'Sağanak';
    return 'Fırtınalı';
  }

  static String havaDurumuEmoji(int kod) {
    if (kod == 0) return '☀️';
    if (kod <= 3) return '⛅';
    if (kod <= 48) return '☁️';
    if (kod <= 67) return '🌧️';
    if (kod <= 77) return '🌨️';
    if (kod <= 82) return '🌦️';
    return '⛈️';
  }

  static String tavsiye(Map<String, dynamic> hava) {
    final yagmur = (hava['daily']?['precipitation_sum']?[0] ?? 0).toDouble();
    final max = (hava['daily']?['temperature_2m_max']?[0] ?? 20).toDouble();
    final min = (hava['daily']?['temperature_2m_min']?[0] ?? 10).toDouble();

    if (yagmur > 5) return '🌧️ Bugün yağmur var — sulamayı atla';
    if (max > 35) return '🌡️ Çok sıcak — sabah erken sula';
    if (min < 5) return '❄️ Soğuk hava — fideleri içeri al';
    return '✅ Bahçe bakımı için güzel bir gün!';
  }
}