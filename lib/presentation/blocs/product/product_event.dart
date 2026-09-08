import 'package:equatable/equatable.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();
  @override
  List<Object?> get props => [];
}

class LoadProductsRequested extends ProductEvent {}

typedef LoadProducts = LoadProductsRequested;

class SearchProductsRequested extends ProductEvent {
  final String query;
  const SearchProductsRequested(this.query);

  @override
  List<Object?> get props => [query];
}

class FilterProductsByGenderRequested extends ProductEvent {
  final String genderFilter; // 'All', 'Boys', 'Girls', 'Educational'
  const FilterProductsByGenderRequested(this.genderFilter);

  @override
  List<Object?> get props => [genderFilter];
}
