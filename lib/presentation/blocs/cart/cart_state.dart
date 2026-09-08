import 'package:equatable/equatable.dart';
import '../../../domain/entities/cart_item.dart';

class CartState extends Equatable {
  final List<CartItemEntity> items;
  final double discountAmount;
  final double shippingFee;

  const CartState({
    this.items = const [],
    this.discountAmount = 0.00,
    this.shippingFee = 0.00,
  });

  List<CartItemEntity> get selectedItems => items.where((i) => i.isSelected).toList();

  double get subtotal {
    double sum = 0;
    for (var item in selectedItems) {
      sum += item.totalPrice;
    }
    return sum;
  }

  double get grandTotal {
    final sub = subtotal;
    if (sub <= 0) return 0.0;
    final total = sub - discountAmount + shippingFee;
    return total > 0 ? total : 0.0;
  }

  double get totalAmount => grandTotal;
  double get discount => discountAmount;

  double get totalSavings {
    double savings = 0;
    for (var item in selectedItems) {
      if (item.product.originalPrice != null && item.product.originalPrice! > item.product.price) {
        savings += (item.product.originalPrice! - item.product.price) * item.quantity;
      }
    }
    return savings;
  }

  int get totalItemCount {
    int count = 0;
    for (var item in items) {
      count += item.quantity;
    }
    return count;
  }

  bool get isAllSelected => items.isNotEmpty && items.every((i) => i.isSelected);

  CartState copyWith({
    List<CartItemEntity>? items,
    double? discountAmount,
    double? shippingFee,
  }) {
    return CartState(
      items: items ?? this.items,
      discountAmount: discountAmount ?? this.discountAmount,
      shippingFee: shippingFee ?? this.shippingFee,
    );
  }

  @override
  List<Object?> get props => [items, discountAmount, shippingFee];
}
