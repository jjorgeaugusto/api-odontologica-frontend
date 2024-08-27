import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AgendamentoService {
  final String baseUrl = 'http://localhost:8080/api';

  Future<List<dynamic>> fetchAgendamentos() async {
    final response = await http.get(Uri.parse('$baseUrl/agendamentos'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'});

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Erro ao carregar agendamentos');
    }
  }

  Future<void> deleteAgendamento(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/agendamentos/$id'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
    );

    if (response.statusCode != 204) {
      throw Exception('Erro ao excluir agendamento');
    }
  }

  Future<void> saveAgendamento(Map<String, dynamic> agendamentoData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/agendamentos'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(agendamentoData),
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao salvar agendamento');
    }
  }
}
