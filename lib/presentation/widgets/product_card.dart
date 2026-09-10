import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../domain/entities/product.dart';
import '../blocs/cart/cart_bloc.dart';
import '../blocs/cart/cart_event.dart';
import '../blocs/wishlist/wishlist_bloc.dart';
import '../blocs/wishlist/wishlist_event.dart';
import '../blocs/wishlist/wishlist_state.dart';

class ProductCard extends StatelessWidget {
  final ProductEntity product;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.cardBorder),
            boxShadow: AppColors.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image Container with Badges & Heart Icon
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(19)),
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(19)),
                        child: Image.network(
                          product.mainImage,
                          fit: BoxFit.cover,
                          cacheWidth: 600,
                          filterQuality: FilterQuality.medium,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: AppColors.accentBlue,
                            child: const Icon(Icons.smart_toy_rounded, color: AppColors.primary, size: 44),
                          ),
                        ),
                      ),
                    ),

                  // Discount Badge (e.g. 33% OFF) or Out of Stock Badge
                  if (product.stock <= 0)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.discountRed,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'OUT OF STOCK',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                  else if (product.discountPercent > 0)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.discountRed,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${product.discountPercent}% OFF',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                  // Wishlist Heart Icon
                  Positioned(
                    top: 8,
                    right: 8,
                    child: BlocBuilder<WishlistBloc, WishlistState>(
                      builder: (context, state) {
                        final isFav = state.isFavorite(product.id);
                        return GestureDetector(
                          onTap: () {
                            context.read<WishlistBloc>().add(ToggleWishlistRequested(product));
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          child: SvgPicture.asset(
                            isFav ? 'assets/icons/wishlist_active.svg' : 'assets/icons/wishlist.svg',
                            width: 18,
                            height: 18,
                            colorFilter: ColorFilter.mode(
                              isFav ? AppColors.heartRed : AppColors.textSecondary,
                              BlendMode.srcIn,
                            ),
                          ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Product Details Footer
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          product.title,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, color: AppColors.starGold, size: 14),
                          const SizedBox(width: 2),
                          Text(
                            '${product.rating}',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            CurrencyFormatter.format(product.price),
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (product.originalPrice != null && product.originalPrice! > product.price) ...[
                            Text(
                              CurrencyFormatter.format(product.originalPrice!),
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 11,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            Text(
                              'Save ${CurrencyFormatter.format(product.originalPrice! - product.price)}',
                              style: const TextStyle(
                                color: AppColors.successGreen,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ],
                      ),

                      // Add to Cart Button
                      GestureDetector(
                        onTap: () {
                          if (product.stock <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Sorry, ${product.title} is currently out of stock.'),
                                backgroundColor: AppColors.discountRed,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                            return;
                          }
                          context.read<CartBloc>().add(AddToCartRequested(product: product));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${product.title} added to cart!'),
                              backgroundColor: AppColors.primary,
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: product.stock <= 0 ? AppColors.textMuted : AppColors.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            product.stock <= 0 ? Icons.block_rounded : Icons.shopping_bag_outlined,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
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
}
