import 'package:flutter/material.dart';

import '../widgets/profile_avatar.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VitalFlow - Dashboard'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Saludo con la foto de perfil tomada con la cámara
            Row(
              children: [
                ProfileAvatar(radius: 28),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // FittedBox reduce el texto solo si no cabe en una línea
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '¡Hola, Jeison Camargo!',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text('Resumen de tus hábitos de hoy', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    SizedBox(
                      width: 70,
                      height: 70,
                      child: CircularProgressIndicator(
                        value: 0.6,
                        strokeWidth: 8,
                        color: Colors.teal,
                      ),
                    ),
                    SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Calorías Quemadas', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('1,250 / 2,000 kcal', style: TextStyle(fontSize: 18, color: Colors.teal)),
                        Text('60% de la meta diaria'),
                      ],
                    )
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: Icon(Icons.water_drop, color: Colors.blue, size: 36),
                title: Text('Consumo de Agua'),
                subtitle: Text('5 de 8 vasos registrados (1.25 L)'),
                trailing: Icon(Icons.arrow_forward_ios),
              ),
            ),
            Card(
              child: ListTile(
                leading: Icon(Icons.directions_run, color: Colors.orange, size: 36),
                title: Text('Tiempo Activo'),
                subtitle: Text('45 minutos de cardio registrados'),
                trailing: Icon(Icons.arrow_forward_ios),
              ),
            ),
          ],
        ),
      ),
    );
  }
}