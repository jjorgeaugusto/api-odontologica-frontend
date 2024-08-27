import 'dart:convert';
import 'package:apiodontologica/services/sala_service.dart';
import 'sala_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/agendamento_service.dart';
import '../services/paciente_service.dart';
import '../services/dentista_service.dart';
import 'package:http/http.dart' as http;

class AgendamentoPage extends StatefulWidget {
  @override
  _AgendamentoPageState createState() => _AgendamentoPageState();
}

class _AgendamentoPageState extends State<AgendamentoPage> {
  late Future<List<dynamic>> _agendamentosFetch;
  late Future<List<dynamic>> _pacientesFetch;
  late Future<List<dynamic>> _dentistasFetch;
  late Future<List<dynamic>> _salasFetch;

  final AgendamentoService _agendamentoService = AgendamentoService();
  final PacienteService _pacienteService = PacienteService();
  final DentistaService _dentistaService = DentistaService();
  final SalaService _salaService = SalaService();

  String _searchQuery = '';
  String? _selectedPaciente;
  String? _selectedDentista;
  String? _selectedSala;
  DateTime? _selectedDate;
  String? _selectedHour;

  final TextEditingController _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _agendamentosFetch = _agendamentoService.fetchAgendamentos();
    _pacientesFetch = _pacienteService.fetchPacientes();
    _dentistasFetch = _dentistaService.fetchDentistas();
    _salasFetch = _salaService.fetchSalas();
  }

  Future<void> _confirmDeleteAgendamento(int id) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar Exclusão'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Deseja mesmo excluir este agendamento?'),
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
              child: Text('Excluir'),
              onPressed: () async {
                await _agendamentoService.deleteAgendamento(id);
                Navigator.of(context).pop();
                setState(() {
                  _agendamentosFetch = _agendamentosFetch;
                });
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateAgendamento(
    int id,
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Por favor, selecione um paciente, um dentista, uma sala, uma data e uma hora',
          ),
        ),
      );
      return;
    }

    final String dateTime =
        '${date.toIso8601String().split('T').first}T$hour:00';

    final response = await http.put(
      Uri.parse('http://localhost:8080/api/agendamentos/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'id': id,
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
        'status': 'Confirmado',
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Agendamento atualizado com sucesso')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar agendamento')),
      );
    }
  }

  Future<void> _showEditAgendamentoDialog(dynamic agendamento) async {
    _selectedPaciente = agendamento['paciente']['id'].toString();
    _selectedDentista = agendamento['dentista']['id'].toString();
    _selectedSala = agendamento['sala']['id'].toString();
    _selectedDate = DateTime.parse(agendamento['dataHora']);
    _selectedHour = DateFormat('HH:mm').format(_selectedDate!);
    _dateController.text = _selectedDate!.toIso8601String().split('T').first;

    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Editar Agendamento'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                FutureBuilder<List<dynamic>>(
                  future: _pacientesFetch,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return CircularProgressIndicator();
                    return DropdownButtonFormField<String>(
                      value: _selectedPaciente,
                      hint: Text('Selecione o Paciente'),
                      items:
                          snapshot.data!.map<DropdownMenuItem<String>>((item) {
                        return DropdownMenuItem<String>(
                          value: item['id']
                              .toString(), // Capture o ID em vez do nome
                          child: Text(
                              item['nome']), // Mostre o nome para o usuário
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedPaciente = value;
                        });
                      },
                    );
                  },
                ),
                SizedBox(height: 16),
                FutureBuilder<List<dynamic>>(
                  future: _dentistasFetch,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return CircularProgressIndicator();
                    return DropdownButtonFormField<String>(
                      value: _selectedDentista,
                      hint: Text('Selecione o Dentista'),
                      items:
                          snapshot.data!.map<DropdownMenuItem<String>>((item) {
                        return DropdownMenuItem<String>(
                          value: item['id'].toString(),
                          child: Text(item['nome']),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedDentista = value;
                        });
                      },
                    );
                  },
                ),
                SizedBox(height: 16),
                FutureBuilder<List<dynamic>>(
                  future: _salasFetch,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return CircularProgressIndicator();
                    return DropdownButtonFormField<String>(
                      value: _selectedSala,
                      hint: Text('Selecione a Sala'),
                      items:
                          snapshot.data!.map<DropdownMenuItem<String>>((item) {
                        return DropdownMenuItem<String>(
                          value: item['id'].toString(),
                          child: Text(item['nome']),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedSala = value;
                        });
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
                      initialDate: _selectedDate!,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        _selectedDate = pickedDate;
                        _dateController.text =
                            _selectedDate!.toIso8601String().split('T').first;
                      });
                    }
                  },
                  controller: _dateController,
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedHour,
                  hint: Text('Selecione a Hora'),
                  items: List.generate(
                      48,
                      (index) => DropdownMenuItem(
                            value: (index ~/ 2).toString().padLeft(2, '0') +
                                ':' +
                                ((index % 2) * 30).toString().padLeft(2, '0'),
                            child: Text((index ~/ 2)
                                    .toString()
                                    .padLeft(2, '0') +
                                ':' +
                                ((index % 2) * 30).toString().padLeft(2, '0')),
                          )),
                  onChanged: (value) {
                    setState(() {
                      _selectedHour = value;
                    });
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
                await _updateAgendamento(
                  agendamento['id'],
                  _selectedPaciente,
                  _selectedDentista,
                  _selectedSala,
                  _selectedDate,
                  _selectedHour,
                );
                Navigator.of(context).pop();
                setState(() {
                  _agendamentosFetch = _agendamentosFetch;
                });
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showNewAgendamentoDialog() async {
    _selectedPaciente = null;
    _selectedDentista = null;
    _selectedSala = null;
    _selectedDate = null;
    _selectedHour = null;
    _dateController.clear();

    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Novo Agendamento'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                FutureBuilder<List<dynamic>>(
                  future: _pacienteService.fetchPacientes(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return CircularProgressIndicator();
                    return DropdownButtonFormField<String>(
                      value: _selectedPaciente,
                      hint: Text('Selecione o Paciente'),
                      items:
                          snapshot.data!.map<DropdownMenuItem<String>>((item) {
                        return DropdownMenuItem<String>(
                          value: item['id'].toString(),
                          child: Text(item['nome']),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedPaciente = value;
                        });
                      },
                    );
                  },
                ),
                SizedBox(height: 16),
                FutureBuilder<List<dynamic>>(
                  future: _dentistaService.fetchDentistas(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return CircularProgressIndicator();
                    return DropdownButtonFormField<String>(
                      value: _selectedDentista,
                      hint: Text('Selecione o Dentista'),
                      items:
                          snapshot.data!.map<DropdownMenuItem<String>>((item) {
                        return DropdownMenuItem<String>(
                          value: item['id'].toString(),
                          child: Text(item['nome']),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedDentista = value;
                        });
                      },
                    );
                  },
                ),
                SizedBox(height: 16),
                // Adicionar lógica de seleção de sala aqui
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
                        setState(() {
                          _selectedDate = pickedDate;
                          _dateController.text =
                              _selectedDate!.toIso8601String().split('T').first;
                        });
                      }
                      controller:
                      _dateController;
                    }),

                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedHour,
                  hint: Text('Selecione a Hora'),
                  items: List.generate(
                      48,
                      (index) => DropdownMenuItem(
                            value: (index ~/ 2).toString().padLeft(2, '0') +
                                ':' +
                                ((index % 2) * 30).toString().padLeft(2, '0'),
                            child: Text((index ~/ 2)
                                    .toString()
                                    .padLeft(2, '0') +
                                ':' +
                                ((index % 2) * 30).toString().padLeft(2, '0')),
                          )),
                  onChanged: (value) {
                    setState(() {
                      _selectedHour = value;
                    });
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
                Map<String, dynamic> agendamentoData = {
                  'paciente': {'id': int.parse(_selectedPaciente!)},
                  'dentista': {'id': int.parse(_selectedDentista!)},
                  'sala': {'id': int.parse(_selectedSala!)},
                  'dataHora':
                      '${_selectedDate!.toIso8601String().split('T').first}T$_selectedHour:00',
                  'status': 'a confirmar',
                };
                await _agendamentoService.saveAgendamento(agendamentoData);
                Navigator.of(context).pop();
                setState(() {
                  _agendamentoService.fetchAgendamentos();
                });
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Lista de Agendamentos')),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Volta para a página anterior
          },
        ),
        actions: <Widget>[
          Builder(
            builder: (context) => IconButton(
                icon: Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openDrawer(); // Abre o drawer ao clicar
                }),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blueAccent,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.add),
              title: Text('Novo Agendamento'),
              onTap: () {
                Navigator.pop(context);
                _showNewAgendamentoDialog();
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              width: 400,
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Pesquisar por nome de paciente ou dentista',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
            SizedBox(height: 5),
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: _agendamentoService.fetchAgendamentos(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Erro: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('Nenhum agendamento encontrado'));
                  } else {
                    var filteredAgendamentos = snapshot.data!;
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: MaterialStateColor.resolveWith(
                          (states) => Colors.blueAccent.withOpacity(0.2),
                        ),
                        columns: <DataColumn>[
                          DataColumn(
                            label: Text(
                              'Paciente',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueAccent),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Dentista',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueAccent),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Data e Hora',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueAccent),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Ações',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blueAccent,
                              ),
                            ),
                          ),
                        ],
                        rows: filteredAgendamentos.map<DataRow>((agendamento) {
                          return DataRow(
                            cells: <DataCell>[
                              DataCell(
                                  Text(agendamento['paciente']['nome'] ?? '')),
                              DataCell(
                                  Text(agendamento['dentista']['nome'] ?? '')),
                              DataCell(Text(DateFormat('dd/MM/yyyy - HH:mm')
                                  .format(DateTime.parse(
                                      agendamento['dataHora'] ?? '')))),
                              DataCell(
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit),
                                      onPressed: () {
                                        _showEditAgendamentoDialog(agendamento);
                                      },
                                      tooltip: 'Editar Agendamento',
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete),
                                      onPressed: () {
                                        _confirmDeleteAgendamento(
                                            agendamento['id']);
                                      },
                                      tooltip: 'Excluir Agendamento',
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
