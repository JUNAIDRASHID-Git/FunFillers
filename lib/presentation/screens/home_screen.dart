import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../data/repositories/app_repository_impl.dart';
import '../../domain/entities/category.dart';
import '../blocs/product/product_bloc.dart';
import '../blocs/product/product_event.dart';
import '../blocs/product/product_state.dart';
import '../widgets/product_card.dart';
import 'product_details_screen.dart';
import 'wishlist_screen.dart';

class HomeScreen extends StatefulWidget {
  final Function(int)? onNavigateTab;

  const HomeScreen({super.key, this.onNavigateTab});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(LoadProductsRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: MaxWidthContainer(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Greeting Header Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Hi, Players',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              SizedBox(width: 4),
                              Text('🥳', style: TextStyle(fontSize: 18)),
                            ],
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Find the perfect toy for your little one',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const WishlistScreen(),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.cardBorder),
                              boxShadow: AppColors.cardShadow,
                            ),
                            child: SvgPicture.asset(
                              'assets/icons/wishlist.svg',
                              width: 20,
                              height: 20,
                              colorFilter: const ColorFilter.mode(
                                AppColors.textPrimary,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.cardBorder),
                            boxShadow: AppColors.cardShadow,
                          ),
                          child: Stack(
                            children: [
                              const Icon(
                                Icons.notifications_none_rounded,
                                color: AppColors.textPrimary,
                                size: 20,
                              ),
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppColors.discountRed,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Search Bar Button
                GestureDetector(
                  onTap: () =>
                      widget.onNavigateTab?.call(2), // Jump to Search tab
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.cardBorder),
                      boxShadow: AppColors.cardShadow,
                    ),
                    child: Row(
                      children: const [
                        Icon(
                          Icons.search_rounded,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Search for toys, brands...',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.tune_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Hero Banner: "Play Learn Grow"
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.accentYellow, Color(0xFFFEF9C3)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Play\nLearn\nGrow',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Best Toys for a Brighter Tomorrow',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 14),
                            ElevatedButton(
                              onPressed: () => widget.onNavigateTab?.call(1),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Shop Now',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          'https://images.unsplash.com/photo-1587654780291-39c9404d746b?auto=format&fit=crop&w=300&q=80',
                          width: 110,
                          height: 110,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const Icon(
                            Icons.smart_toy_rounded,
                            size: 64,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Category Pills Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Categories',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () => widget.onNavigateTab?.call(1),
                      child: const Text(
                        'See All',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                FutureBuilder<List<CategoryEntity>>(
                  future: context.read<AppRepositoryImpl>().getCategories(),
                  builder: (ctx, snapshot) {
                    if (!snapshot.hasData) {
                      return const SizedBox(
                        height: 70,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                            strokeWidth: 2,
                          ),
                        ),
                      );
                    }
                    final categories = snapshot.data!;
                    final colors = [
                      AppColors.accentBlue,
                      AppColors.accentPink,
                      AppColors.accentPurple,
                      AppColors.accentGreen,
                      AppColors.accentYellow,
                    ];

                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(categories.length, (idx) {
                          final cat = categories[idx];
                          final bg = colors[idx % colors.length];
                          return _buildCategoryCircle(cat, bg);
                        }),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Featured Products Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Featured Products',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () => widget.onNavigateTab?.call(2),
                      child: const Text(
                        'See All',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Responsive Featured Products Grid
                BlocBuilder<ProductBloc, ProductState>(
                  builder: (context, state) {
                    if (state is ProductLoading) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        ),
                      );
                    }
                    if (state is ProductLoaded) {
                      final featured = state.products;
                      final crossAxisCount = Responsive.getGridCrossAxisCount(
                        context,
                      );
                      final childAspectRatio =
                          Responsive.getGridChildAspectRatio(context);

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          childAspectRatio: childAspectRatio,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                        ),
                        itemCount: featured.length,
                        itemBuilder: (ctx, idx) {
                          final product = featured[idx];
                          return ProductCard(
                            product: product,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ProductDetailsScreen(product: product),
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCircle(CategoryEntity cat, Color bg) {
    final hasImg =
        cat.iconImage.startsWith('http://') ||
        cat.iconImage.startsWith('https://');

    return GestureDetector(
      onTap: () {
        context.read<ProductBloc>().add(SearchProductsRequested(cat.name));
        widget.onNavigateTab?.call(2);
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 14),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: bg,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.cardBorder, width: 1.5),
                boxShadow: AppColors.cardShadow,
              ),
              clipBehavior: Clip.antiAlias,
              child: hasImg
                  ? Image.network(
                      cat.iconImage,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.category_rounded,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    )
                  : const Icon(
                      Icons.category_rounded,
                      color: AppColors.primary,
                      size: 24,
                    ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: 70,
              child: Text(
                cat.name,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
