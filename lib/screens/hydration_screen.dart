import 'package:flutter/material.dart';

import '../services/notification_service.dart';

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
      // Notificación local inmediata al completar la meta del día
      if (_glasses == _dailyGoal) {
        _notify(
          () => NotificationService.instance.showNow(
            id: NotificationService.goalId,
            title: '¡Meta de hidratación cumplida!',
            body: 'Completaste tus $_dailyGoal vasos de agua de hoy.',
          ),
          '¡Felicidades! Has alcanzado tu meta diaria.',
        );
      }
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

  // Ejecuta una acción de notificación y le informa el resultado al usuario
  Future<void> _notify(
    Future<bool> Function() action,
    String successMessage,
  ) async {
    String message;
    try {
      final shown = await action();
      message = shown
          ? successMessage
          : 'Activa el permiso de notificaciones para recibir avisos.';
    } catch (e) {
      message = 'No se pudo enviar la notificación: $e';
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Notificación programada: llega 10 segundos después
  void _remindInTenSeconds() {
    _notify(
      () => NotificationService.instance.scheduleIn(
        const Duration(seconds: 10),
        id: NotificationService.reminderId,
        title: 'Hora de hidratarte',
        body: 'Llevas $_glasses de $_dailyGoal vasos. ¡Toma un vaso de agua!',
      ),
      'Recordatorio programado: llegará en 10 segundos.',
    );
  }

  // Notificación periódica: se repite cada hora
  void _remindEveryHour() {
    _notify(
      () => NotificationService.instance.repeatHourly(
        id: NotificationService.hourlyId,
        title: 'Hora de hidratarte',
        body: 'Recuerda tomar un vaso de agua.',
      ),
      'Recordatorio activado: te avisaremos cada hora.',
    );
  }

  void _cancelReminders() {
    _notify(
      () async {
        await NotificationService.instance.cancelAll();
        return true;
      },
      'Recordatorios cancelados.',
    );
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
        child: SingleChildScrollView(
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
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 8),
              // Recordatorios con notificaciones locales
              const Text(
                'Recordatorios',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  ElevatedButton.icon(
                    onPressed: _remindInTenSeconds,
                    icon: const Icon(Icons.timer),
                    label: const Text('En 10 segundos'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _remindEveryHour,
                    icon: const Icon(Icons.repeat),
                    label: const Text('Cada hora'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _cancelReminders,
                    icon: const Icon(Icons.notifications_off),
                    label: const Text('Cancelar'),
                    style: TextButton.styleFrom(foregroundColor: Colors.teal),
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
