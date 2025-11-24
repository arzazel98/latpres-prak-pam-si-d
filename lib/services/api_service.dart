// services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nitendo/models/ambio_model.dart';

class ApiService {
  static const String baseUrl = 'https://www.amiiboapi.com/api/amiibo';

  Future<List<Amiibo>> getAllAmiibo() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        // API Amiibo membungkus data dalam key "amiibo"
        final List<dynamic> data = jsonResponse['amiibo'];

        return data.map((json) => Amiibo.fromJson(json)).toList();
      } else {
        throw Exception('Gagal load data API');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
