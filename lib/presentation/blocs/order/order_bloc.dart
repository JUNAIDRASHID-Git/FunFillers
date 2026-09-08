import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/app_repository.dart';
import 'order_event.dart';
import 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final AppRepository repository;

  OrderBloc({required this.repository}) : super(OrderInitial()) {
    on<PlaceOrderRequested>(_onPlaceOrderRequested);
    on<LoadOrdersRequested>(_onLoadOrdersRequested);
  }

  Future<void> _onPlaceOrderRequested(
    PlaceOrderRequested event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderPlacingLoading());
    try {
      final newOrder = await repository.createOrder(
        event.items,
        event.shippingAddress,
        event.paymentMethod,
        event.total,
      );
      emit(OrderPlacedSuccess(newOrder));
    } catch (e) {
      emit(OrderFailure(e.toString()));
    }
  }

  Future<void> _onLoadOrdersRequested(
    LoadOrdersRequested event,
    Emitter<OrderState> emit,
  ) async {
    try {
      final orders = await repository.getOrders();
      emit(OrderLoaded(orders));
    } catch (e) {
      emit(OrderFailure(e.toString()));
    }
  }
}
