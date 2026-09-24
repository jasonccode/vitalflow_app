import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int vasosAgua = 5; // Estado inicial del contador

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resumen Diario'),
        backgroundColor: Colors.green,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text('Hola, Jeison Camargo', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const Text('Hoy, 15 de septiembre', style: TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 20),
          
          // Tarjeta de Calorías
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const Text('Calorías Quemadas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 20),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 120, height: 120,
                        child: CircularProgressIndicator(
                          value: 0.5, 
                          strokeWidth: 12, 
                          backgroundColor: Colors.grey[300], 
                          color: Colors.orange
                        ),
                      ),
                      const Text('1250\n/ 2500 kcal', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Tarjeta de Hidratación interactiva
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.water_drop, color: Colors.blue, size: 40),
                      SizedBox(width: 10),
                      Text('Hidratación', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: Colors.red), 
                        onPressed: () { 
                          setState(() { if(vasosAgua > 0) vasosAgua--; }); 
                        }
                      ),
                      Text('$vasosAgua / 8', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline, color: Colors.green), 
                        onPressed: () { 
                          setState(() { vasosAgua++; }); 
                        }
                      ),
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
      
      // Menú inferior
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: 'Actividad'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}