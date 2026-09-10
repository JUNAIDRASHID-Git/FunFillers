import 'package:equatable/equatable.dart';
import '../../core/constants/api_constants.dart';

class ProductEntity extends Equatable {
  final String id;
  final String title;
  final String category;
  final String categoryId;
  final String subCategory;
  final String subCategoryId;
  final String targetGender; // 'Boys', 'Girls', 'Educational', 'All'
  final double price;
  final double? originalPrice;
  final int discountPercent;
  final double rating;
  final int reviewCount;
  final String description;
  final String mainImage;
  final List<String> galleryImages;
  final bool isFeatured;
  final bool isFavorite;
  final int stock;

  String get imageUrl => mainImage;

  const ProductEntity({
    required this.id,
    required this.title,
    required this.category,
    this.categoryId = '',
    this.subCategory = '',
    this.subCategoryId = '',
    this.targetGender = 'All',
    required this.price,
    this.originalPrice,
    this.discountPercent = 0,
    required this.rating,
    required this.reviewCount,
    required this.description,
    required this.mainImage,
    required this.galleryImages,
    this.isFeatured = false,
    this.isFavorite = false,
    this.stock = 10,
  });

  ProductEntity copyWith({
    bool? isFavorite,
    int? stock,
    String? categoryId,
    String? subCategory,
    String? subCategoryId,
  }) {
    return ProductEntity(
      id: id,
      title: title,
      category: category,
      categoryId: categoryId ?? this.categoryId,
      subCategory: subCategory ?? this.subCategory,
      subCategoryId: subCategoryId ?? this.subCategoryId,
      targetGender: targetGender,
      price: price,
      originalPrice: originalPrice,
      discountPercent: discountPercent,
      rating: rating,
      reviewCount: reviewCount,
      description: description,
      mainImage: mainImage,
      galleryImages: galleryImages,
      isFeatured: isFeatured,
      isFavorite: isFavorite ?? this.isFavorite,
      stock: stock ?? this.stock,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'categoryId': categoryId,
      'subCategory': subCategory,
      'subCategoryId': subCategoryId,
      'targetGender': targetGender,
      'price': price,
      'originalPrice': originalPrice,
      'discountPercent': discountPercent,
      'rating': rating,
      'reviewCount': reviewCount,
      'description': description,
      'mainImage': mainImage,
      'galleryImages': galleryImages,
      'isFeatured': isFeatured,
      'isFavorite': isFavorite,
      'stock': stock,
    };
  }

  factory ProductEntity.fromJson(Map<String, dynamic> json) {
    final double p = (json['price'] as num?)?.toDouble() ?? 0.0;
    
    // Extract regular price / compare price from backend fields
    double? origP = (json['regularPrice'] as num?)?.toDouble() ??
        (json['regular_price'] as num?)?.toDouble() ??
        (json['comparePrice'] as num?)?.toDouble() ??
        (json['compare_price'] as num?)?.toDouble() ??
        (json['originalPrice'] as num?)?.toDouble();

    if (origP != null && origP <= p) {
      origP = null;
    }

    int discount = (json['discountPercent'] as num?)?.toInt() ?? 0;
    if (discount <= 0 && origP != null && origP > p && p > 0) {
      discount = (((origP - p) / origP) * 100).round();
    }

    final rawImg = json['imageUrl']?.toString() ?? json['image']?.toString() ?? json['mainImage']?.toString() ?? '';
    String mainImg = rawImg;
    if (rawImg.isNotEmpty) {
      if (rawImg.contains('localhost:') || rawImg.contains('127.0.0.1:')) {
        mainImg = rawImg.replaceAll(RegExp(r'http://(localhost|127\.0\.0\.1):(5050|8080|5000)'), ApiConstants.serverUrl);
      } else if (!rawImg.startsWith('http')) {
        mainImg = rawImg.startsWith('/') ? '${ApiConstants.serverUrl}$rawImg' : '${ApiConstants.serverUrl}/uploads/$rawImg';
      }
    }

    final List galleryRaw = (json['images'] as List?) ?? (json['galleryImages'] as List?) ?? (mainImg.isNotEmpty ? [mainImg] : []);
    final gallery = galleryRaw.map((e) {
      String s = e.toString();
      if (s.isNotEmpty) {
        if (s.contains('localhost:') || s.contains('127.0.0.1:')) {
          s = s.replaceAll(RegExp(r'http://(localhost|127\.0\.0\.1):(5050|8080|5000)'), ApiConstants.serverUrl);
        } else if (!s.startsWith('http')) {
          return s.startsWith('/') ? '${ApiConstants.serverUrl}$s' : '${ApiConstants.serverUrl}/uploads/$s';
        }
      }
      return s;
    }).toList();

    return ProductEntity(
      id: json['id']?.toString() ?? '',
      title: json['name']?.toString() ?? json['title']?.toString() ?? 'Toy Item',
      category: json['category']?.toString() ?? 'Toys',
      categoryId: json['categoryId']?.toString() ?? json['category_id']?.toString() ?? '',
      subCategory: json['subCategory']?.toString() ?? json['sub_category']?.toString() ?? '',
      subCategoryId: json['subCategoryId']?.toString() ?? json['sub_category_id']?.toString() ?? '',
      targetGender: json['targetGender']?.toString() ?? json['target_gender']?.toString() ?? 'All',
      price: p,
      originalPrice: origP,
      discountPercent: discount,
      rating: (json['rating'] as num?)?.toDouble() ?? 4.8,
      reviewCount: (json['reviewsCount'] as num?)?.toInt() ?? (json['reviewCount'] as num?)?.toInt() ?? 10,
      description: json['description']?.toString() ?? '',
      mainImage: mainImg,
      galleryImages: gallery,
      isFeatured: json['isFeatured'] == true || json['is_featured'] == true,
      isFavorite: json['isFavorite'] == true,
      stock: (json['stock'] as num?)?.toInt() ?? 10,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        category,
        categoryId,
        subCategory,
        subCategoryId,
        targetGender,
        price,
        originalPrice,
        discountPercent,
        rating,
        reviewCount,
        description,
        mainImage,
        galleryImages,
        isFeatured,
        isFavorite,
        stock,
      ];
}
