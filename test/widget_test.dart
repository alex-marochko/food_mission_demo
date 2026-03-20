import 'package:food_mission_demo/src/app/food_mission_app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders intro popup for level one in Ukrainian', (tester) async {
    await tester.pumpWidget(const FoodMissionApp());
    await tester.pump();

    expect(find.text('Рівень 1'), findsOneWidget);
    expect(find.text('Бувай, дієта'), findsWidgets);
    expect(find.text('Почати рівень'), findsOneWidget);
  });

  testWidgets('switches intro popup language to English', (tester) async {
    await tester.pumpWidget(const FoodMissionApp());
    await tester.pump();

    await tester.tap(find.text('EN'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Level 1'), findsOneWidget);
    expect(find.text('Goodbye, Diet'), findsWidgets);
    expect(find.text('Start level'), findsOneWidget);
  });
}
