import 'package:flutter_test/flutter_test.dart';

import 'package:morse_code/main.dart';

void main() {
  testWidgets('App renders phone screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MorseApp());
    expect(find.text('Enter Recipient'), findsOneWidget);
  });
}
