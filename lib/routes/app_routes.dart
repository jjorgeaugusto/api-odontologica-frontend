import 'package:apiodontologica/screens/angeda_page.dart';
import 'package:flutter/material.dart';
import '../screens/agendamento_page.dart';
import '../screens/home_page.dart';
import '../screens/paciente_page.dart';

class AppRoutes {
  static const String home = '/';
  static const String agendamentos = '/agendamentos';
  static const String agenda = '/agenda';
  static const String pacientes = '/pacientes';

  static final Map<String, WidgetBuilder> routes = {
    home: (context) => HomePage(),
    agendamentos: (context) => AgendamentoPage(),
    agenda: (context) => AgendaPage(),
    pacientes: (context) => PacientePage(),
  };
}
