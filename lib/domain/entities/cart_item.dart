import 'package:equatable/equatable.dart';
import 'product.dart';

class CartItemEntity extends Equatable {
  final ProductEntity product;
  final int quantity;
  final bool isSelected;

  const CartItemEntity({
    required this.product,
    this.quantity = 1,
    this.isSelected = true,
  });

  double get totalPrice => product.price * quantity;

  CartItemEntity copyWith({
    int? quantity,
    bool? isSelected,
  }) {
    return CartItemEntity(
      product: product,
      quantity: quantity ?? this.quantity,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'quantity': quantity,
      'isSelected': isSelected,
    };
  }

  factory CartItemEntity.fromJson(Map<String, dynamic> json) {
    return CartItemEntity(
      product: ProductEntity.fromJson(json['product'] as Map<String, dynamic>),
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      isSelected: json['isSelected'] == true,
    );
  }

  @override
  List<Object?> get props => [product, quantity, isSelected];
}
