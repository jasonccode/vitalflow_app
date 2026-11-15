import 'dart:io';

import 'package:flutter/material.dart';

import '../services/profile_service.dart';

/// Avatar circular con la foto de perfil.
///
/// Escucha a ProfileService: cuando se toma una foto nueva, todos los
/// avatares de la aplicación se actualizan de inmediato.
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key, this.radius = 28});

  final double radius;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: ProfileService.instance.photoPath,
      builder: (context, path, _) {
        return CircleAvatar(
          radius: radius,
          backgroundColor: Colors.teal,
          backgroundImage: path != null ? FileImage(File(path)) : null,
          child: path == null
              ? Icon(Icons.person, size: radius, color: Colors.white)
              : null,
        );
      },
    );
  }
}
