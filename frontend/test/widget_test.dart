import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aurix/app.dart';

void main() {
  testWidgets('Aurix app builds and shows MaterialApp', (WidgetTester tester) async {
    await tester.pumpWidget(const AurixApp());
    await tester.pumpAndSettle();

    // Basic sanity checks
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('Aurix'), findsWidgets); // app title can appear in multiple places
  });
}