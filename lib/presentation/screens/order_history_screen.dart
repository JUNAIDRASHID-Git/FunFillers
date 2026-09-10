import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/responsive.dart';
import '../blocs/order/order_bloc.dart';
import '../blocs/order/order_state.dart';
import '../blocs/order/order_event.dart';
import '../widgets/skeleton_widget.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  @override
  void initState() {
    super.initState();
    context.read<OrderBloc>().add(LoadOrdersRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'My Orders',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: BlocBuilder<OrderBloc, OrderState>(
        builder: (context, state) {
          if (state is OrderLoading) {
            return ShimmerEffect(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: 5,
                itemBuilder: (context, index) => const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: SkeletonBox(width: double.infinity, height: 100, borderRadius: 16),
                ),
              ),
            );
          }

          if (state is OrderLoaded) {
            if (state.orders.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: const BoxDecoration(
                        color: AppColors.cardPink,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.shopping_bag_outlined,
                        size: 56,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No Orders Yet',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'When you buy toys, your orders will appear here!',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }

            return MaxWidthContainer(
              maxWidth: 900,
              padding: const EdgeInsets.all(16),
              child: ListView.separated(
                itemCount: state.orders.length,
                separatorBuilder: (_, _) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final order = state.orders[index];
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.cardBorder),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Order #${order.id}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _buildStatusBadge(order.status),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Placed on ${_formatDate(order.createdAt)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.payment_outlined,
                              size: 15,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'Payment Method: ',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textMuted,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.softPink,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: AppColors.primary.withValues(alpha: 0.2),
                                  ),
                                ),
                                child: Text(
                                  order.paymentMethod,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                            if (order.paymentId != null && 
                                order.paymentId!.isNotEmpty && 
                                !order.paymentMethod.contains(order.paymentId!)) ...[
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  '(${order.paymentId})',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const Divider(height: 24, color: AppColors.cardBorder),

                        ...order.items.map((item) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: AppColors.imagePlaceholder,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      item.product.imageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) => const Icon(
                                        Icons.toys,
                                        size: 20,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.product.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        'Qty: ${item.quantity} x ${CurrencyFormatter.format(item.product.price)}',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),

                        if (order.refundId != null || order.cancellationReason != null) ...[
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF8E1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFFFE082)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (order.cancellationReason != null && order.cancellationReason!.isNotEmpty)
                                  Text(
                                    'Reason: ${order.cancellationReason}',
                                    style: const TextStyle(fontSize: 11, color: AppColors.textPrimary),
                                  ),
                                if (order.refundId != null && order.refundId!.isNotEmpty)
                                  Text(
                                    'Razorpay Refund ID: ${order.refundId} (${order.refundStatus ?? "Processed"})',
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.accentOrange),
                                  ),
                              ],
                            ),
                          ),
                        ],
                        const Divider(height: 20, color: AppColors.cardBorder),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Total Amount',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                                Text(
                                  CurrencyFormatter.format(order.total),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            Wrap(
                              spacing: 8,
                              children: [
                                if (order.status.toLowerCase() != 'shipped' &&
                                    order.status.toLowerCase() != 'delivered' &&
                                    order.status.toLowerCase() != 'cancelled')
                                  OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: AppColors.discountRed),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    onPressed: () => _showCancelDialog(
                                      context,
                                      order,
                                    ),
                                    child: const Text(
                                      'Cancel Order',
                                      style: TextStyle(
                                        color: AppColors.discountRed,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                      color: AppColors.primary,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Order tracking link sent to your email.',
                                        ),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'Track Order',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _showCancelDialog(BuildContext context, dynamic order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return _FlipkartCancelBottomSheet(
          order: order,
          onProceedToValidation: (selectedReason) {
            Navigator.pop(bottomSheetContext);
            _showAreYouSureConfirmation(context, order, selectedReason);
          },
        );
      },
    );
  }

  void _showAreYouSureConfirmation(BuildContext context, dynamic order, String reason) {
    final pm = order.paymentMethod.toString().toLowerCase();
    final isCod = pm.contains('cod') || pm.contains('cash on delivery') || pm.contains('cash_on_delivery') || pm.contains('pay on delivery');

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppColors.softPink,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.help_outline_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Are you sure?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to cancel Order #${order.id}?',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reason: $reason',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (isCod)
                      const Row(
                        children: [
                          Icon(Icons.info_outline, size: 14, color: AppColors.textMuted),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Payment Mode: Cash on Delivery (No refund required)',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      Row(
                        children: [
                          const Icon(Icons.account_balance_wallet_outlined, size: 14, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Refund: Full refund of ${CurrencyFormatter.format(order.total)} will be processed via Razorpay.',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Once cancelled, this action cannot be undone and your item reservation will be released.',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          actions: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.discountRed),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<OrderBloc>().add(
                      CancelOrderRequested(
                        orderId: order.id,
                        reason: reason,
                      ),
                    );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isCod
                          ? 'Order #${order.id} cancelled successfully.'
                          : 'Order cancelled. Razorpay refund request submitted successfully.',
                    ),
                    backgroundColor: AppColors.primary,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text(
                'Confirm Cancel',
                style: TextStyle(
                  color: AppColors.discountRed,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'Keep Order',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }


  Widget _buildStatusBadge(String status) {
    Color bg;
    Color fg;

    switch (status.toLowerCase()) {
      case 'delivered':
        bg = const Color(0xFFE8F5E9);
        fg = AppColors.accentGreen;
        break;
      case 'in transit':
      case 'shipped':
        bg = const Color(0xFFFFF3E0);
        fg = AppColors.accentOrange;
        break;
      case 'cancelled':
        bg = const Color(0xFFFFEBEE);
        fg = AppColors.discountRed;
        break;
      default:
        bg = AppColors.softPink;
        fg = AppColors.primary;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

class _FlipkartCancelBottomSheet extends StatefulWidget {
  final dynamic order;
  final Function(String reason) onProceedToValidation;

  const _FlipkartCancelBottomSheet({
    required this.order,
    required this.onProceedToValidation,
  });

  @override
  State<_FlipkartCancelBottomSheet> createState() => _FlipkartCancelBottomSheetState();
}

class _FlipkartCancelBottomSheetState extends State<_FlipkartCancelBottomSheet> {
  final List<String> _reasons = [
    'Expected delivery time is very long',
    'Price for the product has decreased',
    'I want to change the delivery address',
    'Order placed by mistake',
    'I want to change payment mode',
    'Found a better price elsewhere',
    'Other reasons',
  ];

  String? _selectedReason;
  final TextEditingController _otherReasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedReason = _reasons[0];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.cardBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Reason for Cancellation',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Order #${widget.order.id}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(height: 24, color: AppColors.cardBorder),
            const Text(
              'Please select a reason for cancellation:',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            ..._reasons.map((reason) {
              final isSelected = _selectedReason == reason;
              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedReason = reason;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.softPink.withValues(alpha: 0.5) : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.cardBorder,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                        color: isSelected ? AppColors.primary : AppColors.textMuted,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          reason,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? AppColors.primary : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),

            if (_selectedReason == 'Other reasons') ...[
              const SizedBox(height: 8),
              TextField(
                controller: _otherReasonController,
                decoration: const InputDecoration(
                  labelText: 'Please specify reason',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ],

            const SizedBox(height: 12),
            // Flipkart Retention Tip / Notice
            if (_selectedReason == 'I want to change the delivery address')
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF90CAF9)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: Color(0xFF1976D2), size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Tip: You can update your shipping address in Profile > Address Book without needing to cancel your order!',
                        style: TextStyle(fontSize: 12, color: Color(0xFF0D47A1)),
                      ),
                    ),
                  ],
                ),
              )
            else if (_selectedReason == 'Price for the product has decreased')
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFFE082)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.local_offer_outlined, color: AppColors.accentOrange, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Best Price Guarantee: Check out our promo vouchers before cancelling to get extra savings!',
                        style: TextStyle(fontSize: 12, color: AppColors.textPrimary),
                      ),
                    ),
                  ],
                ),
              )
            else () {
              final pm = widget.order.paymentMethod.toString().toLowerCase();
              final isCod = pm.contains('cod') || pm.contains('cash on delivery') || pm.contains('cash_on_delivery') || pm.contains('pay on delivery');
              if (isCod) {
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline_rounded, color: AppColors.textSecondary, size: 20),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Payment Mode: Cash on Delivery (COD). No payment has been collected and no cancellation charges apply.',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.softPink,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.account_balance_wallet_outlined, color: AppColors.primary, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Refund Summary: Full refund of ${CurrencyFormatter.format(widget.order.total)} will be automatically processed back to your original payment method via Razorpay.',
                        style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              );
            }(),


            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Keep Order',
                      style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.discountRed,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      final finalReason = (_selectedReason == 'Other reasons' && _otherReasonController.text.trim().isNotEmpty)
                          ? _otherReasonController.text.trim()
                          : (_selectedReason ?? 'Cancelled by customer');
                      widget.onProceedToValidation(finalReason);
                    },
                    child: const Text(
                      'Cancel Order',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
