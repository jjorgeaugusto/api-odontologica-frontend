import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> showNewAgendamentoDialog(
  BuildContext context,
  Future<List<dynamic>> pacientes,
  Future<List<dynamic>> dentistas,
  Future<List<dynamic>> salas,
  Function fetchAgendamentos,
) async {
  String? selectedPaciente;
  String? selectedDentista;
  String? selectedSala;
  DateTime? selectedDate;
  String? selectedHour;
  final TextEditingController dateController = TextEditingController();

  await showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Novo Agendamento'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              FutureBuilder<List<dynamic>>(
                future: pacientes,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return CircularProgressIndicator();
                  return DropdownButtonFormField<String>(
                    value: selectedPaciente,
                    hint: Text('Selecione o Paciente'),
                    items: snapshot.data!.map<DropdownMenuItem<String>>((item) {
                      return DropdownMenuItem<String>(
                        value: item['id'].toString(),
                        child: Text(item['nome']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      selectedPaciente = value;
                    },
                  );
                },
              ),
              SizedBox(height: 16),
              FutureBuilder<List<dynamic>>(
                future: dentistas,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return CircularProgressIndicator();
                  return DropdownButtonFormField<String>(
                    value: selectedDentista,
                    hint: Text('Selecione o Dentista'),
                    items: snapshot.data!.map<DropdownMenuItem<String>>((item) {
                      return DropdownMenuItem<String>(
                        value: item['id'].toString(),
                        child: Text(item['nome']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      selectedDentista = value;
                    },
                  );
                },
              ),
              SizedBox(height: 16),
              FutureBuilder<List<dynamic>>(
                future: salas,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return CircularProgressIndicator();
                  return DropdownButtonFormField<String>(
                    value: selectedSala,
                    hint: Text('Selecione a Sala'),
                    items: snapshot.data!.map<DropdownMenuItem<String>>((item) {
                      return DropdownMenuItem<String>(
                        value: item['id'].toString(),
                        child: Text(item['nome']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      selectedSala = value;
                    },
                  );
                },
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(labelText: 'Data'),
                readOnly: true,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null) {
                    selectedDate = pickedDate;
                    dateController.text =
                        selectedDate!.toIso8601String().split('T').first;
                  }
                },
                controller: dateController,
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedHour,
                hint: Text('Selecione a Hora'),
                items: List.generate(48, (index) {
                  return DropdownMenuItem(
                    value: (index ~/ 2).toString().padLeft(2, '0') +
                        ':' +
                        ((index % 2) * 30).toString().padLeft(2, '0'),
                    child: Text(
                      (index ~/ 2).toString().padLeft(2, '0') +
                          ':' +
                          ((index % 2) * 30).toString().padLeft(2, '0'),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  selectedHour = value;
                },
              ),
            ],
          ),
        ),
        actions: <Widget>[
          ElevatedButton(
            child: Text('Cancelar'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          ElevatedButton(
            child: Text('Salvar'),
            onPressed: () async {
              await _saveAgendamento(
                selectedPaciente,
                selectedDentista,
                selectedSala,
                selectedDate,
                selectedHour,
              );
              Navigator.of(context).pop();
              fetchAgendamentos();
            },
          ),
        ],
      );
    },
  );
}

Future<void> _saveAgendamento(
  String? paciente,
  String? dentista,
  String? sala,
  DateTime? date,
  String? hour,
) async {
  if (paciente == null ||
      dentista == null ||
      sala == null ||
      date == null ||
      hour == null) {
    return;
  }

  final String dateTime = '${date.toIso8601String().split('T').first}T$hour:00';

  final response = await http.post(
    Uri.parse('http://localhost:8080/api/agendamentos'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'paciente': {
        'id': int.parse(paciente),
      },
      'dentista': {
        'id': int.parse(dentista),
      },
      'sala': {
        'id': int.parse(sala),
      },
      'dataHora': dateTime,
      'status': 'a confirmar',
    }),
  );

  if (response.statusCode != 200) {
    throw Exception('Erro ao criar agendamento');
  }
}
