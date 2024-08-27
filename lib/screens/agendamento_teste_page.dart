import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '/services/agendamento_service.dart';
import '/services/dentista_service.dart';

class AgendaTestePage extends StatefulWidget {
  @override
  _AgendaTestePageState createState() => _AgendaTestePageState();
}

class _AgendaTestePageState extends State<AgendaTestePage> {
  late Future<List<dynamic>> _dentistas;
  late Future<List<dynamic>> _agendamentos;

  @override
  void initState() {
    super.initState();
    _dentistas = DentistaService().fetchDentistas();
    _agendamentos = AgendamentoService().fetchAgendamentos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agenda de Teste'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: Future.wait([_dentistas, _agendamentos]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar dados'));
          } else {
            List<dynamic> dentistas = snapshot.data![0];
            List<dynamic> agendamentos = snapshot.data![1];
            return _buildAgenda(dentistas, agendamentos);
          }
        },
      ),
    );
  }

  Widget _buildAgenda(List<dynamic> dentistas, List<dynamic> agendamentos) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_left),
                onPressed: () {
                  // Função para mover para a semana anterior
                },
              ),
              Text(
                '02 de Fevereiro de 2021',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: Icon(Icons.arrow_right),
                onPressed: () {
                  // Função para mover para a próxima semana
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: dentistas.length,
            itemBuilder: (context, index) {
              return _buildDentistaColumn(dentistas[index], agendamentos);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDentistaColumn(dynamic dentista, List<dynamic> agendamentos) {
    return Container(
      width: 150,
      margin: EdgeInsets.all(8.0),
      child: Column(
        children: [
          CircleAvatar(
            backgroundImage:
                NetworkImage(dentista['imagemUrl']), // Placeholder de imagem
            radius: 30,
          ),
          SizedBox(height: 8),
          Text(
            dentista['nome'],
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          Text(
            dentista['especialidade'],
            style: TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: agendamentos.length,
              itemBuilder: (context, index) {
                if (agendamentos[index]['dentista']['id'] == dentista['id']) {
                  return _buildAgendamentoTile(agendamentos[index]);
                }
                return Container(); // Retorna um container vazio se não for o dentista certo
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgendamentoTile(dynamic agendamento) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4.0),
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: agendamento['status'] == 'Confirmado'
            ? Colors.greenAccent
            : agendamento['status'] == 'Cancelado'
                ? Colors.redAccent
                : Colors.blueAccent,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            agendamento['paciente']['nome'],
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          Text(
            '${agendamento['dataHora']}',
            style: TextStyle(fontSize: 12, color: Colors.white),
          ),
          Text(
            'R\$ ${agendamento['valor']}',
            style: TextStyle(fontSize: 12, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
