import 'package:flutter_test/flutter_test.dart';
import 'package:agneslb/main.dart';

void main() {
  testWidgets('AgnesLBApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const AgnesLBApp());
    expect(find.text('AgnesLB'), findsOneWidget);
  });
}
