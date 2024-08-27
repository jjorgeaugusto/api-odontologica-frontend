import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class AgendamentoPage extends StatefulWidget {
  @override
  _AgendamentoPageState createState() => _AgendamentoPageState();
}

class _AgendamentoPageState extends State<AgendamentoPage> {
  late Future<List<dynamic>> _agendamentos;
  late Future<List<dynamic>> _pacientes;
  late Future<List<dynamic>> _dentistas;
  String _searchQuery = '';
  String? _selectedPaciente;
  String? _selectedDentista;
  String? _selectedSala;
  DateTime? _selectedDate;
  String? _selectedHour;

  final TextEditingController _dateController =
      TextEditingController(); // Controlador de texto para o campo de data

  @override
  void initState() {
    super.initState();
    _agendamentos = fetchAgendamentos();
    _pacientes = fetchPacientes();
    _dentistas = fetchDentistas();
  }

  String _formatDate(String dateTime) {
    DateTime parsedDate = DateTime.parse(dateTime);
    return DateFormat('dd/MM/yyyy - HH:mm').format(parsedDate);
  }

  Future<List<dynamic>> fetchAgendamentos() async {
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

  Future<List<dynamic>> fetchPacientes() async {
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

  Future<List<dynamic>> fetchDentistas() async {
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
                await _deleteAgendamento(id);
                Navigator.of(context).pop();
                setState(() {
                  _agendamentos = fetchAgendamentos();
                });
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAgendamento(int id) async {
    final response = await http.delete(
      Uri.parse('http://localhost:8080/api/agendamentos/$id'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
    );

    if (response.statusCode == 204) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Agendamento excluído com sucesso')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao excluir agendamento')),
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
                  future: _pacientes,
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
                  future: _dentistas,
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
                  future: _fetchSalas(),
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
                  _agendamentos = fetchAgendamentos();
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

  Future<void> _showNewAgendamentoDialog() async {
    _selectedPaciente = null;
    _selectedDentista = null;
    _selectedSala = null;
    _selectedDate = null;
    _selectedHour = null;
    _dateController.clear;

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
                  future: _pacientes,
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
                  future: _dentistas,
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
                  future: _fetchSalas(), // Função que busca as salas
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
                  },
                  controller:
                      _dateController, // Use o controlador de texto aqui
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
                await _saveAgendamento(
                  _selectedPaciente,
                  _selectedDentista,
                  _selectedSala,
                  _selectedDate,
                  _selectedHour,
                );
                Navigator.of(context).pop();
                setState(() {
                  _agendamentos = fetchAgendamentos();
                });
              },
            ),
          ],
        );
      },
    );
  }

  Future<List<dynamic>> _fetchSalas() async {
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

    final response = await http.post(
      Uri.parse('http://localhost:8080/api/agendamentos'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'paciente': {
          'id': int.parse(paciente), // O ID já está sendo passado
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

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Agendamento criado com sucesso')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao criar agendamento')),
      );
    }
  }

  List<dynamic> _filterAgendamentos(List<dynamic> agendamentos) {
    if (_searchQuery.isEmpty) {
      return agendamentos;
    } else {
      return agendamentos.where((agendamento) {
        final pacienteNomeLower =
            (agendamento['paciente']?['nome'] ?? '').toLowerCase();
        final dentistaNomeLower =
            (agendamento['dentista']?['nome'] ?? '').toLowerCase();
        final SalaNomeLower =
            (agendamento['sala']?['nome'] ?? '').toLowerCase();
        final queryLower = _searchQuery.toLowerCase();
        return pacienteNomeLower.contains(queryLower) ||
            dentistaNomeLower.contains(queryLower);
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Lista de Agendamentos')),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        leading: Container(
          width: 100,
          child: Row(
            mainAxisSize:
                MainAxisSize.min, // Ajusta o tamanho da Row ao conteúdo
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back, size: 20),
                onPressed: () {
                  Navigator.pop(context); // Volta para a página anterxior
                },
              ),
            ],
          ),
        ),
        actions: <Widget>[
          Builder(
            builder: (context) => IconButton(
                icon: Icon(Icons.menu, size: 20),
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
              width: 400, // Ajuste conforme necessário para o tamanho desejado
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
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: _agendamentos,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Erro: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('Nenhum agendamento encontrado'));
                  } else {
                    var filteredAgendamentos =
                        _filterAgendamentos(snapshot.data!);
                    return Center(
                      child: SingleChildScrollView(
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
                              label: Row(
                                children: [
                                  Text(
                                    'Data e Hora',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blueAccent),
                                  ),
                                ],
                              ),
                            ),
                            DataColumn(
                              label: Row(
                                children: [
                                  Text(
                                    'Ações',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blueAccent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          rows:
                              filteredAgendamentos.map<DataRow>((agendamento) {
                            return DataRow(
                              cells: <DataCell>[
                                DataCell(Text(
                                    agendamento['paciente']?['nome'] ?? '')),
                                DataCell(Text(
                                    agendamento['dentista']?['nome'] ?? '')),
                                DataCell(Text(_formatDate(
                                    agendamento['dataHora'] ?? ''))),
                                DataCell(
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.edit),
                                        onPressed: () {
                                          _showEditAgendamentoDialog(
                                              agendamento);
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
                      ),
                    );
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: AgendamentoPage(),
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
  ));
}
