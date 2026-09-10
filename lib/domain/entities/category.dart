import 'package:equatable/equatable.dart';

class SubCategoryEntity extends Equatable {
  final String id;
  final String categoryId;
  final String name;
  final String iconImage;
  final String description;

  const SubCategoryEntity({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.iconImage,
    this.description = '',
  });

  @override
  List<Object?> get props => [id, categoryId, name, iconImage, description];
}

class CategoryEntity extends Equatable {
  final String id;
  final String name;
  final String iconImage;
  final int itemCount;
  final List<SubCategoryEntity> subCategories;

  const CategoryEntity({
    required this.id,
    required this.name,
    required this.iconImage,
    required this.itemCount,
    this.subCategories = const [],
  });

  @override
  List<Object?> get props => [id, name, iconImage, itemCount, subCategories];
}
