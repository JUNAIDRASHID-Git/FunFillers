import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../blocs/product/product_bloc.dart';
import '../blocs/product/product_event.dart';
import '../blocs/product/product_state.dart';
import '../widgets/product_card.dart';
import 'product_details_screen.dart';

class SearchCatalogScreen extends StatefulWidget {
  const SearchCatalogScreen({super.key});

  @override
  State<SearchCatalogScreen> createState() => _SearchCatalogScreenState();
}

class _SearchCatalogScreenState extends State<SearchCatalogScreen> {
  final _searchCtrl = TextEditingController();
  String _activeTab = 'Products'; // 'Products', 'Brands', 'Categories'

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
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
              // Search Input Row
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.cardBorder),
                        boxShadow: AppColors.cardShadow,
                      ),
                      child: TextField(
                        controller: _searchCtrl,
                        onChanged: (val) {
                          context.read<ProductBloc>().add(SearchProductsRequested(val));
                        },
                        style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Search teddy bear, rc car...',
                          hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
                          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
                          suffixIcon: _searchCtrl.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded, color: AppColors.textMuted),
                                  onPressed: () {
                                    _searchCtrl.clear();
                                    context.read<ProductBloc>().add(const SearchProductsRequested(''));
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Filter Sub-Tabs (Products, Brands, Categories)
              Row(
                children: ['Products', 'Brands', 'Categories'].map((tab) {
                  final isSelected = _activeTab == tab;
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: ChoiceChip(
                      label: Text(tab),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                      onSelected: (_) => setState(() => _activeTab = tab),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Product Search Results
              Expanded(
                child: BlocBuilder<ProductBloc, ProductState>(
                  builder: (context, state) {
                    if (state is ProductLoading) {
                      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                    }
                    if (state is ProductLoaded) {
                      final products = state.filteredProducts;

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
