import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/weather.dart';
import 'countries_service.dart'; // Per reaprofitar l'ApiException

class WeatherService {
  static const String baseUrl = 'https://api.open-meteo.com/v1/forecast';

  Future<Weather> getWeather(double latitude, double longitude) async {
    try {
      final url = Uri.parse(
        '$baseUrl?latitude=$latitude&longitude=$longitude'
        '&current_weather=true'
        '&daily=temperature_2m_max,temperature_2m_min,weathercode'
        '&timezone=auto',
      );

      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw TimeoutException('Timeout'),
      );

      if (response.statusCode != 200) {
        throw ApiException('Error del servidor meteorológico. Inténtalo más tarde.');
      }

      final Map<String, dynamic> jsonData = json.decode(response.body);
      return Weather.fromJson(jsonData);
    } on TimeoutException {
      throw ApiException('La petición del clima ha tardado demasiado. Inténtalo de nuevo.');
    } on SocketException {
      throw ApiException('Sin conexión a Internet. Revisa tu red.');
    } on FormatException {
      throw ApiException('Error del servidor. Respuesta malformada. Inténtalo más tarde.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Error inesperado en el clima: $e');
    }
  }
}
