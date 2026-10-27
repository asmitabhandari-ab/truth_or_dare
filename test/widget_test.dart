import 'package:flutter_test/flutter_test.dart';

import 'package:truth_or_dare/main.dart';

void main() {
  testWidgets('shows the game home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const TruthOrDareApp());

    expect(find.text('TRUTH\nOR DARE'), findsOneWidget);
    expect(find.text('START A GAME'), findsOneWidget);
  });
}
