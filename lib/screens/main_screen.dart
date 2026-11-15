import 'package:flutter/material.dart';
import '../services/profile_service.dart';
import 'dashboard_screen.dart';
import 'hydration_screen.dart';
import 'activity_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const HydrationScreen(),
    const ActivityScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Recupera la foto de perfil guardada en SQLite
    ProfileService.instance.load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack mantiene vivas las 4 pantallas: al cambiar de pestaña
      // no se pierde lo que el usuario estaba haciendo en la anterior.
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        // Con 4 pestañas hay que fijar el tipo para que se vean las etiquetas
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        selectedItemColor: Colors.teal,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.water_drop), label: 'Hidratación'),
          BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: 'Actividad'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}
