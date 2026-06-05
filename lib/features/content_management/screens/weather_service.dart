import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class WeatherService {
  // Lấy API Key từ biến môi trường thay vì gắn cứng
  final String apiKey = dotenv.env['WEATHER_API_KEY'] ?? '';

  final String baseUrl = 'https://api.openweathermap.org/data/2.5/weather';

  Future<Map<String, dynamic>> fetchWeather(String city) async {
    if (apiKey.isEmpty) {
      throw Exception('Lỗi: Chưa cấu hình WEATHER_API_KEY trong file .env');
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl?q=$city&appid=$apiKey&units=metric&lang=vi'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Không lấy được dữ liệu thời tiết');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối: $e');
    }
  }
}