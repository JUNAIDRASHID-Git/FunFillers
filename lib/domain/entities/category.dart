import 'package:equatable/equatable.dart';

class CategoryEntity extends Equatable {
  final String id;
  final String name;
  final String iconImage;
  final int itemCount;

  const CategoryEntity({
    required this.id,
    required this.name,
    required this.iconImage,
    required this.itemCount,
  });

  @override
  List<Object?> get props => [id, name, iconImage, itemCount];
}
