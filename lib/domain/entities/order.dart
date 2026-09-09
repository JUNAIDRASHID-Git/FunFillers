import 'package:equatable/equatable.dart';
import 'cart_item.dart';
import 'address.dart';

class UserOrderEntity extends Equatable {
  final String id;
  final List<CartItemEntity> items;
  final double totalAmount;
  final String status; // 'Processing', 'Shipped', 'Delivered', 'Cancelled'
  final String paymentMethod;
  final AddressEntity shippingAddress;
  final DateTime createdAt;

  double get total => totalAmount;

  const UserOrderEntity({
    required this.id,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.paymentMethod,
    required this.shippingAddress,
    required this.createdAt,
  });

  UserOrderEntity copyWith({
    String? id,
    List<CartItemEntity>? items,
    double? totalAmount,
    String? status,
    String? paymentMethod,
    AddressEntity? shippingAddress,
    DateTime? createdAt,
  }) {
    return UserOrderEntity(
      id: id ?? this.id,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        items,
        totalAmount,
        status,
        paymentMethod,
        shippingAddress,
        createdAt,
      ];
}
