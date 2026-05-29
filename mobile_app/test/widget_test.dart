import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile_app/main.dart';

void main() {
  testWidgets('Splash screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const KitsAndKidsApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
