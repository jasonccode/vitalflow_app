import 'package:flutter/material.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedActivity;
  final _durationController = TextEditingController();

  final List<String> _activities = [
    'Correr',
    'Caminar',
    'Ciclismo',
    'Natación',
    'Gimnasio / Pesas',
    'Yoga'
  ];

  void _saveActivity() {
    if (_formKey.currentState!.validate()) {
      // Mostrar confirmación visual (SnackBar)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$_selectedActivity por ${_durationController.text} min registrado con éxito.'),
          backgroundColor: Colors.teal,
        ),
      );
      // Limpiar el formulario tras guardar
      _formKey.currentState!.reset();
      setState(() {
        _selectedActivity = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de Actividad'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Registra tu entrenamiento',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal),
              ),
              const SizedBox(height: 24),
              // Selector desplegable para el tipo de ejercicio
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Tipo de Actividad',
                  prefixIcon: Icon(Icons.fitness_center),
                  border: OutlineInputBorder(),
                ),
                initialValue: _selectedActivity,
                items: _activities.map((String activity) {
                  return DropdownMenuItem<String>(
                    value: activity,
                    child: Text(activity),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedActivity = newValue;
                  });
                },
                validator: (value) => value == null ? 'Por favor seleccione una actividad' : null,
              ),
              const SizedBox(height: 16),
              // Campo numérico para la duración
              TextFormField(
                controller: _durationController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Duración (en minutos)',
                  prefixIcon: Icon(Icons.timer),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese la duración';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Ingrese un número válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              // Botón de guardado
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveActivity,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Guardar Actividad', style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}