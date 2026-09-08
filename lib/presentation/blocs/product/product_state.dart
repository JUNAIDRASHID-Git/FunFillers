import 'package:equatable/equatable.dart';
import '../../../domain/entities/product.dart';

abstract class ProductState extends Equatable {
  const ProductState();
  @override
  List<Object?> get props => [];
}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductLoaded extends ProductState {
  final List<ProductEntity> products;
  final List<ProductEntity> filteredProducts;
  final String activeGenderFilter;
  final String searchQuery;

  const ProductLoaded({
    required this.products,
    required this.filteredProducts,
    this.activeGenderFilter = 'All',
    this.searchQuery = '',
  });

  ProductLoaded copyWith({
    List<ProductEntity>? products,
    List<ProductEntity>? filteredProducts,
    String? activeGenderFilter,
    String? searchQuery,
  }) {
    return ProductLoaded(
      products: products ?? this.products,
      filteredProducts: filteredProducts ?? this.filteredProducts,
      activeGenderFilter: activeGenderFilter ?? this.activeGenderFilter,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [products, filteredProducts, activeGenderFilter, searchQuery];
}

class ProductError extends ProductState {
  final String message;
  const ProductError(this.message);

  @override
  List<Object?> get props => [message];
}
