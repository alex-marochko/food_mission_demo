import 'package:food_mission_demo/src/features/food_mission/domain/food_item.dart';
import 'package:food_mission_demo/src/features/food_mission/domain/mission_definition.dart';

class MissionCatalog {
  const MissionCatalog._();

  static const itemsById = <String, FoodItem>{
    'grapes': FoodItem(id: 'grapes', emoji: '🍇'),
    'watermelon': FoodItem(id: 'watermelon', emoji: '🍉'),
    'orange': FoodItem(id: 'orange', emoji: '🍊'),
    'pineapple': FoodItem(id: 'pineapple', emoji: '🍍'),
    'mango': FoodItem(id: 'mango', emoji: '🥭'),
    'cookie': FoodItem(id: 'cookie', emoji: '🍪'),
    'doughnut': FoodItem(id: 'doughnut', emoji: '🍩'),
    'icecream': FoodItem(id: 'icecream', emoji: '🍦'),
    'cake': FoodItem(id: 'cake', emoji: '🍰'),
    'cupcake': FoodItem(id: 'cupcake', emoji: '🧁'),
    'pie': FoodItem(id: 'pie', emoji: '🥧'),
    'apple': FoodItem(id: 'apple', emoji: '🍎'),
    'greenApple': FoodItem(id: 'greenApple', emoji: '🍏'),
    'strawberry': FoodItem(id: 'strawberry', emoji: '🍓'),
    'blueberry': FoodItem(id: 'blueberry', emoji: '🫐'),
    'lemon': FoodItem(id: 'lemon', emoji: '🍋'),
    'kiwi': FoodItem(id: 'kiwi', emoji: '🥝'),
    'pear': FoodItem(id: 'pear', emoji: '🍐'),
    'tomato': FoodItem(id: 'tomato', emoji: '🍅'),
    'avocado': FoodItem(id: 'avocado', emoji: '🥑'),
    'carrot': FoodItem(id: 'carrot', emoji: '🥕'),
    'broccoli': FoodItem(id: 'broccoli', emoji: '🥦'),
    'cucumber': FoodItem(id: 'cucumber', emoji: '🥒'),
    'leafyGreens': FoodItem(id: 'leafyGreens', emoji: '🥬'),
    'peas': FoodItem(id: 'peas', emoji: '🫛'),
    'croissant': FoodItem(id: 'croissant', emoji: '🥐'),
    'baguette': FoodItem(id: 'baguette', emoji: '🥖'),
    'flatbread': FoodItem(id: 'flatbread', emoji: '🫓'),
    'pretzel': FoodItem(id: 'pretzel', emoji: '🥨'),
    'bagel': FoodItem(id: 'bagel', emoji: '🥯'),
    'taco': FoodItem(id: 'taco', emoji: '🌮'),
    'burrito': FoodItem(id: 'burrito', emoji: '🌯'),
    'popcorn': FoodItem(id: 'popcorn', emoji: '🍿'),
    'juice': FoodItem(id: 'juice', emoji: '🧃'),
    'pancakes': FoodItem(id: 'pancakes', emoji: '🥞'),
    'waffle': FoodItem(id: 'waffle', emoji: '🧇'),
    'cheese': FoodItem(id: 'cheese', emoji: '🧀'),
    'meat': FoodItem(id: 'meat', emoji: '🍖'),
    'poultryLeg': FoodItem(id: 'poultryLeg', emoji: '🍗'),
    'cutOfMeat': FoodItem(id: 'cutOfMeat', emoji: '🥩'),
    'bacon': FoodItem(id: 'bacon', emoji: '🥓'),
    'egg': FoodItem(id: 'egg', emoji: '🥚'),
    'friedEgg': FoodItem(id: 'friedEgg', emoji: '🍳'),
    'shallowPanFood': FoodItem(id: 'shallowPanFood', emoji: '🥘'),
    'potOfFood': FoodItem(id: 'potOfFood', emoji: '🍲'),
    'fondue': FoodItem(id: 'fondue', emoji: '🫕'),
    'bowlWithSpoon': FoodItem(id: 'bowlWithSpoon', emoji: '🥣'),
    'greenSalad': FoodItem(id: 'greenSalad', emoji: '🥗'),
    'rice': FoodItem(id: 'rice', emoji: '🍚'),
    'curryRice': FoodItem(id: 'curryRice', emoji: '🍛'),
    'bread': FoodItem(id: 'bread', emoji: '🍞'),
    'coffee': FoodItem(id: 'coffee', emoji: '☕'),
    'teapot': FoodItem(id: 'teapot', emoji: '🫖'),
    'tea': FoodItem(id: 'tea', emoji: '🍵'),
    'chocolate': FoodItem(id: 'chocolate', emoji: '🍫'),
    'pizza': FoodItem(id: 'pizza', emoji: '🍕'),
    'burger': FoodItem(id: 'burger', emoji: '🍔'),
    'fries': FoodItem(id: 'fries', emoji: '🍟'),
    'hotdog': FoodItem(id: 'hotdog', emoji: '🌭'),
    'candy': FoodItem(id: 'candy', emoji: '🍬'),
    'lollipop': FoodItem(id: 'lollipop', emoji: '🍭'),
    'custard': FoodItem(id: 'custard', emoji: '🍮'),
    'cocktail': FoodItem(id: 'cocktail', emoji: '🍹'),
    'beer': FoodItem(id: 'beer', emoji: '🍺'),
  };

  static final missions = <MissionDefinition>[
    const MissionDefinition(
      id: 'vitamins',
      goalScore: 120,
      durationSeconds: 20,
      mood: MissionMood.vitamins,
      targetItemIds: [
        'grapes',
        'watermelon',
        'orange',
        'lemon',
        'pineapple',
        'mango',
        'apple',
        'greenApple',
        'pear',
        'strawberry',
        'blueberry',
        'kiwi',
        'tomato',
        'avocado',
        'carrot',
        'cucumber',
        'leafyGreens',
        'broccoli',
        'peas',
        'juice',
      ],
      distractorItemIds: [
        'bread',
        'cheese',
        'friedEgg',
        'potOfFood',
        'shallowPanFood',
        'rice',
        'burger',
        'pizza',
        'doughnut',
        'cookie',
        'cake',
      ],
    ),
    const MissionDefinition(
      id: 'proper_meal',
      goalScore: 120,
      durationSeconds: 20,
      mood: MissionMood.properMeal,
      targetItemIds: [
        'bread',
        'baguette',
        'cheese',
        'meat',
        'poultryLeg',
        'cutOfMeat',
        'friedEgg',
        'shallowPanFood',
        'potOfFood',
        'greenSalad',
      ],
      distractorItemIds: [
        'orange',
        'strawberry',
        'broccoli',
        'cookie',
        'burger',
        'fries',
        'pizza',
        'hotdog',
        'icecream',
        'doughnut',
        'chocolate',
        'beer',
      ],
    ),
    const MissionDefinition(
      id: 'goodbye_diet',
      goalScore: 115,
      durationSeconds: 20,
      mood: MissionMood.goodbyeDiet,
      targetItemIds: [
        'burger',
        'fries',
        'pizza',
        'hotdog',
        'taco',
        'burrito',
        'popcorn',
        'icecream',
        'doughnut',
        'cookie',
        'cake',
        'cupcake',
        'pie',
        'chocolate',
        'candy',
        'lollipop',
        'custard',
        'cocktail',
        'beer',
      ],
      distractorItemIds: [
        'apple',
        'kiwi',
        'cucumber',
        'leafyGreens',
        'peas',
        'bread',
        'cheese',
        'friedEgg',
        'potOfFood',
        'greenSalad',
        'rice',
        'juice',
      ],
    ),
  ];

  static final Map<String, MissionDefinition> _missionsById = {
    for (final mission in missions) mission.id: mission,
  };

  static MissionDefinition get initialMission => missions.first;

  static MissionDefinition missionById(String id) {
    final mission = _missionsById[id];
    if (mission == null) {
      throw StateError('Unknown MissionDefinition id: $id');
    }
    return mission;
  }

  static List<FoodItem> resolveItems(List<String> itemIds) {
    return itemIds.map((id) => itemsById.getValue(id)).toList(growable: false);
  }
}

extension on Map<String, FoodItem> {
  FoodItem getValue(String key) {
    final value = this[key];
    if (value == null) {
      throw StateError('Unknown FoodItem id: $key');
    }
    return value;
  }
}
