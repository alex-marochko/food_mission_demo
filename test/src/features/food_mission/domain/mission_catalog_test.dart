import 'package:flutter_test/flutter_test.dart';
import 'package:food_mission_demo/src/features/food_mission/domain/mission_catalog.dart';

void main() {
  test('all missions reference known item ids', () {
    for (final mission in MissionCatalog.missions) {
      for (final itemId in [
        ...mission.targetItemIds,
        ...mission.distractorItemIds,
      ]) {
        expect(
          MissionCatalog.itemsById.containsKey(itemId),
          isTrue,
          reason: 'Mission ${mission.id} references missing item $itemId',
        );
      }
    }
  });

  test('every mission keeps targets and distractors separate', () {
    for (final mission in MissionCatalog.missions) {
      expect(
        mission.targetItemIds.toSet().intersection(
          mission.distractorItemIds.toSet(),
        ),
        isEmpty,
      );
    }
  });
}
