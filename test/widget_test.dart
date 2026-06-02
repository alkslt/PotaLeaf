import 'package:flutter_test/flutter_test.dart';

import 'package:alya_project/main.dart';

void main() {
  testWidgets('PotaLeaf app boots correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const PotaLeafApp());
    // App should render without crashing
    expect(find.byType(PotaLeafApp), findsOneWidget);
  });
}
