import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../data/repositories/app_repository_impl.dart';
import '../../domain/entities/category.dart';
import '../widgets/skeleton_widget.dart';
import '../widgets/app_search_bar_widget.dart';
import 'search_catalog_screen.dart';
import 'category_products_screen.dart';

class CategoryListScreen extends StatefulWidget {
  final Function(int)? onNavigateTab;

  const CategoryListScreen({super.key, this.onNavigateTab});

  @override
  State<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  String? _expandedCategoryId;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 800;
    final crossAxisCount = isWide ? 6 : 3;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: MaxWidthContainer(
          maxWidth: 1200,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: FutureBuilder<List<CategoryEntity>>(
            future: context.read<AppRepositoryImpl>().getCategories(),
            builder: (ctx, snapshot) {
              if (!snapshot.hasData) {
                return const ProductGridSkeleton(itemCount: 9, aspectRatio: 0.85);
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

              // Group categories into rows based on responsive column count
              final rows = <List<CategoryEntity>>[];
              for (int i = 0; i < categories.length; i += crossAxisCount) {
                final end = (i + crossAxisCount < categories.length) ? i + crossAxisCount : categories.length;
                rows.add(categories.sublist(i, end));
              }

              return ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: rows.length + 1, // +1 for search bar header
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _buildSearchBar();
                  }

                  final rowIndex = index - 1;
                  final rowCategories = rows[rowIndex];

                  // Check if any category in this row is currently expanded
                  CategoryEntity? expandedCatInRow;
                  for (final cat in rowCategories) {
                    if (cat.id == _expandedCategoryId) {
                      expandedCatInRow = cat;
                      break;
                    }
                  }

                  return Column(
                    key: ValueKey('row_$rowIndex'),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Row of Category Cards
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(crossAxisCount, (colIndex) {
                          if (colIndex < rowCategories.length) {
                            final cat = rowCategories[colIndex];
                            final isExpanded = cat.id == _expandedCategoryId;
                            return Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  right: colIndex < crossAxisCount - 1 ? 12.0 : 0.0,
                                ),
                                child: _buildCategoryGridCard(cat, isExpanded),
                              ),
                            );
                          } else {
                            return const Expanded(child: SizedBox());
                          }
                        }),
                      ),
                      const SizedBox(height: 12),

                      // Smooth Inline Expanded Section Directly Below This Row (top-center butter smooth transition)
                      AnimatedSize(
                        duration: const Duration(milliseconds: 380),
                        curve: Curves.fastOutSlowIn,
                        alignment: Alignment.topCenter,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 320),
                          switchInCurve: Curves.easeOutCubic,
                          switchOutCurve: Curves.easeInCubic,
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                          child: expandedCatInRow != null
                              ? Container(
                                  key: ValueKey('expanded_${expandedCatInRow.id}'),
                                  margin: const EdgeInsets.only(bottom: 16, top: 4),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(22),
                                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1.2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary.withValues(alpha: 0.08),
                                        blurRadius: 16,
                                        offset: const Offset(0, 4),
                                      )
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Row Header
                                      Row(
                                        children: [
                                          Container(
                                            width: 36,
                                            height: 36,
                                            padding: const EdgeInsets.all(5),
                                            decoration: BoxDecoration(
                                              color: AppColors.primary.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(6),
                                              child: Image.network(
                                                expandedCatInRow.iconImage,
                                                fit: BoxFit.cover,
                                                errorBuilder: (c, e, s) => const Icon(Icons.category_rounded, color: AppColors.primary, size: 18),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              '${expandedCatInRow.name} Sub-Categories',
                                              style: const TextStyle(
                                                color: Color(0xFF0F172A),
                                                fontSize: 15,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                          ),
                                          TextButton.icon(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => CategoryProductsScreen(
                                                    title: expandedCatInRow!.name,
                                                  ),
                                                ),
                                              );
                                            },
                                            icon: const Text('View All', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primary)),
                                            label: const Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.primary),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),

                                      // Sub-Categories Horizontal Scroll View
                                      expandedCatInRow.subCategories.isNotEmpty
                                          ? SizedBox(
                                              height: 135,
                                              child: ListView.separated(
                                                scrollDirection: Axis.horizontal,
                                                physics: const BouncingScrollPhysics(),
                                                itemCount: expandedCatInRow.subCategories.length,
                                                separatorBuilder: (c, i) => const SizedBox(width: 12),
                                                itemBuilder: (c, i) => _buildSubCategoryCard(expandedCatInRow!.subCategories[i]),
                                              ),
                                            )
                                          : Container(
                                              padding: const EdgeInsets.symmetric(vertical: 14),
                                              child: Row(
                                                children: [
                                                  const Icon(Icons.info_outline_rounded, color: AppColors.textMuted, size: 18),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      'Explore all products in ${expandedCatInRow.name}.',
                                                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                    ],
                                  ),
                                )
                              : const SizedBox.shrink(key: ValueKey('expanded_none')),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  // Search Bar Header
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20, top: 4),
      child: AppSearchBarWidget(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SearchCatalogScreen()),
        ),
      ),
    );
  }

  // Vertical Grid Main Category Card Item (matching user's 3-card per row screenshot design)
  Widget _buildCategoryGridCard(CategoryEntity cat, bool isExpanded) {
    return RepaintBoundary(
      child: GestureDetector(
        onTap: () {
          setState(() {
            if (_expandedCategoryId == cat.id) {
              _expandedCategoryId = null; // Toggle collapse if clicked again
            } else {
              _expandedCategoryId = cat.id; // Expand subcategories below row
            }
          });
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Image Box Container (matching user screenshot)
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              height: 125,
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isExpanded ? const Color(0xFFE2E8F0) : const Color(0xFFEFF3F8),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isExpanded ? AppColors.primary : Colors.transparent,
                  width: isExpanded ? 2.5 : 0,
                ),
                boxShadow: isExpanded
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        )
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        )
                      ],
              ),
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    cat.iconImage,
                    fit: BoxFit.contain,
                    errorBuilder: (c, e, s) => const Icon(
                      Icons.toys_rounded,
                      size: 40,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Title Label Below Image Box (matching user screenshot)
            Padding(
              padding: const EdgeInsets.only(left: 2),
              child: Text(
                cat.name,
                style: TextStyle(
                  color: isExpanded ? AppColors.primary : const Color(0xFF0F172A),
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Horizontal Sub-Category Card Item
  Widget _buildSubCategoryCard(SubCategoryEntity sub) {
    return RepaintBoundary(
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CategoryProductsScreen(
                  title: sub.name,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(18),
          child: Container(
            width: 155,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          sub.iconImage,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => const Icon(Icons.apps_rounded, color: AppColors.primary, size: 20),
                        ),
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  sub.name,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (sub.description.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    sub.description,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
