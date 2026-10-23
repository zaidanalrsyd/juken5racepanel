
import 'package:flutter_test/flutter_test.dart';
import 'package:juken_race_panel/app/app.dart';

void main() {
  testWidgets('JUKEN Race Panel app starts', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const JukenRacePanelApp());

    expect(find.byType(JukenRacePanelApp), findsOneWidget);
  });
}
