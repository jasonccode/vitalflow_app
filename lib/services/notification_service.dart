import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Servicio nativo: NOTIFICACIONES LOCALES.
///
/// Envuelve el plugin flutter_local_notifications para que las pantallas
/// solo llamen a métodos simples (mostrar ahora, programar, cancelar).
///
/// Todos los métodos que muestran algo devuelven `false` cuando el usuario
/// no concedió el permiso de notificaciones.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  // Identificadores de cada notificación. Reutilizar el mismo id
  // reemplaza la notificación anterior en lugar de duplicarla.
  static const int goalId = 1;
  static const int reminderId = 2;
  static const int hourlyId = 3;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _ready = false;

  // Canal de Android (obligatorio desde Android 8). Importancia máxima
  // para que la notificación aparezca como aviso emergente.
  static const NotificationDetails _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'vitalflow_recordatorios',
      'Recordatorios de hábitos',
      channelDescription: 'Recordatorios de hidratación y actividad',
      importance: Importance.max,
      priority: Priority.high,
    ),
  );

  AndroidFlutterLocalNotificationsPlugin? get _android =>
      _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

  /// Inicializa el plugin. Se llama una sola vez desde main().
  Future<void> init() async {
    // El servicio está configurado solo para Android.
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    try {
      tz_data.initializeTimeZones();
      const settings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      );
      await _plugin.initialize(settings);
      _ready = true;
    } catch (e) {
      debugPrint('No se pudieron iniciar las notificaciones: $e');
    }
  }

  /// Pide el permiso POST_NOTIFICATIONS (Android 13+ muestra un diálogo).
  Future<bool> requestPermission() async {
    if (!_ready) return false;
    final granted = await _android?.requestNotificationsPermission();
    return granted ?? false;
  }

  /// Muestra una notificación de inmediato.
  Future<bool> showNow({
    required int id,
    required String title,
    required String body,
  }) async {
    if (!await requestPermission()) return false;
    await _plugin.show(id, title, body, _details);
    return true;
  }

  /// Programa una notificación para dentro de [delay].
  Future<bool> scheduleIn(
    Duration delay, {
    required int id,
    required String title,
    required String body,
  }) async {
    if (!await requestPermission()) return false;

    // Hora exacta si el sistema lo permite; si no, aproximada.
    final canBeExact = await _android?.canScheduleExactNotifications() ?? false;

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.now(tz.local).add(delay),
      _details,
      androidScheduleMode: canBeExact
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
    return true;
  }

  /// Programa una notificación que se repite cada hora.
  Future<bool> repeatHourly({
    required int id,
    required String title,
    required String body,
  }) async {
    if (!await requestPermission()) return false;
    await _plugin.periodicallyShow(
      id,
      title,
      body,
      RepeatInterval.hourly,
      _details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
    return true;
  }

  /// Cancela todas las notificaciones mostradas y programadas.
  Future<void> cancelAll() async {
    if (!_ready) return;
    await _plugin.cancelAll();
  }
}
