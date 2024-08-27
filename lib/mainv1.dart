import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/paciente_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/agendamento_pagev1.dart'; // Certifique-se de que o caminho esteja correto
import 'screens/agenda_pagev1.dart';
import 'package:intl/intl.dart';

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
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('API Odontológica'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Card(
              elevation: 8, // Sombra para o quadro
              color: Colors.white, // Cor de fundo do quadro
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(15), // Bordas arredondadas do quadro
              ),
              child: Container(
                width: 580, // Largura do Card
                height: 450, // Altura do Card
                padding:
                    const EdgeInsets.all(16.0), // Espaçamento interno do quadro
                child: Column(
                  children: [
                    Text(
                      'Menu Principal',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        _buildButton(
                          context,
                          'Agendamentos',
                          Icons.calendar_today,
                          AgendamentoPage(),
                        ),
                        SizedBox(width: 30),
                        _buildButton(
                          context,
                          'Pacientes',
                          Icons.people,
                          PacientePage(),
                        ),
                      ],
                    ),
                    SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        _buildButton(
                          context,
                          'Agenda',
                          Icons.calendar_month,
                          AgendaPage(), // Exemplo de uma nova página
                        ),
                        SizedBox(width: 20),
                        _buildButton(
                          context,
                          'Outro Serviço',
                          Icons.local_hospital,
                          PacientePage(), // Exemplo de outra nova página
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(
      BuildContext context, String text, IconData icon, Widget page) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 40), // Ícone grande
      label: Text(
        text,
        style: TextStyle(fontSize: 16), // Tamanho do texto
      ),
      style: ElevatedButton.styleFrom(
        fixedSize: Size(200, 150), // Tamanho fixo para todos os botões
        padding: EdgeInsets.all(20), // Padding ajustado
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // Bordas arredondadas
        ),
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
    );
  }
}
