import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AgendaPage extends StatefulWidget {
  @override
  _AgendaPageState createState() => _AgendaPageState();
}

class _AgendaPageState extends State<AgendaPage> {
  List<Appointment> _appointments = [];
  CalendarController _calendarController = CalendarController();
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _initializeDateFormatting();
  }

  Future<void> _initializeDateFormatting() async {
    await initializeDateFormatting('pt_BR', null);
    _fetchAgendamentos(); // Continue com a execução normal
  }

  Future<void> _updateAgendamentoStatus(int id, String action) async {
    final response = await http.put(
      Uri.parse('http://localhost:8080/api/agendamentos/$id/$action'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Agendamento $action com sucesso')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao $action agendamento')),
      );
    }
  }

  Future<void> _fetchAgendamentos() async {
    final response = await http.get(
      Uri.parse('http://localhost:8080/api/agendamentos'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      List<Appointment> appointments = data.map((agendamento) {
        Color appointmentColor;

        // Definindo a cor do agendamento com base no status
        switch (agendamento['status']) {
          case 'Confirmado':
            appointmentColor = Colors.green;
            break;
          case 'Cancelado':
            appointmentColor = Colors.red;
            break;
          default:
            appointmentColor = Colors.blue; // Status padrão "À confirmar"
        }

        return Appointment(
          startTime: DateTime.parse(agendamento['dataHora']),
          endTime: DateTime.parse(agendamento['dataHora'])
              .add(Duration(minutes: 30)),
          subject: agendamento['paciente']['nome'],
          color: appointmentColor,
          notes: jsonEncode(agendamento),
        );
      }).toList();

      setState(() {
        _appointments = appointments;
      });
    } else {
      throw Exception('Erro ao carregar agendamentos');
    }
  }

  void _showAgendamentoDetails(BuildContext context, dynamic agendamento) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Detalhes do Agendamento'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Paciente: ${agendamento['paciente']['nome']}'),
                Text('Dentista: ${agendamento['dentista']['nome']}'),
                Text('Sala: ${agendamento['sala']['nome']}'),
                Text(
                  'Data: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(agendamento['dataHora']))}',
                ),
                Text(
                  'Hora: ${DateFormat('HH:mm').format(DateTime.parse(agendamento['dataHora']))}',
                ),
                Text('Status: ${agendamento['status']}'),
              ],
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text('Confirmar'),
              onPressed: () async {
                await _updateAgendamentoStatus(agendamento['id'], "confirmar");
                Navigator.of(context).pop();
                setState(() {
                  _fetchAgendamentos();
                });
              },
            ),
            ElevatedButton(
              child: Text('Cancelar'),
              onPressed: () async {
                await _updateAgendamentoStatus(agendamento['id'], "cancelar");
                Navigator.of(context).pop();
                setState(() {
                  _fetchAgendamentos();
                });
              },
            ),
            ElevatedButton(
              child: Text('Fechar'),
              onPressed: () {
                Navigator.of(context).pop();
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
        title: Center(child: Text('Calendário')),
        backgroundColor: const Color.fromARGB(255, 76, 96, 131),
        centerTitle: true,
        titleTextStyle:
            TextStyle(color: Color.fromRGBO(255, 255, 255, 1), fontSize: 31),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Volta para a página anterior
          },
        ),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_left),
                onPressed: () {
                  setState(() {
                    _calendarController.backward!();
                  });
                },
              ),
              IconButton(
                icon: Icon(Icons.arrow_right),
                onPressed: () {
                  setState(() {
                    _calendarController.forward!();
                  });
                },
              ),
            ],
          ),
          Expanded(
            child: SfCalendar(
              view: CalendarView.week,
              controller: _calendarController,
              dataSource: _getCalendarDataSource(),
              timeSlotViewSettings: const TimeSlotViewSettings(
                timeIntervalHeight: 60,
                timeFormat: 'HH:mm', // Formato de 24 horas
                dateFormat: 'd MMM', // Formato do dia e mês em português
                dayFormat: 'EEE', // Formato do dia da semana em português
              ),
              onTap: (CalendarTapDetails details) {
                if (details.targetElement == CalendarElement.appointment) {
                  final Appointment appointment = details.appointments!.first;
                  final agendamento = jsonDecode(appointment.notes!);
                  _showAgendamentoDetails(context, agendamento);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  AppointmentDataSource _getCalendarDataSource() {
    return AppointmentDataSource(_appointments);
  }
}

class AppointmentDataSource extends CalendarDataSource {
  AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }
}
