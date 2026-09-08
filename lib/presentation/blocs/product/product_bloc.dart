import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/app_repository.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final AppRepository repository;

  ProductBloc({required this.repository}) : super(ProductInitial()) {
    on<LoadProductsRequested>(_onLoadProductsRequested);
    on<SearchProductsRequested>(_onSearchProductsRequested);
    on<FilterProductsByGenderRequested>(_onFilterProductsByGenderRequested);
  }

  Future<void> _onLoadProductsRequested(
    LoadProductsRequested event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());
    try {
      final products = await repository.getProducts();
      emit(ProductLoaded(
        products: products,
        filteredProducts: products,
      ));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onSearchProductsRequested(
    SearchProductsRequested event,
    Emitter<ProductState> emit,
  ) async {
    if (state is ProductLoaded) {
      final currentState = state as ProductLoaded;
      final query = event.query.toLowerCase().trim();

      final filtered = currentState.products.where((p) {
        final matchesQuery = p.title.toLowerCase().contains(query) ||
            p.category.toLowerCase().contains(query);

        final matchesGender = currentState.activeGenderFilter == 'All' ||
            p.targetGender.toLowerCase() == currentState.activeGenderFilter.toLowerCase();

        return matchesQuery && matchesGender;
      }).toList();

      emit(currentState.copyWith(
        searchQuery: event.query,
        filteredProducts: filtered,
      ));
    }
  }

  void _onFilterProductsByGenderRequested(
    FilterProductsByGenderRequested event,
    Emitter<ProductState> emit,
  ) {
    if (state is ProductLoaded) {
      final currentState = state as ProductLoaded;
      final gender = event.genderFilter;

      final filtered = currentState.products.where((p) {
        final matchesGender = gender == 'All' ||
            p.targetGender.toLowerCase() == gender.toLowerCase();

        final matchesQuery = currentState.searchQuery.isEmpty ||
            p.title.toLowerCase().contains(currentState.searchQuery.toLowerCase());

        return matchesGender && matchesQuery;
      }).toList();

      emit(currentState.copyWith(
        activeGenderFilter: gender,
        filteredProducts: filtered,
      ));
    }
  }
}
