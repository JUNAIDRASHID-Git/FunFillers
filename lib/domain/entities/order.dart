import 'package:equatable/equatable.dart';
import 'cart_item.dart';
import 'address.dart';

class UserOrderEntity extends Equatable {
  final String id;
  final List<CartItemEntity> items;
  final double totalAmount;
  final String status; // 'Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled'
  final String paymentMethod;
  final String? paymentId;
  final String? refundId;
  final double? refundAmount;
  final String? refundStatus;
  final String? cancellationReason;
  final AddressEntity shippingAddress;
  final DateTime createdAt;

  double get total => totalAmount;

  const UserOrderEntity({
    required this.id,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.paymentMethod,
    this.paymentId,
    this.refundId,
    this.refundAmount,
    this.refundStatus,
    this.cancellationReason,
    required this.shippingAddress,
    required this.createdAt,
  });

  UserOrderEntity copyWith({
    String? id,
    List<CartItemEntity>? items,
    double? totalAmount,
    String? status,
    String? paymentMethod,
    String? paymentId,
    String? refundId,
    double? refundAmount,
    String? refundStatus,
    String? cancellationReason,
    AddressEntity? shippingAddress,
    DateTime? createdAt,
  }) {
    return UserOrderEntity(
      id: id ?? this.id,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentId: paymentId ?? this.paymentId,
      refundId: refundId ?? this.refundId,
      refundAmount: refundAmount ?? this.refundAmount,
      refundStatus: refundStatus ?? this.refundStatus,
      cancellationReason: cancellationReason ?? this.cancellationReason,
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
        paymentId,
        refundId,
        refundAmount,
        refundStatus,
        cancellationReason,
        shippingAddress,
        createdAt,
      ];
}
