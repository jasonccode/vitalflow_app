// Pruebas de la pantalla de inicio de sesión de VitalFlow.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vitalflow_app/main.dart';

void main() {
  testWidgets('La app abre en la pantalla de login', (WidgetTester tester) async {
    await tester.pumpWidget(const VitalFlowApp());

    expect(find.text('VitalFlow'), findsOneWidget);
    expect(find.text('Correo Electrónico'), findsOneWidget);
    expect(find.text('Contraseña'), findsOneWidget);
    expect(find.text('Iniciar Sesión'), findsOneWidget);
  });

  testWidgets('El login exige correo y contraseña', (WidgetTester tester) async {
    await tester.pumpWidget(const VitalFlowApp());

    await tester.tap(find.text('Iniciar Sesión'));
    await tester.pump();

    expect(find.text('Por favor ingrese su correo electrónico'), findsOneWidget);
    expect(find.text('Por favor ingrese su contraseña'), findsOneWidget);
  });

  testWidgets('El login rechaza correo inválido y contraseña corta',
      (WidgetTester tester) async {
    await tester.pumpWidget(const VitalFlowApp());

    await tester.enterText(find.byType(TextFormField).at(0), 'correo-sin-arroba');
    await tester.enterText(find.byType(TextFormField).at(1), '123');
    await tester.tap(find.text('Iniciar Sesión'));
    await tester.pump();

    expect(find.text('Ingrese un correo electrónico válido'), findsOneWidget);
    expect(
      find.text('La contraseña debe tener al menos 6 caracteres'),
      findsOneWidget,
    );
  });
}
