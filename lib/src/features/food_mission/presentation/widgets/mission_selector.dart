import 'package:food_mission_demo/src/features/food_mission/domain/mission_definition.dart';
import 'package:flutter/material.dart';

class MissionSelector extends StatelessWidget {
  const MissionSelector({
    super.key,
    required this.missions,
    required this.selectedMission,
    required this.onSelected,
    required this.enabled,
  });

  final List<MissionDefinition> missions;
  final MissionDefinition selectedMission;
  final ValueChanged<MissionDefinition> onSelected;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: missions
          .map(
            (mission) => ChoiceChip(
              label: Text(mission.title),
              selected: mission == selectedMission,
              onSelected: enabled ? (_) => onSelected(mission) : null,
            ),
          )
          .toList(growable: false),
    );
  }
}
