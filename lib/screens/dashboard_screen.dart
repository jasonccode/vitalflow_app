import 'package:flutter/material.dart';

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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '¡Hola, Jeison Camargo!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text('Resumen de tus hábitos de hoy', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 70,
                      height: 70,
                      child: CircularProgressIndicator(
                        value: 0.6,
                        strokeWidth: 8,
                        color: Colors.teal,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Calorías Quemadas', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('1,250 / 2,000 kcal', style: TextStyle(fontSize: 18, color: Colors.teal)),
                        Text('60% de la meta diaria'),
                      ],
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.water_drop, color: Colors.blue, size: 36),
                title: const Text('Consumo de Agua'),
                subtitle: const Text('5 de 8 vasos registrados (1.25 L)'),
                trailing: const Icon(Icons.arrow_forward_ios),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.directions_run, color: Colors.orange, size: 36),
                title: const Text('Tiempo Activo'),
                subtitle: const Text('45 minutos de cardio registrados'),
                trailing: const Icon(Icons.arrow_forward_ios),
              ),
            ),
          ],
        ),
      ),
    );
  }
}