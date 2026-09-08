import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../data/repositories/app_repository_impl.dart';
import '../../domain/entities/category.dart';
import '../blocs/product/product_bloc.dart';
import '../blocs/product/product_event.dart';
import '../widgets/category_chip.dart';

class CategoryListScreen extends StatefulWidget {
  final Function(int)? onNavigateTab;

  const CategoryListScreen({super.key, this.onNavigateTab});

  @override
  State<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  String _selectedGender = 'All';

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 800;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Categories'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () => widget.onNavigateTab?.call(2),
          ),
        ],
      ),
      body: MaxWidthContainer(
        maxWidth: 1200,
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            // Gender / Type Filter Chips (All, Boys, Girls, Educational)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  CategoryChip(
                    label: 'All',
                    isSelected: _selectedGender == 'All',
                    onTap: () {
                      setState(() => _selectedGender = 'All');
                      context.read<ProductBloc>().add(
                        const FilterProductsByGenderRequested('All'),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  CategoryChip(
                    label: 'Boys',
                    isSelected: _selectedGender == 'Boys',
                    onTap: () {
                      setState(() => _selectedGender = 'Boys');
                      context.read<ProductBloc>().add(
                        const FilterProductsByGenderRequested('Boys'),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  CategoryChip(
                    label: 'Girls',
                    isSelected: _selectedGender == 'Girls',
                    onTap: () {
                      setState(() => _selectedGender = 'Girls');
                      context.read<ProductBloc>().add(
                        const FilterProductsByGenderRequested('Girls'),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  CategoryChip(
                    label: 'Educational',
                    isSelected: _selectedGender == 'Educational',
                    onTap: () {
                      setState(() => _selectedGender = 'Educational');
                      context.read<ProductBloc>().add(
                        const FilterProductsByGenderRequested('Educational'),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Real Server Category Items Grid/List
            Expanded(
              child: FutureBuilder<List<CategoryEntity>>(
                future: context.read<AppRepositoryImpl>().getCategories(),
                builder: (ctx, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  }
                  final categories = snapshot.data!;
                  if (categories.isEmpty) {
                    return const Center(
                      child: Text(
                        'No categories available from server',
                        style: TextStyle(color: AppColors.textMuted),
                      ),
                    );
                  }

                  return isWide
                      ? GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 380,
                                mainAxisExtent: 90,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                          itemCount: categories.length,
                          itemBuilder: (ctx, idx) =>
                              _buildCategoryTile(categories[idx]),
                        )
                      : ListView.separated(
                          itemCount: categories.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 12),
                          itemBuilder: (ctx, idx) =>
                              _buildCategoryTile(categories[idx]),
                        );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTile(dynamic cat) {
    return GestureDetector(
      onTap: () {
        context.read<ProductBloc>().add(SearchProductsRequested(cat.name));
        widget.onNavigateTab?.call(2); // Jump to Search catalog
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: AppColors.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(14),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(
                  cat.iconImage,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const Icon(
                    Icons.category_rounded,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    cat.name,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${cat.itemCount} items',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.textMuted,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
