import 'package:equatable/equatable.dart';

class FoodItem extends Equatable {
  const FoodItem({required this.id, required this.emoji, required this.label});

  final String id;
  final String emoji;
  final String label;

  @override
  List<Object?> get props => [id, emoji, label];
}
