import 'package:apophenia_flutter/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Theme builds with RTL', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: Center(child: Text('السور')),
          ),
        ),
      ),
    );
    expect(find.text('السور'), findsOneWidget);
  });
}
