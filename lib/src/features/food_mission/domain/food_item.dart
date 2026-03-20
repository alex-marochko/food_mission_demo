import 'package:equatable/equatable.dart';

class FoodItem extends Equatable {
  const FoodItem({required this.id, required this.emoji});

  final String id;
  final String emoji;

  @override
  List<Object?> get props => [id, emoji];
}
