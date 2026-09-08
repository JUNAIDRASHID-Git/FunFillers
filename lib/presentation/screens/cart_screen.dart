import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/responsive.dart';
import '../blocs/cart/cart_bloc.dart';
import '../blocs/cart/cart_event.dart';
import '../blocs/cart/cart_state.dart';
import '../widgets/custom_button.dart';
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 900;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: BlocBuilder<CartBloc, CartState>(
          builder: (context, state) {
            return Text(state.items.isEmpty ? 'My Cart' : 'My Cart (${state.items.length})');
          },
        ),
      ),
      body: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.shopping_bag_outlined, size: 64, color: AppColors.textMuted),
                  SizedBox(height: 14),
                  Text('Your cart is empty', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 6),
                  Text('Explore toys and add your favorites to cart!', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                ],
              ),
            );
          }

          if (isWide) {
            return MaxWidthContainer(
              maxWidth: 1200,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Side (65% width): Cart Items List
                  Expanded(
                    flex: 65,
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: state.items.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (ctx, idx) => _buildCartItemTile(context, state.items[idx]),
                    ),
                  ),

                  const SizedBox(width: 32),

                  // Right Side: Price Details
                  SizedBox(
                    width: 380,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.cardBorder),
                        boxShadow: AppColors.cardShadow,
                      ),
                      child: _buildPriceSummaryContent(context, state),
                    ),
                  ),
                ],
              ),
            );
          }

          // Mobile Layout (< 900px)
          return SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.items.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (ctx, idx) => _buildCartItemTile(context, state.items[idx]),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  child: _buildPriceSummaryContent(context, state),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCartItemTile(BuildContext context, dynamic item) {
    final prod = item.product;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(14),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(
                prod.mainImage,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.smart_toy_rounded, color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  prod.title,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  runSpacing: 2,
                  children: [
                    Text(
                      CurrencyFormatter.format(prod.price),
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w800),
                    ),
                    if (prod.originalPrice != null && prod.originalPrice! > prod.price) ...[
                      Text(
                        CurrencyFormatter.format(prod.originalPrice!),
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      Text(
                        'Save ${CurrencyFormatter.format((prod.originalPrice! - prod.price) * item.quantity)}',
                        style: const TextStyle(
                          color: AppColors.successGreen,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        context.read<CartBloc>().add(UpdateCartQuantityRequested(prod.id, item.quantity - 1));
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: const Icon(Icons.remove, size: 14, color: AppColors.textPrimary),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        '${item.quantity}',
                        style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        context.read<CartBloc>().add(UpdateCartQuantityRequested(prod.id, item.quantity + 1));
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: const Icon(Icons.add, size: 14, color: AppColors.textPrimary),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.textMuted, size: 20),
            onPressed: () {
              context.read<CartBloc>().add(RemoveFromCartRequested(prod.id));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSummaryContent(BuildContext context, CartState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Price Details',
          style: TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Subtotal', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            Text(CurrencyFormatter.format(state.subtotal), style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
        if (state.totalSavings > 0) ...[
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Savings', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              Text('-${CurrencyFormatter.format(state.totalSavings)}', style: const TextStyle(color: AppColors.successGreen, fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
        ],
        const Divider(color: AppColors.cardBorder, height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Total', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w900)),
            Text(CurrencyFormatter.format(state.grandTotal), style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w900)),
          ],
        ),
        const SizedBox(height: 16),
        CustomButton(
          text: 'Proceed to Checkout',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CheckoutScreen()),
            );
          },
        ),
      ],
    );
  }
}
