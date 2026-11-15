import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../helpers/database_helper.dart';

/// Servicio nativo: CÁMARA.
///
/// Abre la cámara del dispositivo con image_picker y deja la foto como
/// imagen de perfil. La ruta se guarda en SQLite para que la foto siga
/// ahí al cerrar y volver a abrir la aplicación.
class ProfileService {
  ProfileService._();
  static final ProfileService instance = ProfileService._();

  final ImagePicker _picker = ImagePicker();

  /// Ruta de la foto de perfil actual (null si todavía no hay foto).
  /// Los widgets que la escuchan se redibujan apenas cambia.
  final ValueNotifier<String?> photoPath = ValueNotifier<String?>(null);

  /// Carga la foto guardada. Se llama al entrar a la aplicación.
  Future<void> load() async {
    try {
      final saved = await DatabaseHelper.instance.getProfilePhoto();
      if (saved != null && File(saved).existsSync()) {
        photoPath.value = saved;
      }
      await _recoverLostPhoto();
    } catch (e) {
      debugPrint('No se pudo cargar la foto de perfil: $e');
    }
  }

  /// Abre la cámara y guarda la foto como imagen de perfil.
  /// Devuelve false si el usuario cerró la cámara sin tomar la foto.
  Future<bool> takePhoto() async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 800,
      imageQuality: 85,
    );
    if (picked == null) return false;

    await _savePhoto(picked);
    return true;
  }

  // La cámara deja la foto en una carpeta temporal. Se copia a la carpeta
  // de documentos de la app (privada, no requiere permiso de almacenamiento).
  Future<void> _savePhoto(XFile picked) async {
    final Directory dir = await getApplicationDocumentsDirectory();
    final String name =
        'perfil_${DateTime.now().millisecondsSinceEpoch}${p.extension(picked.path)}';
    final String newPath = p.join(dir.path, name);
    await File(picked.path).copy(newPath);

    final String? previous = photoPath.value;
    await DatabaseHelper.instance.saveProfilePhoto(newPath);
    photoPath.value = newPath;

    // La foto anterior ya no se usa: se borra para no ocupar espacio.
    if (previous != null && previous != newPath) {
      try {
        await File(previous).delete();
      } catch (_) {
        // Si no se puede borrar no pasa nada: solo queda un archivo sin usar.
      }
    }
  }

  // Android puede cerrar la app mientras la cámara está abierta (poca
  // memoria). image_picker conserva la foto para recuperarla al volver.
  Future<void> _recoverLostPhoto() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    final LostDataResponse response = await _picker.retrieveLostData();
    final XFile? file = response.file;
    if (!response.isEmpty && file != null) {
      await _savePhoto(file);
    }
  }
}
