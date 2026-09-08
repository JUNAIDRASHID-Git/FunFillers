import 'package:equatable/equatable.dart';
import '../../../domain/entities/product.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();
  @override
  List<Object?> get props => [];
}

class LoadCart extends CartEvent {}

class AddToCartRequested extends CartEvent {
  final ProductEntity product;
  final int quantity;
  const AddToCartRequested({required this.product, this.quantity = 1});

  @override
  List<Object?> get props => [product, quantity];
}

class RemoveFromCartRequested extends CartEvent {
  final String productId;
  const RemoveFromCartRequested(this.productId);

  @override
  List<Object?> get props => [productId];
}

class UpdateCartQuantityRequested extends CartEvent {
  final String productId;
  final int quantity;
  const UpdateCartQuantityRequested(this.productId, this.quantity);

  @override
  List<Object?> get props => [productId, quantity];
}

class ToggleCartItemSelectionRequested extends CartEvent {
  final String productId;
  const ToggleCartItemSelectionRequested(this.productId);

  @override
  List<Object?> get props => [productId];
}

class ToggleSelectAllCartItemsRequested extends CartEvent {
  final bool selectAll;
  const ToggleSelectAllCartItemsRequested(this.selectAll);

  @override
  List<Object?> get props => [selectAll];
}

class ClearCartRequested extends CartEvent {}

typedef AddToCart = AddToCartRequested;
typedef ClearCart = ClearCartRequested;
