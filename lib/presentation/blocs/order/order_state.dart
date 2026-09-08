import 'package:equatable/equatable.dart';
import '../../../domain/entities/order.dart';

abstract class OrderState extends Equatable {
  const OrderState();
  @override
  List<Object?> get props => [];
}

class OrderInitial extends OrderState {}

class OrderPlacingLoading extends OrderState {}

typedef OrderLoading = OrderPlacingLoading;

class OrderPlacedSuccess extends OrderState {
  final UserOrderEntity order;
  const OrderPlacedSuccess(this.order);

  @override
  List<Object?> get props => [order];
}

class OrderLoaded extends OrderState {
  final List<UserOrderEntity> orders;
  const OrderLoaded(this.orders);

  @override
  List<Object?> get props => [orders];
}

class OrderFailure extends OrderState {
  final String message;
  const OrderFailure(this.message);

  @override
  List<Object?> get props => [message];
}
