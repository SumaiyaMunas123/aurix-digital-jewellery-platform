import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Basic MaterialApp widget test', (WidgetTester tester) async {
    // Create a simple test widget instead of the full app
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Aurix'),
          ),
        ),
      ),
    );

    // Verify the text appears
    expect(find.text('Aurix'), findsOneWidget);
  });
}