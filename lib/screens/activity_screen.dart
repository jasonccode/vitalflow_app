import 'package:flutter/material.dart';

import '../helpers/database_helper.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  final _titleController = TextEditingController();
  final _durationController = TextEditingController();
  String? _selectedActivity;

  // Rutinas leídas de SQLite
  List<Map<String, dynamic>> _routines = [];
  // Id de la rutina que se está editando (null = se está creando una nueva)
  int? _editingId;

  final List<String> _activities = [
    'Correr',
    'Caminar',
    'Ciclismo',
    'Natación',
    'Gimnasio / Pesas',
    'Yoga'
  ];

  @override
  void initState() {
    super.initState();
    _loadRoutines();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _titleController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  void _showMessage(String message, {Color backgroundColor = Colors.teal}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: backgroundColor),
    );
  }

  // READ: Consultar las rutinas guardadas y mostrarlas en la lista
  Future<void> _loadRoutines() async {
    try {
      final routines = await DatabaseHelper.instance.getRoutines();
      if (!mounted) return;
      setState(() {
        _routines = routines;
      });
    } catch (e) {
      _showMessage('No se pudieron cargar las rutinas: $e',
          backgroundColor: Colors.red);
    }
  }

  // CREATE / UPDATE: Guardar el formulario en SQLite
  Future<void> _saveActivity() async {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleController.text.trim();
    final duration = int.parse(_durationController.text.trim());
    final row = <String, dynamic>{
      'title': title,
      'duration': duration,
      'category': _selectedActivity,
    };

    final editingId = _editingId;
    try {
      if (editingId == null) {
        await DatabaseHelper.instance.insertRoutine(row);
      } else {
        row['id'] = editingId;
        await DatabaseHelper.instance.updateRoutine(row);
      }
    } catch (e) {
      _showMessage('No se pudo guardar la rutina: $e',
          backgroundColor: Colors.red);
      return;
    }
    if (!mounted) return;

    // Limpiar el formulario tras guardar y refrescar la lista
    _clearForm();
    await _loadRoutines();
    _showMessage(
      editingId == null
          ? '$title por $duration min registrado con éxito.'
          : '$title actualizado con éxito.',
    );
  }

  // Cargar una rutina en el formulario para editarla
  void _startEdit(Map<String, dynamic> routine) {
    setState(() {
      _editingId = routine['id'] as int;
      _titleController.text = routine['title'] as String;
      _durationController.text = '${routine['duration']}';
      _selectedActivity = routine['category'] as String;
    });
    // Subir hasta el formulario para que el usuario vea los datos cargados
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  // DELETE: Eliminar una rutina después de confirmar
  Future<void> _confirmDelete(Map<String, dynamic> routine) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar rutina'),
        content: Text('¿Seguro que deseas eliminar "${routine['title']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            style: TextButton.styleFrom(foregroundColor: Colors.teal),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final id = routine['id'] as int;
    try {
      await DatabaseHelper.instance.deleteRoutine(id);
    } catch (e) {
      _showMessage('No se pudo eliminar la rutina: $e',
          backgroundColor: Colors.red);
      return;
    }
    if (!mounted) return;

    // Si se eliminó la rutina que estaba en edición, se limpia el formulario
    if (_editingId == id) _clearForm();
    await _loadRoutines();
    _showMessage('"${routine['title']}" eliminado.');
  }

  void _clearForm() {
    _formKey.currentState!.reset();
    _titleController.clear();
    _durationController.clear();
    setState(() {
      _selectedActivity = null;
      _editingId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = _editingId != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de Actividad'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEditing ? 'Editar rutina' : 'Registra tu entrenamiento',
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal),
              ),
              const SizedBox(height: 24),
              // Campo de texto para el nombre de la rutina
              TextFormField(
                controller: _titleController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la rutina',
                  prefixIcon: Icon(Icons.edit_note),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor ingrese el nombre de la rutina';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
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
                validator: (value) =>
                    value == null ? 'Por favor seleccione una actividad' : null,
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
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor ingrese la duración';
                  }
                  final minutes = int.tryParse(value.trim());
                  if (minutes == null) {
                    return 'Ingrese un número válido';
                  }
                  if (minutes <= 0) {
                    return 'La duración debe ser mayor a 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              // Botón de guardado (crea o actualiza según el modo)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveActivity,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    isEditing ? 'Actualizar Actividad' : 'Guardar Actividad',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
              if (isEditing)
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: _clearForm,
                    style: TextButton.styleFrom(foregroundColor: Colors.teal),
                    child: const Text('Cancelar edición'),
                  ),
                ),
              const SizedBox(height: 32),
              // Lista de rutinas guardadas en SQLite
              Text(
                'Mis rutinas guardadas (${_routines.length})',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (_routines.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    'Aún no hay rutinas. Registra la primera con el formulario.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              for (final routine in _routines)
                Card(
                  child: ListTile(
                    leading:
                        const Icon(Icons.fitness_center, color: Colors.teal),
                    title: Text(
                      routine['title'] as String,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                        '${routine['category']} · ${routine['duration']} min'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          tooltip: 'Editar',
                          onPressed: () => _startEdit(routine),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          tooltip: 'Eliminar',
                          onPressed: () => _confirmDelete(routine),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
