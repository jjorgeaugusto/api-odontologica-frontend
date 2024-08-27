import 'dart:convert';
import 'package:http/http.dart' as http;

class SalaService {
  Future<List<dynamic>> fetchSalas() async {
    final response = await http.get(
      Uri.parse('http://localhost:8080/api/salas'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Erro ao carregar salas');
    }
  }
}
