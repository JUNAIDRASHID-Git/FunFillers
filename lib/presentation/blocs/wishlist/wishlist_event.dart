import 'package:equatable/equatable.dart';
import '../../../domain/entities/product.dart';

abstract class WishlistEvent extends Equatable {
  const WishlistEvent();
  @override
  List<Object?> get props => [];
}

class LoadWishlist extends WishlistEvent {}

class ToggleWishlistRequested extends WishlistEvent {
  final ProductEntity product;
  const ToggleWishlistRequested(this.product);

  @override
  List<Object?> get props => [product];
}

typedef ToggleWishlist = ToggleWishlistRequested;
