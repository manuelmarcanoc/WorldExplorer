import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/country.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}

class CountriesService {
  static const String baseUrl = 'https://restcountries.com/v3.1';

  Future<Country> getCountryByName(String name) async {
    try {
      final url = Uri.parse('$baseUrl/name/$name?fullText=false');
      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw TimeoutException('Timeout'),
      );

      if (response.statusCode == 404) {
        throw ApiException('No se ha encontrado el país "$name". Intenta buscarlo en inglés.');
      } else if (response.statusCode != 200) {
        throw ApiException('Error del servidor. Inténtalo más tarde.');
      }

      final List<dynamic> jsonList = json.decode(response.body);
      if (jsonList.isEmpty) {
        throw ApiException('No se ha encontrado el país "$name".');
      }

      // agafem el primer resultat
      return Country.fromJson(jsonList.first as Map<String, dynamic>);
    } on TimeoutException {
      throw ApiException('La petición ha tardado demasiado. Inténtalo de nuevo.');
    } on SocketException {
      throw ApiException('Sin conexión a Internet. Revisa tu red.');
    } on FormatException {
      throw ApiException('Error del servidor. Respuesta malformada. Inténtalo más tarde.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Error inesperado: $e');
    }
  }
}
