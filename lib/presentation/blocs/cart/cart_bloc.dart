import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../domain/repositories/app_repository.dart';
import '../../../domain/entities/cart_item.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  static const String _cartStorageKey = 'funfillers_guest_cart';
  final AppRepository? repository;

  CartBloc({this.repository}) : super(const CartState(items: [])) {
    on<LoadCart>(_onLoadCart);
    on<AddToCartRequested>(_onAddToCartRequested);
    on<RemoveFromCartRequested>(_onRemoveFromCartRequested);
    on<UpdateCartQuantityRequested>(_onUpdateCartQuantityRequested);
    on<ToggleCartItemSelectionRequested>(_onToggleCartItemSelectionRequested);
    on<ToggleSelectAllCartItemsRequested>(_onToggleSelectAllCartItemsRequested);
    on<ClearCartRequested>(_onClearCartRequested);
  }

  Future<void> _saveCartToStorage(List<CartItemEntity> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJsonList = items.map((item) => item.toJson()).toList();
      await prefs.setString(_cartStorageKey, jsonEncode(cartJsonList));
    } catch (_) {}
  }

  Future<void> _onLoadCart(LoadCart event, Emitter<CartState> emit) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedCart = prefs.getString(_cartStorageKey);
      if (storedCart != null && storedCart.isNotEmpty) {
        final List dynamicList = jsonDecode(storedCart);
        final loadedItems = dynamicList
            .map((item) => CartItemEntity.fromJson(item as Map<String, dynamic>))
            .where((item) {
              final id = item.product.id.toLowerCase();
              return !id.startsWith('prod_teddy') &&
                     !id.startsWith('prod_rc') &&
                     !id.startsWith('prod_building') &&
                     !id.startsWith('prod_doctor');
            })
            .toList();
        emit(state.copyWith(items: loadedItems));
        _saveCartToStorage(loadedItems);
        return;
      }
    } catch (_) {}

    // Empty cart for fresh start
    emit(state.copyWith(items: []));
    _saveCartToStorage([]);
  }

  void _onAddToCartRequested(
    AddToCartRequested event,
    Emitter<CartState> emit,
  ) {
    final currentItems = List<CartItemEntity>.from(state.items);
    final idx = currentItems.indexWhere((i) => i.product.id == event.product.id);

    if (idx != -1) {
      final item = currentItems[idx];
      currentItems[idx] = item.copyWith(quantity: item.quantity + event.quantity);
    } else {
      currentItems.add(CartItemEntity(product: event.product, quantity: event.quantity, isSelected: true));
    }

    emit(state.copyWith(items: currentItems));
    _saveCartToStorage(currentItems);
  }

  void _onRemoveFromCartRequested(
    RemoveFromCartRequested event,
    Emitter<CartState> emit,
  ) {
    final currentItems = List<CartItemEntity>.from(state.items);
    currentItems.removeWhere((i) => i.product.id == event.productId);
    emit(state.copyWith(items: currentItems));
    _saveCartToStorage(currentItems);
  }

  void _onUpdateCartQuantityRequested(
    UpdateCartQuantityRequested event,
    Emitter<CartState> emit,
  ) {
    if (event.quantity <= 0) {
      add(RemoveFromCartRequested(event.productId));
      return;
    }
    final currentItems = List<CartItemEntity>.from(state.items);
    final idx = currentItems.indexWhere((i) => i.product.id == event.productId);
    if (idx != -1) {
      currentItems[idx] = currentItems[idx].copyWith(quantity: event.quantity);
      emit(state.copyWith(items: currentItems));
      _saveCartToStorage(currentItems);
    }
  }

  void _onToggleCartItemSelectionRequested(
    ToggleCartItemSelectionRequested event,
    Emitter<CartState> emit,
  ) {
    final currentItems = List<CartItemEntity>.from(state.items);
    final idx = currentItems.indexWhere((i) => i.product.id == event.productId);
    if (idx != -1) {
      final item = currentItems[idx];
      currentItems[idx] = item.copyWith(isSelected: !item.isSelected);
      emit(state.copyWith(items: currentItems));
      _saveCartToStorage(currentItems);
    }
  }

  void _onToggleSelectAllCartItemsRequested(
    ToggleSelectAllCartItemsRequested event,
    Emitter<CartState> emit,
  ) {
    final currentItems = state.items.map((i) => i.copyWith(isSelected: event.selectAll)).toList();
    emit(state.copyWith(items: currentItems));
    _saveCartToStorage(currentItems);
  }

  void _onClearCartRequested(
    ClearCartRequested event,
    Emitter<CartState> emit,
  ) {
    emit(state.copyWith(items: []));
    _saveCartToStorage([]);
  }
}
