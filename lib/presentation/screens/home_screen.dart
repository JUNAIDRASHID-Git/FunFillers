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
import '../widgets/location_header_widget.dart';
import '../widgets/video_background_header.dart';
import '../widgets/carousel_banner_widget.dart';
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Animated Background Header (Video + White Gradient Fade)
              VideoBackgroundHeader(
                child: MaxWidthContainer(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Top Bar: Logo on Left + Action Icons on Right
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Image.asset(
                            'assets/images/fun_fillers_font_logo.PNG',
                            height: 40,
                            fit: BoxFit.contain,
                            errorBuilder: (_, _, _) => Image.asset(
                              'assets/images/fun_fillers_logo.png',
                              height: 40,
                              fit: BoxFit.contain,
                              errorBuilder: (_, _, _) => const Icon(
                                Icons.toys_rounded,
                                color: Colors.white,
                                size: 36,
                              ),
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
                                    border: Border.all(
                                      color: AppColors.cardBorder,
                                    ),
                                    boxShadow: AppColors.cardShadow,
                                  ),
                                  child: SvgPicture.asset(
                                    'assets/icons/wishlist.svg',
                                    width: 18,
                                    height: 18,
                                    colorFilter: const ColorFilter.mode(
                                      AppColors.textPrimary,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.cardBorder,
                                  ),
                                  boxShadow: AppColors.cardShadow,
                                ),
                                child: Stack(
                                  children: [
                                    const Icon(
                                      Icons.notifications_none_rounded,
                                      color: AppColors.textPrimary,
                                      size: 18,
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
                      const SizedBox(height: 50),

                      // 2. Delivery Location Frosted Glass Pill Widget
                      const LocationHeaderWidget(),
                      const SizedBox(height: 16),

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
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),

              // Rest of Page Body
              MaxWidthContainer(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    // Hero Carousel Banner
                    CarouselBannerWidget(
                      onBannerTap: () => widget.onNavigateTab?.call(1),
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
                          final crossAxisCount =
                              Responsive.getGridCrossAxisCount(context);
                          final childAspectRatio =
                              Responsive.getGridChildAspectRatio(context);

                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
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
                  ],
                ),
              ),
            ],
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
