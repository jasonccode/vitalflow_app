import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.health_and_safety, size: 80, color: Colors.green),
            const SizedBox(height: 20),
            const Text('VitalFlow', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            const Text('Tus hábitos saludables', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 40),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Correo electrónico',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 20),
            const TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Contraseña',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: () {
                  // Navegación hacia el dashboard
                  Navigator.pushReplacementNamed(context, '/dashboard');
                },
                child: const Text('Iniciar Sesión', style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {},
              child: const Text('¿No tienes cuenta? Regístrate aquí', style: TextStyle(color: Colors.green)),
            )
          ],
        ),
      ),
    );
  }
}