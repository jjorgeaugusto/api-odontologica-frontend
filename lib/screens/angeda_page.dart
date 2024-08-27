import 'package:flutter/material.dart';
import '../services/agendamento_service.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class AgendaPage extends StatefulWidget {
  @override
  _AgendaPageState createState() => _AgendaPageState();
}

class _AgendaPageState extends State<AgendaPage> {
  final _agendamentoService = AgendamentoService();
  CalendarController _calendarController = CalendarController();
  List<Appointment> _appointments = [];

  @override
  void initState() {
    super.initState();
    _fetchAgendamentos();
  }

  Future<void> _fetchAgendamentos() async {
    var agendamentos = await _agendamentoService.fetchAgendamentos();
    List<Appointment> appointments =
        agendamentos.map<Appointment>((agendamento) {
      Color appointmentColor;
      switch (agendamento['status']) {
        case 'Confirmado':
          appointmentColor = Colors.green;
          break;
        case 'Cancelado':
          appointmentColor = Colors.red;
          break;
        default:
          appointmentColor = Colors.blue;
      }
      return Appointment(
        startTime: DateTime.parse(agendamento['dataHora']),
        endTime:
            DateTime.parse(agendamento['dataHora']).add(Duration(minutes: 30)),
        subject: agendamento['paciente']['nome'],
        color: appointmentColor,
        notes: agendamento['id'].toString(),
      );
    }).toList();

    setState(() {
      _appointments = appointments;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agenda'),
      ),
      body: SfCalendar(
        view: CalendarView.week,
        controller: _calendarController,
        dataSource: AppointmentDataSource(_appointments),
      ),
    );
  }
}

class AppointmentDataSource extends CalendarDataSource {
  AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }
}
