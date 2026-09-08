import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/app_repository.dart';
import '../../../domain/entities/product.dart';
import 'wishlist_event.dart';
import 'wishlist_state.dart';

class WishlistBloc extends Bloc<WishlistEvent, WishlistState> {
  final AppRepository? repository;

  WishlistBloc({this.repository}) : super(const WishlistState(favorites: [])) {
    on<LoadWishlist>((event, emit) async {
      if (repository != null) {
        final favs = await repository!.getWishlist();
        emit(WishlistState(favorites: favs));
      } else {
        emit(WishlistState(favorites: state.favorites));
      }
    });

    on<ToggleWishlistRequested>(_onToggleWishlistRequested);

    // Initial load
    add(LoadWishlist());
  }

  Future<void> _onToggleWishlistRequested(
    ToggleWishlistRequested event,
    Emitter<WishlistState> emit,
  ) async {
    final currentFavs = List<ProductEntity>.from(state.favorites);
    final exists = currentFavs.any((p) => p.id == event.product.id);

    if (exists) {
      currentFavs.removeWhere((p) => p.id == event.product.id);
    } else {
      currentFavs.add(event.product.copyWith(isFavorite: true));
    }

    emit(WishlistState(favorites: currentFavs));

    if (repository != null) {
      try {
        await repository!.toggleWishlist(event.product);
      } catch (_) {}
    }
  }
}
