import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:apiodontologica/screens/agendamento_teste_page.dart';

import 'screens/angeda_page.dart';
import 'screens/home_page.dart';
import 'screens/agendamento_page.dart';
import 'screens/paciente_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR', null);
  Intl.defaultLocale = 'pt_BR'; // Define o locale padrão como pt_BR
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: const Locale('pt', 'BR'), // Define a localização como pt_BR
      supportedLocales: const [Locale('pt', 'BR')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      title: 'API Odontológica',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
        '/agendamentos': (context) => AgendamentoPage(),
        '/agenda': (context) => AgendaPage(),
        '/pacientes': (context) => PacientePage(),
        '/agenda-teste': (context) => AgendaTestePage(), // Nova rota adicionada
      },
    );
  }
}
