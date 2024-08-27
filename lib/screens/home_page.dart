import 'package:flutter/material.dart';

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
              elevation: 8,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Container(
                width: 580,
                height: 450,
                padding: const EdgeInsets.all(16.0),
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
                          '/agendamentos',
                        ),
                        SizedBox(width: 30),
                        _buildButton(
                          context,
                          'Pacientes',
                          Icons.people,
                          '/pacientes',
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
                          '/agenda',
                        ),
                        SizedBox(width: 20),
                        _buildButton(
                          context,
                          'Outro Serviço',
                          Icons.local_hospital,
                          '/agenda-teste', // Exemplo de outra página, pode ser alterado conforme necessário
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
      BuildContext context, String text, IconData icon, String route) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 40),
      label: Text(
        text,
        style: TextStyle(fontSize: 16),
      ),
      style: ElevatedButton.styleFrom(
        fixedSize: Size(200, 150),
        padding: EdgeInsets.all(20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onPressed: () {
        Navigator.pushNamed(context, route);
      },
    );
  }
}
