import 'package:food_mission_demo/src/app/food_mission_app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders mission chips and primary CTA', (tester) async {
    await tester.pumpWidget(const FoodMissionApp());
    await tester.pump();

    expect(find.text('Promo Playground'), findsOneWidget);
    expect(find.text('Вітамінізація'), findsWidgets);
    expect(find.text('Поїж нормально'), findsWidgets);
    expect(find.text('Бувай, дієта'), findsWidgets);
    expect(find.text('Почати місію'), findsOneWidget);
  });
}
