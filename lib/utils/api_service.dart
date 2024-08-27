import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static Future<List<dynamic>> fetchAgendamentos() async {
    final response = await http.get(
      Uri.parse('http://localhost:8080/api/agendamentos'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Erro ao carregar agendamentos');
    }
  }

  static Future<List<dynamic>> fetchPacientes() async {
    final response = await http.get(
      Uri.parse('http://localhost:8080/api/pacientes'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Erro ao carregar pacientes');
    }
  }

  static Future<List<dynamic>> fetchDentistas() async {
    final response = await http.get(
      Uri.parse('http://localhost:8080/api/dentistas'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Erro ao carregar dentistas');
    }
  }

  static Future<void> deleteAgendamento(int id) async {
    final response = await http.delete(
      Uri.parse('http://localhost:8080/api/agendamentos/$id'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
    );

    if (response.statusCode == 204) {
      // Sucesso ao excluir
    } else {
      throw Exception('Erro ao excluir agendamento');
    }
  }
}
