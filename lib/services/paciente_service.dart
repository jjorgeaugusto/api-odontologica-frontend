import 'package:http/http.dart' as http;
import 'dart:convert';

class PacienteService {
  final String baseUrl = 'http://localhost:8080/api';

  Future<List<dynamic>> fetchPacientes() async {
    final response = await http.get(Uri.parse('$baseUrl/pacientes'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'});

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Erro ao carregar pacientes');
    }
  }
}
