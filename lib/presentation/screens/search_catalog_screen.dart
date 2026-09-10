import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../domain/entities/product.dart';
import '../blocs/product/product_bloc.dart';
import '../blocs/product/product_event.dart';
import '../blocs/product/product_state.dart';
import '../widgets/product_card.dart';
import '../widgets/skeleton_widget.dart';
import '../widgets/app_search_bar_widget.dart';
import 'product_details_screen.dart';

class SearchCatalogScreen extends StatefulWidget {
  const SearchCatalogScreen({super.key});

  @override
  State<SearchCatalogScreen> createState() => _SearchCatalogScreenState();
}

class _SearchCatalogScreenState extends State<SearchCatalogScreen> {
  final _searchCtrl = TextEditingController();
  String _sortBy = 'default'; // 'default', 'low_to_high', 'high_to_low', 'discount'

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Widget _buildSortChip(String label, String value, IconData icon) {
    final isSelected = _sortBy == value;
    return ChoiceChip(
      avatar: Icon(
        icon,
        size: 15,
        color: isSelected ? Colors.white : AppColors.primary,
      ),
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.primary,
      backgroundColor: Colors.white,
      side: BorderSide(
        color: isSelected ? AppColors.primary : const Color(0xFFCBD5E1),
        width: 1.2,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : const Color(0xFF334155),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
        fontSize: 13,
      ),
      onSelected: (_) {
        setState(() {
          _sortBy = value;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: MaxWidthContainer(
          maxWidth: 1240,
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              // Search Input Row with Back Button using reusable AppSearchBarWidget
              AppSearchBarWidget(
                readOnly: false,
                showBackButton: true,
                controller: _searchCtrl,
                onChanged: (val) {
                  setState(() {});
                  context.read<ProductBloc>().add(SearchProductsRequested(val));
                },
                onClear: () {
                  _searchCtrl.clear();
                  setState(() {});
                  context.read<ProductBloc>().add(const SearchProductsRequested(''));
                },
                onBackTap: () => Navigator.maybePop(context),
              ),
              const SizedBox(height: 14),

              // Sorting Filters Row (Price: Low to High, High to Low, Discount)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildSortChip('Default', 'default', Icons.swap_vert_rounded),
                    const SizedBox(width: 8),
                    _buildSortChip('Price: Low to High', 'low_to_high', Icons.arrow_upward_rounded),
                    const SizedBox(width: 8),
                    _buildSortChip('Price: High to Low', 'high_to_low', Icons.arrow_downward_rounded),
                    const SizedBox(width: 8),
                    _buildSortChip('Top Discount', 'discount', Icons.local_offer_rounded),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Product Search Results
              Expanded(
                child: BlocBuilder<ProductBloc, ProductState>(
                  builder: (context, state) {
                    if (state is ProductLoading) {
                      return const ProductGridSkeleton();
                    }
                    if (state is ProductLoaded) {
                      final products = List<ProductEntity>.from(state.filteredProducts);

                      // Apply sorting filter
                      if (_sortBy == 'low_to_high') {
                        products.sort((a, b) => a.price.compareTo(b.price));
                      } else if (_sortBy == 'high_to_low') {
                        products.sort((a, b) => b.price.compareTo(a.price));
                      } else if (_sortBy == 'discount') {
                        products.sort((a, b) => b.discountPercent.compareTo(a.discountPercent));
                      }

                      if (products.isEmpty) {
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off_rounded, size: 48, color: AppColors.textMuted),
                              SizedBox(height: 12),
                              Text('No matching toys found', style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
                            ],
                          ),
                        );
                      }

                      final crossAxisCount = Responsive.getGridCrossAxisCount(context);
                      final childAspectRatio = Responsive.getGridChildAspectRatio(context);

                      return GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          childAspectRatio: childAspectRatio,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                        ),
                        itemCount: products.length,
                        itemBuilder: (ctx, idx) {
                          final product = products[idx];
                          return ProductCard(
                            product: product,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ProductDetailsScreen(product: product),
                                ),
                              );
                            },
                          );
                        },
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
