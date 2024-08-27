import 'package:flutter/material.dart';
import '/services/sala_service.dart'; // Importe o serviço que criamos

class SalaPage extends StatefulWidget {
  @override
  _SalaPageState createState() => _SalaPageState();
}

class _SalaPageState extends State<SalaPage> {
  late Future<List<dynamic>> _salas;

  final SalaService _salaService = SalaService(); // Instancia o serviço

  @override
  void initState() {
    super.initState();
    _salas = _salaService.fetchSalas(); // Usa o método do serviço
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Salas'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _salas,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Nenhuma sala encontrada'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var sala = snapshot.data![index];
                return ListTile(
                  title: Text(sala['nome']),
                );
              },
            );
          }
        },
      ),
    );
  }
}
