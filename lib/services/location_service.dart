import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

/// Error de ubicación con un mensaje listo para mostrarle al usuario.
class LocationException implements Exception {
  const LocationException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Servicio nativo: GPS / GEOLOCALIZACIÓN.
///
/// Obtiene las coordenadas del dispositivo con geolocator y las abre
/// en Google Maps con url_launcher.
class LocationService {
  LocationService._();

  /// Devuelve la posición actual del dispositivo.
  ///
  /// Lanza [LocationException] si el GPS está apagado, si el usuario
  /// niega el permiso o si no se logra obtener la ubicación.
  static Future<Position> getCurrentPosition() async {
    // 1. El GPS del celular debe estar encendido.
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const LocationException(
        'El GPS está apagado. Actívalo e inténtalo de nuevo.',
      );
    }

    // 2. Permiso de ubicación (ACCESS_FINE_LOCATION del AndroidManifest).
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw const LocationException('Permiso de ubicación denegado.');
    }
    if (permission == LocationPermission.deniedForever) {
      throw const LocationException(
        'El permiso de ubicación está bloqueado. '
        'Actívalo desde los ajustes de la aplicación.',
      );
    }

    // 3. Coordenadas. Si en 15 s no hay señal (por ejemplo, bajo techo),
    //    se usa la última ubicación conocida del dispositivo.
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
    } on TimeoutException {
      final Position? last = await Geolocator.getLastKnownPosition();
      if (last != null) return last;
      throw const LocationException(
        'No se pudo obtener la ubicación. '
        'Intenta en un lugar con mejor señal.',
      );
    }
  }

  /// URL de Google Maps que apunta a las coordenadas indicadas.
  static Uri mapsUri(double latitude, double longitude) {
    return Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    );
  }

  /// Abre las coordenadas de forma externa (app de Google Maps o navegador).
  static Future<void> openInGoogleMaps(
    double latitude,
    double longitude,
  ) async {
    final opened = await launchUrl(
      mapsUri(latitude, longitude),
      mode: LaunchMode.externalApplication,
    );
    if (!opened) {
      throw const LocationException('No se pudo abrir Google Maps.');
    }
  }
}
