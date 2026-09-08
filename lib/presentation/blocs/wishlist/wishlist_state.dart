import 'package:equatable/equatable.dart';
import '../../../domain/entities/product.dart';

class WishlistState extends Equatable {
  final List<ProductEntity> favorites;

  const WishlistState({this.favorites = const []});

  bool isFavorite(String productId) {
    return favorites.any((p) => p.id == productId);
  }

  @override
  List<Object?> get props => [favorites];
}
