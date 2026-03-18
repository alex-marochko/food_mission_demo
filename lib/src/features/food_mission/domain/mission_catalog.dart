import 'package:food_mission_demo/src/features/food_mission/domain/food_item.dart';
import 'package:food_mission_demo/src/features/food_mission/domain/mission_definition.dart';

class MissionCatalog {
  const MissionCatalog._();

  static const itemsById = <String, FoodItem>{
    'cookie': FoodItem(id: 'cookie', emoji: '🍪', label: 'Печиво'),
    'doughnut': FoodItem(id: 'doughnut', emoji: '🍩', label: 'Пончик'),
    'icecream': FoodItem(id: 'icecream', emoji: '🍦', label: 'Морозиво'),
    'cake': FoodItem(id: 'cake', emoji: '🍰', label: 'Торт'),
    'cupcake': FoodItem(id: 'cupcake', emoji: '🧁', label: 'Капкейк'),
    'honey': FoodItem(id: 'honey', emoji: '🍯', label: 'Мед'),
    'apple': FoodItem(id: 'apple', emoji: '🍎', label: 'Яблуко'),
    'greenApple': FoodItem(
      id: 'greenApple',
      emoji: '🍏',
      label: 'Зелене яблуко',
    ),
    'strawberry': FoodItem(id: 'strawberry', emoji: '🍓', label: 'Полуниця'),
    'blueberry': FoodItem(id: 'blueberry', emoji: '🫐', label: 'Лохина'),
    'lemon': FoodItem(id: 'lemon', emoji: '🍋', label: 'Лимон'),
    'kiwi': FoodItem(id: 'kiwi', emoji: '🥝', label: 'Ківі'),
    'avocado': FoodItem(id: 'avocado', emoji: '🥑', label: 'Авокадо'),
    'broccoli': FoodItem(id: 'broccoli', emoji: '🥦', label: 'Броколі'),
    'cucumber': FoodItem(id: 'cucumber', emoji: '🥒', label: 'Огірок'),
    'croissant': FoodItem(id: 'croissant', emoji: '🥐', label: 'Круасан'),
    'pretzel': FoodItem(id: 'pretzel', emoji: '🥨', label: 'Крендель'),
    'sandwich': FoodItem(id: 'sandwich', emoji: '🥪', label: 'Сендвіч'),
    'taco': FoodItem(id: 'taco', emoji: '🌮', label: 'Тако'),
    'popcorn': FoodItem(id: 'popcorn', emoji: '🍿', label: 'Попкорн'),
    'bubbleTea': FoodItem(id: 'bubbleTea', emoji: '🧋', label: 'Бабл-ті'),
    'juice': FoodItem(id: 'juice', emoji: '🧃', label: 'Сік'),
    'pancakes': FoodItem(id: 'pancakes', emoji: '🥞', label: 'Панкейки'),
    'waffle': FoodItem(id: 'waffle', emoji: '🧇', label: 'Вафля'),
    'friedEgg': FoodItem(id: 'friedEgg', emoji: '🍳', label: 'Яєчня'),
    'bread': FoodItem(id: 'bread', emoji: '🍞', label: 'Хліб'),
    'coffee': FoodItem(id: 'coffee', emoji: '☕', label: 'Кава'),
    'teapot': FoodItem(id: 'teapot', emoji: '🫖', label: 'Чайник'),
    'tea': FoodItem(id: 'tea', emoji: '🍵', label: 'Чай'),
    'chocolate': FoodItem(id: 'chocolate', emoji: '🍫', label: 'Шоколад'),
    'pizza': FoodItem(id: 'pizza', emoji: '🍕', label: 'Піца'),
    'burger': FoodItem(id: 'burger', emoji: '🍔', label: 'Бургер'),
    'fries': FoodItem(id: 'fries', emoji: '🍟', label: 'Картопля фрі'),
    'cocktail': FoodItem(id: 'cocktail', emoji: '🍹', label: 'Коктейль'),
  };

  static final missions = <MissionDefinition>[
    const MissionDefinition(
      id: 'dessert',
      title: 'Солодощі',
      tagline: 'Лови солодощі, пропускай фастфуд, чай і фрукти.',
      brief: 'Гість чекає на маленьке свято після покупки.',
      goalScore: 110,
      durationSeconds: 20,
      mood: MissionMood.dessert,
      targetItemIds: [
        'cookie',
        'doughnut',
        'icecream',
        'cake',
        'cupcake',
        'honey',
        'chocolate',
      ],
      distractorItemIds: ['pizza', 'burger', 'fries', 'tea', 'apple'],
    ),
    const MissionDefinition(
      id: 'vitamins',
      title: 'Вітамінізація',
      tagline: 'Збери корисне і не ведись на зайвий sugar rush.',
      brief: 'Набери кольоровий кошик для швидкого healthy boost.',
      goalScore: 120,
      durationSeconds: 20,
      mood: MissionMood.vitamins,
      targetItemIds: [
        'apple',
        'greenApple',
        'strawberry',
        'blueberry',
        'lemon',
        'kiwi',
        'avocado',
        'broccoli',
        'cucumber',
      ],
      distractorItemIds: ['cookie', 'doughnut', 'cake', 'burger', 'fries'],
    ),
    const MissionDefinition(
      id: 'road_trip',
      title: 'Перекус в дорозі',
      tagline: 'Пакуй усе, що легко схопити на ходу.',
      brief: 'Потрібен швидкий snacking kit для поїздки містом.',
      goalScore: 115,
      durationSeconds: 20,
      mood: MissionMood.roadTrip,
      targetItemIds: [
        'croissant',
        'pretzel',
        'sandwich',
        'taco',
        'popcorn',
        'bubbleTea',
        'juice',
      ],
      distractorItemIds: ['broccoli', 'friedEgg', 'teapot', 'coffee', 'cake'],
    ),
    const MissionDefinition(
      id: 'breakfast',
      title: 'Сніданок',
      tagline: 'Лови ранкову класику і збери ідеальний старт дня.',
      brief: 'Тут важливий баланс між ситністю та comfort vibe.',
      goalScore: 120,
      durationSeconds: 20,
      mood: MissionMood.breakfast,
      targetItemIds: [
        'croissant',
        'pancakes',
        'waffle',
        'friedEgg',
        'bread',
        'coffee',
        'tea',
      ],
      distractorItemIds: ['fries', 'burger', 'cocktail', 'pizza', 'icecream'],
    ),
    const MissionDefinition(
      id: 'coffee_break',
      title: 'Каво-брейк',
      tagline: 'Комбо з кави та солодкого для короткої паузи.',
      brief: 'Усе для офісного pit stop між дзвінками й задачами.',
      goalScore: 110,
      durationSeconds: 20,
      mood: MissionMood.coffeeBreak,
      targetItemIds: [
        'coffee',
        'teapot',
        'tea',
        'cookie',
        'cupcake',
        'cake',
        'chocolate',
      ],
      distractorItemIds: ['burger', 'fries', 'broccoli', 'cucumber', 'taco'],
    ),
  ];

  static MissionDefinition get initialMission => missions.first;

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
