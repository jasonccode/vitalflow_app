import 'package:flutter/material.dart';

class HydrationScreen extends StatefulWidget {
  const HydrationScreen({super.key});

  @override
  State<HydrationScreen> createState() => _HydrationScreenState();
}

class _HydrationScreenState extends State<HydrationScreen> {
  int _glasses = 5; // Estado inicial simulado
  final int _dailyGoal = 8; // Meta diaria

  void _addGlass() {
    if (_glasses < _dailyGoal) {
      setState(() {
        _glasses++;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Felicidades! Has alcanzado tu meta diaria.'),
        ),
      );
    }
  }

  void _removeGlass() {
    if (_glasses > 0) {
      setState(() {
        _glasses--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Control de Hidratación'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.water_drop, size: 100, color: Colors.blue),
              const SizedBox(height: 20),
              Text(
                '$_glasses / $_dailyGoal Vasos',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Has bebido ${(_glasses * 250)} ml de agua hoy.',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 40),
              // Barra de progreso interactiva
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: _glasses / _dailyGoal,
                  minHeight: 20,
                  backgroundColor: Colors.blue.withValues(alpha: 0.2),
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FloatingActionButton(
                    heroTag: 'btn_remove',
                    onPressed: _removeGlass,
                    backgroundColor: Colors.redAccent,
                    child: const Icon(Icons.remove, color: Colors.white),
                  ),
                  FloatingActionButton(
                    heroTag: 'btn_add',
                    onPressed: _addGlass,
                    backgroundColor: Colors.teal,
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
