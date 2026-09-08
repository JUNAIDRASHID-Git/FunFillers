import '../../domain/entities/product.dart';

class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    required super.title,
    required super.category,
    super.targetGender,
    required super.price,
    super.originalPrice,
    super.discountPercent,
    required super.rating,
    required super.reviewCount,
    required super.description,
    required super.mainImage,
    required super.galleryImages,
    super.isFeatured,
    super.isFavorite,
    super.stock,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? '',
      title: json['title'] ?? json['name'] ?? '',
      category: json['category'] ?? 'Toys',
      targetGender: json['targetGender'] ?? 'All',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      originalPrice: (json['originalPrice'] as num?)?.toDouble(),
      discountPercent: (json['discountPercent'] as num?)?.toInt() ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 4.8,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 120,
      description: json['description'] ?? 'Soft, safe, and fun companion for kids.',
      mainImage: json['mainImage'] ?? json['image'] ?? 'https://images.unsplash.com/photo-1558060370-d644479be6f7?auto=format&fit=crop&w=600&q=80',
      galleryImages: (json['galleryImages'] as List?)?.map((e) => e.toString()).toList() ?? [
        json['mainImage'] ?? json['image'] ?? 'https://images.unsplash.com/photo-1558060370-d644479be6f7?auto=format&fit=crop&w=600&q=80',
      ],
      isFeatured: json['isFeatured'] ?? true,
      isFavorite: json['isFavorite'] ?? false,
      stock: json['stock'] ?? 15,
    );
  }
}
