import 'package:food_mission_demo/src/features/food_mission/domain/food_item.dart';
import 'package:food_mission_demo/src/features/food_mission/domain/mission_definition.dart';

class MissionCatalog {
  const MissionCatalog._();

  static const itemsById = <String, FoodItem>{
    'grapes': FoodItem(id: 'grapes', emoji: '🍇', label: 'Виноград'),
    'watermelon': FoodItem(id: 'watermelon', emoji: '🍉', label: 'Кавун'),
    'orange': FoodItem(id: 'orange', emoji: '🍊', label: 'Апельсин'),
    'pineapple': FoodItem(id: 'pineapple', emoji: '🍍', label: 'Ананас'),
    'mango': FoodItem(id: 'mango', emoji: '🥭', label: 'Манго'),
    'cookie': FoodItem(id: 'cookie', emoji: '🍪', label: 'Печиво'),
    'doughnut': FoodItem(id: 'doughnut', emoji: '🍩', label: 'Пончик'),
    'icecream': FoodItem(id: 'icecream', emoji: '🍦', label: 'Морозиво'),
    'cake': FoodItem(id: 'cake', emoji: '🍰', label: 'Торт'),
    'cupcake': FoodItem(id: 'cupcake', emoji: '🧁', label: 'Капкейк'),
    'pie': FoodItem(id: 'pie', emoji: '🥧', label: 'Пиріг'),
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
    'pear': FoodItem(id: 'pear', emoji: '🍐', label: 'Груша'),
    'tomato': FoodItem(id: 'tomato', emoji: '🍅', label: 'Томат'),
    'avocado': FoodItem(id: 'avocado', emoji: '🥑', label: 'Авокадо'),
    'carrot': FoodItem(id: 'carrot', emoji: '🥕', label: 'Морква'),
    'broccoli': FoodItem(id: 'broccoli', emoji: '🥦', label: 'Броколі'),
    'cucumber': FoodItem(id: 'cucumber', emoji: '🥒', label: 'Огірок'),
    'leafyGreens': FoodItem(id: 'leafyGreens', emoji: '🥬', label: 'Зелень'),
    'peas': FoodItem(id: 'peas', emoji: '🫛', label: 'Горошок'),
    'croissant': FoodItem(id: 'croissant', emoji: '🥐', label: 'Круасан'),
    'baguette': FoodItem(id: 'baguette', emoji: '🥖', label: 'Багет'),
    'flatbread': FoodItem(id: 'flatbread', emoji: '🫓', label: 'Коржик'),
    'pretzel': FoodItem(id: 'pretzel', emoji: '🥨', label: 'Крендель'),
    'bagel': FoodItem(id: 'bagel', emoji: '🥯', label: 'Бейгл'),
    'sandwich': FoodItem(id: 'sandwich', emoji: '🥪', label: 'Сендвіч'),
    'taco': FoodItem(id: 'taco', emoji: '🌮', label: 'Тако'),
    'burrito': FoodItem(id: 'burrito', emoji: '🌯', label: 'Буріто'),
    'popcorn': FoodItem(id: 'popcorn', emoji: '🍿', label: 'Попкорн'),
    'bubbleTea': FoodItem(id: 'bubbleTea', emoji: '🧋', label: 'Бабл-ті'),
    'juice': FoodItem(id: 'juice', emoji: '🧃', label: 'Сік'),
    'pancakes': FoodItem(id: 'pancakes', emoji: '🥞', label: 'Панкейки'),
    'waffle': FoodItem(id: 'waffle', emoji: '🧇', label: 'Вафля'),
    'cheese': FoodItem(id: 'cheese', emoji: '🧀', label: 'Сир'),
    'meat': FoodItem(id: 'meat', emoji: '🍖', label: 'Мʼясо'),
    'poultryLeg': FoodItem(
      id: 'poultryLeg',
      emoji: '🍗',
      label: 'Куряча ніжка',
    ),
    'cutOfMeat': FoodItem(id: 'cutOfMeat', emoji: '🥩', label: 'Стейк'),
    'bacon': FoodItem(id: 'bacon', emoji: '🥓', label: 'Бекон'),
    'egg': FoodItem(id: 'egg', emoji: '🥚', label: 'Яйце'),
    'friedEgg': FoodItem(id: 'friedEgg', emoji: '🍳', label: 'Яєчня'),
    'shallowPanFood': FoodItem(
      id: 'shallowPanFood',
      emoji: '🥘',
      label: 'Гаряча страва',
    ),
    'potOfFood': FoodItem(id: 'potOfFood', emoji: '🍲', label: 'Каструля'),
    'fondue': FoodItem(id: 'fondue', emoji: '🫕', label: 'Фондю'),
    'bowlWithSpoon': FoodItem(id: 'bowlWithSpoon', emoji: '🥣', label: 'Боул'),
    'greenSalad': FoodItem(id: 'greenSalad', emoji: '🥗', label: 'Салат'),
    'spaghetti': FoodItem(id: 'spaghetti', emoji: '🍝', label: 'Паста'),
    'rice': FoodItem(id: 'rice', emoji: '🍚', label: 'Рис'),
    'curryRice': FoodItem(id: 'curryRice', emoji: '🍛', label: 'Карі з рисом'),
    'bread': FoodItem(id: 'bread', emoji: '🍞', label: 'Хліб'),
    'coffee': FoodItem(id: 'coffee', emoji: '☕', label: 'Кава'),
    'teapot': FoodItem(id: 'teapot', emoji: '🫖', label: 'Чайник'),
    'tea': FoodItem(id: 'tea', emoji: '🍵', label: 'Чай'),
    'chocolate': FoodItem(id: 'chocolate', emoji: '🍫', label: 'Шоколад'),
    'pizza': FoodItem(id: 'pizza', emoji: '🍕', label: 'Піца'),
    'burger': FoodItem(id: 'burger', emoji: '🍔', label: 'Бургер'),
    'fries': FoodItem(id: 'fries', emoji: '🍟', label: 'Картопля фрі'),
    'hotdog': FoodItem(id: 'hotdog', emoji: '🌭', label: 'Хот-дог'),
    'candy': FoodItem(id: 'candy', emoji: '🍬', label: 'Цукерка'),
    'lollipop': FoodItem(id: 'lollipop', emoji: '🍭', label: 'Льодяник'),
    'custard': FoodItem(id: 'custard', emoji: '🍮', label: 'Пудинг'),
    'cocktail': FoodItem(id: 'cocktail', emoji: '🍹', label: 'Коктейль'),
    'beer': FoodItem(id: 'beer', emoji: '🍺', label: 'Пиво'),
    'clinkingBeers': FoodItem(
      id: 'clinkingBeers',
      emoji: '🍻',
      label: 'Пиво удвох',
    ),
    'clinkingGlasses': FoodItem(
      id: 'clinkingGlasses',
      emoji: '🥂',
      label: 'Ігристе',
    ),
  };

  static final missions = <MissionDefinition>[
    const MissionDefinition(
      id: 'vitamins',
      title: 'Вітамінізація',
      tagline:
          'Фрукти, овочі, зелень і healthy-drinks. Лови вітаміни, не хаос.',
      brief: 'Кошик для тих, хто сьогодні справді за себе взявся.',
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
        'spaghetti',
        'rice',
        'burger',
        'pizza',
        'doughnut',
        'cookie',
        'cake',
        'bubbleTea',
      ],
    ),
    const MissionDefinition(
      id: 'proper_meal',
      title: 'Поїж нормально',
      tagline: 'Ситна їжа, сніданки й домашні страви. Без чітмільних спокус.',
      brief: 'Тут не про салатик на два листочки, а про нормальний прийом їжі.',
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
        'juice',
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
      title: 'Бувай, дієта',
      tagline: 'Фастфуд, десерти, снеки й рідкі калорії. Соромно? Ні.',
      brief: 'Категорія для днів, коли план харчування пішов гуляти без тебе.',
      goalScore: 115,
      durationSeconds: 20,
      mood: MissionMood.goodbyeDiet,
      targetItemIds: [
        'burger',
        'fries',
        'pizza',
        'hotdog',
        'sandwich',
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
        'honey',
        'cocktail',
        'beer',
        'clinkingBeers',
        'clinkingGlasses',
        'bubbleTea',
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
