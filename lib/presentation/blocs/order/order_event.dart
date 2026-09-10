import 'package:equatable/equatable.dart';
import '../../../domain/entities/cart_item.dart';
import '../../../domain/entities/address.dart';

abstract class OrderEvent extends Equatable {
  const OrderEvent();
  @override
  List<Object?> get props => [];
}

class PlaceOrderRequested extends OrderEvent {
  final List<CartItemEntity> items;
  final AddressEntity shippingAddress;
  final String paymentMethod;
  final double subtotal;
  final double discount;
  final double shippingFee;
  final double total;

  const PlaceOrderRequested({
    required this.items,
    required this.shippingAddress,
    required this.paymentMethod,
    this.subtotal = 0,
    this.discount = 0,
    this.shippingFee = 0,
    required this.total,
  });

  @override
  List<Object?> get props => [items, shippingAddress, paymentMethod, total];
}

class LoadOrdersRequested extends OrderEvent {}

class CancelOrderRequested extends OrderEvent {
  final String orderId;
  final String? reason;

  const CancelOrderRequested({
    required this.orderId,
    this.reason,
  });

  @override
  List<Object?> get props => [orderId, reason];
}

typedef LoadOrders = LoadOrdersRequested;
typedef CreateOrder = PlaceOrderRequested;
typedef CancelOrder = CancelOrderRequested;
