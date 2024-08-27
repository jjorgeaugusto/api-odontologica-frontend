import 'package:http/http.dart' as http;
import 'dart:convert';

class DentistaService {
  final String baseUrl = 'http://localhost:8080/api';

  Future<List<dynamic>> fetchDentistas() async {
    final response = await http.get(Uri.parse('$baseUrl/dentistas'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'});

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Erro ao carregar dentistas');
    }
  }
}
