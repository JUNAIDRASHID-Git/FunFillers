import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../domain/entities/product.dart';
import '../blocs/product/product_bloc.dart';
import '../blocs/product/product_state.dart';
import '../widgets/product_card.dart';
import '../widgets/skeleton_widget.dart';
import 'product_details_screen.dart';

class CategoryProductsScreen extends StatefulWidget {
  final String title;
  final String? parentCategoryName;

  const CategoryProductsScreen({
    super.key,
    required this.title,
    this.parentCategoryName,
  });

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  String _sortBy = 'default'; // 'default', 'low_to_high', 'high_to_low', 'discount'

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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppColors.textPrimary,
            size: 22,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (widget.parentCategoryName != null)
              Text(
                'Category: ${widget.parentCategoryName}',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: MaxWidthContainer(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              // Sorting Options Row
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
              const SizedBox(height: 16),

              // Product Grid
              Expanded(
                child: BlocBuilder<ProductBloc, ProductState>(
                  builder: (context, state) {
                    if (state is ProductLoading) {
                      return const ProductGridSkeleton();
                    }

                    if (state is ProductLoaded) {
                      final term = widget.title.toLowerCase().trim();
                      final parentTerm = (widget.parentCategoryName ?? '').toLowerCase().trim();
                      final words = term.split(RegExp(r'\s+')).where((w) => w.length > 2).toList();

                      // Filter products matching subcategory, title, category, or subcategory keywords strictly
                      final matched = state.products.where((p) {
                        final catLower = p.category.toLowerCase().trim();
                        final catIdLower = p.categoryId.toLowerCase().trim();
                        final subCatLower = p.subCategory.toLowerCase().trim();
                        final subCatIdLower = p.subCategoryId.toLowerCase().trim();
                        final titleLower = p.title.toLowerCase().trim();
                        final descLower = p.description.toLowerCase().trim();

                        // 1. Direct subcategory field match
                        if (subCatLower.isNotEmpty && (subCatLower == term || subCatLower.contains(term) || term.contains(subCatLower))) {
                          return true;
                        }
                        if (subCatIdLower.isNotEmpty && (subCatIdLower == term || subCatIdLower.contains(term))) {
                          return true;
                        }

                        // 2. Direct category field match
                        if (catLower.isNotEmpty && (catLower == term || catLower.contains(term) || term.contains(catLower))) {
                          return true;
                        }
                        if (catIdLower.isNotEmpty && (catIdLower == term || catIdLower.contains(term))) {
                          return true;
                        }
                        if (parentTerm.isNotEmpty && (catLower.contains(parentTerm) || catIdLower.contains(parentTerm))) {
                          if (subCatLower.contains(term) || titleLower.contains(term)) {
                            return true;
                          }
                        }

                        // 3. Title or description match
                        if (titleLower.contains(term) || descLower.contains(term)) {
                          return true;
                        }

                        // 4. Word-by-word matching
                        if (words.isNotEmpty) {
                          for (final w in words) {
                            if (subCatLower.contains(w) || catLower.contains(w) || titleLower.contains(w) || descLower.contains(w)) {
                              return true;
                            }
                          }
                        }

                        return false;
                      }).toList();

                      final products = List<ProductEntity>.from(matched);

                      // Apply Sorting
                      if (_sortBy == 'low_to_high') {
                        products.sort((a, b) => a.price.compareTo(b.price));
                      } else if (_sortBy == 'high_to_low') {
                        products.sort((a, b) => b.price.compareTo(a.price));
                      } else if (_sortBy == 'discount') {
                        products.sort((a, b) => b.discountPercent.compareTo(a.discountPercent));
                      }

                      if (products.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: const BoxDecoration(
                                  color: AppColors.inputBackground,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.inventory_2_outlined,
                                  color: AppColors.textMuted,
                                  size: 32,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                'No products found for "${widget.title}"',
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      final crossAxisCount = Responsive.getGridCrossAxisCount(context);
                      final childAspectRatio = Responsive.getGridChildAspectRatio(context);

                      return GridView.builder(
                        physics: const BouncingScrollPhysics(),
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
                                  builder: (_) => ProductDetailsScreen(
                                    product: product,
                                  ),
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
