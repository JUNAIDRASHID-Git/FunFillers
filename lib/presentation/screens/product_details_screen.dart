import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/api_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/responsive.dart';
import '../../domain/entities/product.dart';
import '../blocs/cart/cart_bloc.dart';
import '../blocs/cart/cart_event.dart';
import '../blocs/wishlist/wishlist_bloc.dart';
import '../blocs/wishlist/wishlist_event.dart';
import '../blocs/wishlist/wishlist_state.dart';
import '../blocs/product/product_bloc.dart';
import '../blocs/product/product_state.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../widgets/custom_button.dart';
import '../widgets/product_card.dart';
import 'cart_screen.dart';

class ProductDetailsScreen extends StatefulWidget {
  final ProductEntity? product;
  final String? productId;

  const ProductDetailsScreen({
    super.key,
    this.product,
    this.productId,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _selectedImageIndex = 0;
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    ProductEntity? prod = widget.product;
    final productState = context.watch<ProductBloc>().state;

    if (prod == null && widget.productId != null && productState is ProductLoaded) {
      final matches = productState.products.where((p) => p.id == widget.productId);
      if (matches.isNotEmpty) {
        prod = matches.first;
      }
    }

    if (prod == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                context.go('/home');
              }
            },
          ),
          title: const Text('Product Details', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final productEntity = prod;
    final images = productEntity.galleryImages.isNotEmpty ? productEntity.galleryImages : [productEntity.mainImage];
    final isWide = MediaQuery.sizeOf(context).width >= 800;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              context.go('/home');
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: AppColors.textPrimary, size: 22),
            onPressed: () => _shareProduct(context, productEntity),
          ),
          BlocBuilder<WishlistBloc, WishlistState>(
            builder: (context, state) {
              final isFav = state.isFavorite(productEntity.id);
              return IconButton(
                icon: SvgPicture.asset(
                  isFav ? 'assets/icons/wishlist_active.svg' : 'assets/icons/wishlist.svg',
                  width: 22,
                  height: 22,
                  colorFilter: ColorFilter.mode(
                    isFav ? AppColors.heartRed : AppColors.textPrimary,
                    BlendMode.srcIn,
                  ),
                ),
                onPressed: () {
                  context.read<WishlistBloc>().add(ToggleWishlistRequested(productEntity));
                },
              );
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: isWide
            ? MaxWidthContainer(
                maxWidth: 1100,
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left Column: Image Showcase & Thumbnails
                          Expanded(
                            flex: 5,
                            child: Column(
                              children: [
                                Container(
                                  width: double.infinity,
                                  height: 380,
                                  decoration: const BoxDecoration(
                                    color: Colors.transparent,
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(24),
                                    child: Image.network(
                                      images[_selectedImageIndex],
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, error, stackTrace) =>
                                          const Icon(Icons.smart_toy_rounded, size: 80, color: AppColors.primary),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                if (images.length > 1)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(images.length, (idx) {
                                      final isSelected = _selectedImageIndex == idx;
                                      return GestureDetector(
                                        onTap: () => setState(() => _selectedImageIndex = idx),
                                        child: Container(
                                          margin: const EdgeInsets.symmetric(horizontal: 6),
                                          width: 60,
                                          height: 60,
                                          decoration: BoxDecoration(
                                            color: Colors.transparent,
                                            borderRadius: BorderRadius.circular(14),
                                            border: isSelected ? Border.all(color: AppColors.primary, width: 2.5) : null,
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(12),
                                            child: Image.network(images[idx], fit: BoxFit.cover),
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 40),

                          // Right Column: Details, Rating, Description & Purchase Stepper
                          Expanded(
                            flex: 6,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildTitleAndRating(productEntity),
                                const SizedBox(height: 18),
                                _buildPriceSection(productEntity),
                                const SizedBox(height: 20),
                                const Text('Description', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
                                const SizedBox(height: 8),
                                Text(productEntity.description, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.5)),
                                const SizedBox(height: 32),

                                // Purchase Stepper Row
                                Row(
                                  children: [
                                    _buildQuantityStepper(),
                                    const SizedBox(width: 16),
                                    Expanded(child: _buildAddToCartButton(context, productEntity)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      _buildRecommendedProductsSection(context, productEntity),
                    ],
                  ),
                ),
              )
            : Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            height: 240,
                            decoration: const BoxDecoration(
                              color: Colors.transparent,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: Image.network(
                                images[_selectedImageIndex],
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.smart_toy_rounded, size: 80, color: AppColors.primary),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          if (images.length > 1)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(images.length, (idx) {
                                final isSelected = _selectedImageIndex == idx;
                                return GestureDetector(
                                  onTap: () => setState(() => _selectedImageIndex = idx),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 4),
                                    width: 52,
                                    height: 52,
                                    decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      borderRadius: BorderRadius.circular(12),
                                      border: isSelected ? Border.all(color: AppColors.primary, width: 2) : null,
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(images[idx], fit: BoxFit.cover),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          const SizedBox(height: 20),
                          _buildTitleAndRating(productEntity),
                          const SizedBox(height: 16),
                          _buildPriceSection(productEntity),
                          const SizedBox(height: 18),
                          const Text('Description', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 15)),
                          const SizedBox(height: 6),
                          Text(productEntity.description, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.4)),
                          _buildRecommendedProductsSection(context, productEntity),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Toolbar for Mobile
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                      border: Border(top: BorderSide(color: AppColors.cardBorder)),
                    ),
                    child: Row(
                      children: [
                        _buildQuantityStepper(),
                        const SizedBox(width: 14),
                        Expanded(child: _buildAddToCartButton(context, productEntity)),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildTitleAndRating(ProductEntity prod) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          prod.title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Soft & Cuddly • Category: ${prod.category}',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.accentYellow,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star_rounded, color: AppColors.starGold, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${prod.rating}',
                    style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '(${prod.reviewCount} reviews)',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            const Spacer(),
            InkWell(
              onTap: () => _shareProduct(context, prod),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.share_outlined, size: 14, color: AppColors.textPrimary),
                    SizedBox(width: 4),
                    Text(
                      'Share',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _shareProduct(BuildContext context, ProductEntity prod) {
    const backendBaseUrl = ApiConstants.serverUrl;
    final shareUrl = '$backendBaseUrl/share/product/${prod.id}';
    final shareText = 'Check out ${prod.title} on Funfillers for ${CurrencyFormatter.format(prod.price)}!\n$shareUrl';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Share Product',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          prod.mainImage,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const Icon(Icons.smart_toy_rounded, size: 30, color: AppColors.primary),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              prod.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              CurrencyFormatter.format(prod.price),
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.primary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.softPink,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.share_rounded, color: AppColors.primary, size: 22),
                  ),
                  title: const Text('Share via App', style: TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: const Text('Send using system share dialog', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  onTap: () {
                    Navigator.pop(ctx);
                    // ignore: deprecated_member_use
                    Share.share(shareText, subject: prod.title);
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.accentYellow.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.copy_rounded, color: AppColors.textPrimary, size: 22),
                  ),
                  title: const Text('Copy Product Link', style: TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: const Text('Copy OG preview link to clipboard', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  onTap: () {
                    Navigator.pop(ctx);
                    Clipboard.setData(ClipboardData(text: shareUrl));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Copied link: $shareUrl'),
                        backgroundColor: AppColors.primary,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPriceSection(ProductEntity prod) {
    final double? savings = (prod.originalPrice != null && prod.originalPrice! > prod.price)
        ? (prod.originalPrice! - prod.price)
        : null;

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 10,
      runSpacing: 8,
      children: [
        Text(
          CurrencyFormatter.format(prod.price),
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
        if (prod.originalPrice != null && prod.originalPrice! > prod.price)
          Text(
            CurrencyFormatter.format(prod.originalPrice!),
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 14,
              decoration: TextDecoration.lineThrough,
            ),
          ),
        if (prod.discountPercent > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.discountRed.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '${prod.discountPercent}% OFF',
              style: const TextStyle(
                color: AppColors.discountRed,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
        if (savings != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.successGreen.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.successGreen.withValues(alpha: 0.3)),
            ),
            child: Text(
              'You Save ${CurrencyFormatter.format(savings)}',
              style: const TextStyle(
                color: AppColors.successGreen,
                fontWeight: FontWeight.w900,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildQuantityStepper() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.remove_rounded, size: 18, color: AppColors.textPrimary),
            onPressed: () {
              if (_quantity > 1) setState(() => _quantity--);
            },
          ),
          Text(
            '$_quantity',
            style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 15),
          ),
          IconButton(
            icon: const Icon(Icons.add_rounded, size: 18, color: AppColors.textPrimary),
            onPressed: () => setState(() => _quantity++),
          ),
        ],
      ),
    );
  }

  Widget _buildAddToCartButton(BuildContext context, ProductEntity prod) {
    return CustomButton(
      text: 'Add to Cart',
      icon: Icons.shopping_bag_outlined,
      onPressed: () {
        context.read<CartBloc>().add(AddToCartRequested(product: prod, quantity: _quantity));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${prod.title} added to your cart!'),
            backgroundColor: AppColors.primary,
            action: SnackBarAction(
              label: 'View Cart',
              textColor: Colors.white,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CartScreen()),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecommendedProductsSection(BuildContext context, ProductEntity currentProduct) {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        if (state is! ProductLoaded) {
          return const SizedBox.shrink();
        }

        // Filter products in the same category, excluding the current product
        List<ProductEntity> recommended = state.products
            .where((p) =>
                p.id != currentProduct.id &&
                p.category.toLowerCase().trim() == currentProduct.category.toLowerCase().trim())
            .toList();

        // Fallback: if not enough in same category, show other products (excluding current)
        if (recommended.isEmpty) {
          recommended = state.products.where((p) => p.id != currentProduct.id).toList();
        }

        if (recommended.isEmpty) {
          return const SizedBox.shrink();
        }

        final categoryTitle = currentProduct.category.isNotEmpty ? currentProduct.category : 'For You';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recommended Products',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    letterSpacing: -0.3,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.softPink,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    categoryTitle,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 275,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: recommended.length,
                separatorBuilder: (_, _) => const SizedBox(width: 14),
                itemBuilder: (ctx, index) {
                  final item = recommended[index];
                  return SizedBox(
                    width: 185,
                    child: ProductCard(
                      product: item,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProductDetailsScreen(product: item),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
