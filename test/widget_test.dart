import 'package:food_mission_demo/src/app/food_mission_app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders intro popup for level one', (tester) async {
    await tester.pumpWidget(const FoodMissionApp());
    await tester.pump();

    expect(find.text('Рівень 1'), findsOneWidget);
    expect(find.text('Бувай, дієта'), findsWidgets);
    expect(find.text('Почати рівень'), findsOneWidget);
  });
}
