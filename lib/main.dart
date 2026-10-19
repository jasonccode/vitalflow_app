import 'package:flutter/material.dart';

import 'screens/login_screen.dart';
import 'screens/main_screen.dart';

void main() {
  runApp(const VitalFlowApp());
}

class VitalFlowApp extends StatelessWidget {
  const VitalFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VitalFlow',
      debugShowCheckedModeBanner: false,
      // En tu archivo lib/main.dart
      theme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFA8F5E5),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(),
        ),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const MainScreen(),
      },
    );
  }
}
