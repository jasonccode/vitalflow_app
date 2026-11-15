import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:share_plus/share_plus.dart';

import '../helpers/database_helper.dart';
import '../services/location_service.dart';
import '../services/profile_service.dart';
import '../widgets/profile_avatar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Position? _position; // Última ubicación obtenida con el GPS
  bool _loadingLocation = false;

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // SERVICIO 1 - CÁMARA: toma la foto y la deja como imagen de perfil
  Future<void> _takePhoto() async {
    try {
      final saved = await ProfileService.instance.takePhoto();
      if (saved) _showMessage('Foto de perfil actualizada.');
    } on PlatformException catch (e) {
      if (e.code == 'camera_access_denied') {
        _showMessage('Permiso de cámara denegado.');
      } else {
        _showMessage('No se pudo abrir la cámara: ${e.message ?? e.code}');
      }
    } catch (e) {
      _showMessage('No se pudo guardar la foto: $e');
    }
  }

  // SERVICIO 2 - GPS: obtiene las coordenadas y las abre en Google Maps
  Future<void> _openMyLocation() async {
    setState(() => _loadingLocation = true);
    try {
      final position = await LocationService.getCurrentPosition();
      if (!mounted) return;
      setState(() => _position = position);
      await LocationService.openInGoogleMaps(
        position.latitude,
        position.longitude,
      );
    } on LocationException catch (e) {
      _showMessage(e.message);
    } catch (e) {
      _showMessage('Error al obtener la ubicación: $e');
    } finally {
      if (mounted) setState(() => _loadingLocation = false);
    }
  }

  // SERVICIO 3 - COMPARTIR: envía el progreso a WhatsApp u otras apps
  Future<void> _shareProgress() async {
    try {
      // El resumen se arma con las rutinas guardadas en SQLite
      final routines = await DatabaseHelper.instance.getRoutines();
      int totalMinutes = 0;
      for (final routine in routines) {
        totalMinutes += routine['duration'] as int;
      }

      final text = StringBuffer()
        ..writeln('Mi progreso en VitalFlow')
        ..writeln('Rutinas registradas: ${routines.length}')
        ..writeln('Tiempo activo: $totalMinutes min');

      final position = _position;
      if (position != null) {
        final link = LocationService.mapsUri(
          position.latitude,
          position.longitude,
        );
        text.writeln('Mi ubicación: $link');
      }

      await SharePlus.instance.share(
        ShareParams(
          text: text.toString().trim(),
          subject: 'Mi progreso en VitalFlow',
        ),
      );
    } catch (e) {
      _showMessage('No se pudo compartir: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final position = _position;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 8),
            // Foto de perfil con el botón de la cámara encima
            Stack(
              children: [
                const ProfileAvatar(radius: 64),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: IconButton.filled(
                    onPressed: _takePhoto,
                    tooltip: 'Tomar foto de perfil',
                    icon: const Icon(Icons.camera_alt),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      // Borde blanco para que se distinga sobre el avatar
                      side: const BorderSide(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Jeison Camargo',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Toca la cámara para cambiar tu foto de perfil',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            // Tarjeta del GPS
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.redAccent),
                        SizedBox(width: 8),
                        Text(
                          'Mi ubicación (GPS)',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      position == null
                          ? 'Aún no se ha consultado tu ubicación.'
                          : 'Latitud: ${position.latitude.toStringAsFixed(6)}\n'
                              'Longitud: ${position.longitude.toStringAsFixed(6)}',
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _loadingLocation ? null : _openMyLocation,
                        icon: _loadingLocation
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.teal,
                                ),
                              )
                            : const Icon(Icons.map),
                        label: Text(
                          _loadingLocation
                              ? 'Obteniendo ubicación...'
                              : 'Ver en Google Maps',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Tarjeta de compartir
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.share, color: Colors.teal),
                        SizedBox(width: 8),
                        Text(
                          'Compartir',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Envía el resumen de tus rutinas por WhatsApp '
                      'u otra aplicación.',
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _shareProgress,
                        icon: const Icon(Icons.send),
                        label: const Text('Compartir mi progreso'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                        ),
                      ),
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
}
