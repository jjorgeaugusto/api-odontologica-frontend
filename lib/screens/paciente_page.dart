import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PacientePage extends StatefulWidget {
  @override
  _PacientePageState createState() => _PacientePageState();
}

class _PacientePageState extends State<PacientePage> {
  late Future<List<dynamic>> _pacientes;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _pacientes = fetchPacientes();
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

  Future<void> _updatePaciente(
      int id, String nome, String telefone, String email) async {
    final response = await http.put(
      Uri.parse('http://localhost:8080/api/pacientes/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nome': nome,
        'telefone': telefone,
        'email': email,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Paciente atualizado com sucesso')),
      );
      setState(() {
        _pacientes = fetchPacientes(); // Recarrega a lista de pacientes
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar paciente')),
      );
    }
  }

  Future<void> _showEditPacienteDialog(Map<String, dynamic> paciente) async {
    String nome = paciente['nome'];
    String telefone = paciente['telefone'];
    String email = paciente['email'];

    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Editar Paciente'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  decoration: InputDecoration(labelText: 'Nome'),
                  controller: TextEditingController(text: nome),
                  onChanged: (value) {
                    nome = value;
                  },
                ),
                SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(labelText: 'Telefone'),
                  controller: TextEditingController(text: telefone),
                  onChanged: (value) {
                    telefone = value;
                  },
                ),
                SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(labelText: 'Email'),
                  controller: TextEditingController(text: email),
                  onChanged: (value) {
                    email = value;
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
                await _updatePaciente(paciente['id'], nome, telefone, email);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _savePaciente(String nome, String telefone, String email) async {
    final response = await http.post(
      Uri.parse('http://localhost:8080/api/pacientes'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nome': nome,
        'telefone': telefone,
        'email': email,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Paciente criado com sucesso')),
      );
      setState(() {
        _pacientes = fetchPacientes(); // Recarrega a lista de pacientes
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao criar paciente')),
      );
    }
  }

  Future<void> _showNewPacienteDialog() async {
    String nome = '';
    String telefone = '';
    String email = '';

    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Novo Paciente'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  decoration: InputDecoration(labelText: 'Nome'),
                  onChanged: (value) {
                    nome = value;
                  },
                ),
                SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(labelText: 'Telefone'),
                  onChanged: (value) {
                    telefone = value;
                  },
                ),
                SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(labelText: 'Email'),
                  onChanged: (value) {
                    email = value;
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
                await _savePaciente(nome, telefone, email);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  List<dynamic> _filterPacientes(List<dynamic> pacientes) {
    if (_searchQuery.isEmpty) {
      return pacientes;
    } else {
      return pacientes.where((paciente) {
        final nomeLower = paciente['nome'].toLowerCase();
        final telefoneLower = paciente['telefone'].toLowerCase();
        final queryLower = _searchQuery.toLowerCase();
        return nomeLower.contains(queryLower) ||
            telefoneLower.contains(queryLower);
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Lista de Pacientes')),
        backgroundColor: const Color.fromARGB(255, 143, 144, 145),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Volta para a página anterior
          },
        ),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openEndDrawer(); // Abre o Drawer
              },
            ),
          ),
        ],
      ),
      endDrawer: Drawer(
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
              title: Text('Novo Paciente'),
              onTap: () {
                Navigator.pop(context); // Fecha o Drawer
                _showNewPacienteDialog(); // Abre o diálogo para adicionar um novo paciente
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 500,
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Pesquisar por nome ou telefone',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: FutureBuilder<List<dynamic>>(
                  future: _pacientes,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Erro: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text('Nenhum paciente encontrado'));
                    } else {
                      var filteredPacientes = _filterPacientes(snapshot.data!);
                      return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            headingRowColor: MaterialStateColor.resolveWith(
                              (states) => Colors.blueAccent.withOpacity(0.2),
                            ),
                            columns: const <DataColumn>[
                              DataColumn(
                                label: Text(
                                  'Nome',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blueAccent),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Telefone',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blueAccent),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Email',
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
                                      color: Colors.blueAccent),
                                ),
                              ),
                            ],
                            rows: filteredPacientes.map<DataRow>((paciente) {
                              return DataRow(
                                cells: <DataCell>[
                                  DataCell(Text(paciente['nome'])),
                                  DataCell(Text(paciente['telefone'])),
                                  DataCell(Text(paciente['email'])),
                                  DataCell(
                                    IconButton(
                                      icon: Icon(Icons.edit),
                                      onPressed: () {
                                        _showEditPacienteDialog(paciente);
                                      },
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ));
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: PacientePage(),
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
  ));
}
