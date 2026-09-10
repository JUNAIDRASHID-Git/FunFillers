import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/api_constants.dart';
import '../../core/services/razorpay_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/responsive.dart';
import '../../data/repositories/app_repository_impl.dart';
import '../../domain/entities/address.dart';
import '../blocs/address/address_cubit.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_state.dart';
import '../blocs/cart/cart_bloc.dart';
import '../blocs/cart/cart_event.dart';
import '../blocs/cart/cart_state.dart';
import '../blocs/checkout/checkout_bloc.dart';
import '../blocs/checkout/checkout_event.dart';
import '../blocs/checkout/checkout_state.dart';
import '../blocs/order/order_bloc.dart';
import '../blocs/order/order_event.dart';
import '../blocs/order/order_state.dart';
import '../widgets/custom_button.dart';
import 'address_selection_screen.dart';
import 'order_success_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _isProcessingPayment = false;
  String _expandedCategory = 'upi';

  Address _shippingAddress = const Address(
    id: 'addr_default',
    title: 'Home',
    label: 'Home',
    fullAddress: 'Detecting address...',
    city: 'Bengaluru',
    state: 'Karnataka',
    country: 'India',
    pincode: '560001',
    latitude: 12.9716,
    longitude: 77.5946,
    isDefault: true,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthBloc>().state;
      final bool isGuest = authState is! Authenticated || authState.user.isGuest;
      if (isGuest && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please sign in to proceed with checkout.'),
            backgroundColor: AppColors.primary,
          ),
        );
        context.pushReplacement('/signin');
      }
    });

    // Ensure initial step is set to 2 (Confirm details) on entering Checkout
    context.read<CheckoutBloc>().add(const GoToStep(step: 2));
    _loadSavedAddress();
  }

  Future<void> _loadSavedAddress() async {
    try {
      final active = context.read<AddressCubit>().state.activeAddress;
      if (active != null && mounted) {
        setState(() => _shippingAddress = active);
        return;
      }
      final repository = RepositoryProvider.of<AppRepositoryImpl>(context, listen: false);
      final addresses = await repository.getAddresses();
      if (addresses.isNotEmpty && mounted) {
        final defaultAddr = addresses.firstWhere((a) => a.isDefault, orElse: () => addresses.first);
        setState(() => _shippingAddress = defaultAddr);
      }
    } catch (_) {}
  }



  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 900;

    return BlocListener<OrderBloc, OrderState>(
      listener: (context, state) {
        if (state is OrderPlacedSuccess) {
          context.read<CartBloc>().add(ClearCart());
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => OrderSuccessScreen(orderId: state.order.id),
            ),
            (route) => false,
          );
        }
      },
      child: BlocBuilder<CheckoutBloc, CheckoutState>(
        builder: (context, state) {
          final isPaymentStep = state.currentStep == 3;

          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                onPressed: () {
                  if (_isProcessingPayment) return;
                  if (isPaymentStep) {
                    context.read<CheckoutBloc>().add(const GoToStep(step: 2));
                  } else {
                    Navigator.pop(context);
                  }
                },
              ),
              centerTitle: true,
              title: isPaymentStep
                  ? const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Step 3 of 3',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textMuted,
                          ),
                        ),
                        Text(
                          'Payments',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                      ],
                    )
                  : const Text(
                      'Checkout',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
              actions: [
                if (isPaymentStep)
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.lock_outline_rounded, size: 13, color: AppColors.textSecondary),
                            SizedBox(width: 4),
                            Text(
                              '100% Secure',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            body: Stack(
              children: [
                Column(
                  children: [
                    // Step Indicator Bar: Address -> Confirm details -> Payment
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      child: MaxWidthContainer(
                        maxWidth: 800,
                        child: Row(
                          children: [
                            _buildStepCircle(
                              step: 1,
                              label: 'Address',
                              isActive: true,
                              isCompleted: true,
                            ),
                            _buildStepLine(isActive: true),
                            _buildStepCircle(
                              step: 2,
                              label: 'Confirm details',
                              isActive: state.currentStep >= 2,
                              isCompleted: state.currentStep > 2,
                            ),
                            _buildStepLine(isActive: state.currentStep >= 3),
                            _buildStepCircle(
                              step: 3,
                              label: 'Payment',
                              isActive: state.currentStep >= 3,
                              isCompleted: false,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(height: 1, color: AppColors.cardBorder),

                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: MaxWidthContainer(
                          maxWidth: isWide ? 1100 : 680,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: BlocBuilder<CartBloc, CartState>(
                            builder: (context, cartState) {
                              if (isPaymentStep) {
                                return _buildPaymentStepContent(context, state, cartState, isWide);
                              }
                              return _buildConfirmDetailsStepContent(context, state, cartState, isWide);
                            },
                          ),
                        ),
                      ),
                    ),

                    // Mobile Bottom Floating Bar (< 900px)
                    if (!isWide)
                      BlocBuilder<CartBloc, CartState>(
                        builder: (context, cartState) {
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 10,
                                  offset: Offset(0, -2),
                                ),
                              ],
                            ),
                            child: SafeArea(
                              child: Row(
                                children: [
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Total Amount',
                                        style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                                      ),
                                      Text(
                                        CurrencyFormatter.format(cartState.totalAmount),
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w900,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: CustomButton(
                                      text: _isProcessingPayment
                                          ? 'Processing...'
                                          : (isPaymentStep ? 'Place Order' : 'Proceed to Payment'),
                                      onPressed: _isProcessingPayment
                                          ? null
                                          : () => _handleCheckoutAction(context, state, cartState),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
                if (_isProcessingPayment)
                  Container(
                    color: Colors.black26,
                    child: const Center(
                      child: Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 28, vertical: 20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(color: AppColors.primary),
                              SizedBox(height: 16),
                              Text(
                                'Opening Razorpay Payment...',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Content for Step 2: Confirm Details (Address + Checkout Products + Order Summary)
  Widget _buildConfirmDetailsStepContent(
    BuildContext context,
    CheckoutState state,
    CartState cartState,
    bool isWide,
  ) {
    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Column (60%): Shipping Address & Product Details
          Expanded(
            flex: 60,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildShippingAddressSection(context),
                const SizedBox(height: 20),
                _buildCheckoutProductsSection(context, cartState),
              ],
            ),
          ),
          const SizedBox(width: 24),
          // Right Column (40%): Order Summary & Proceed Button
          Expanded(
            flex: 40,
            child: _buildDesktopOrderSummaryCard(
              context,
              state,
              cartState,
              buttonText: 'Proceed to Payment',
              onPressed: () => _handleCheckoutAction(context, state, cartState),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildShippingAddressSection(context),
        const SizedBox(height: 20),
        _buildCheckoutProductsSection(context, cartState),
        const SizedBox(height: 20),
        _buildOrderSummarySection(context, cartState),
        const SizedBox(height: 30),
      ],
    );
  }

  // Content for Step 3: Payment (Price Breakdown + Cashback Offers + Accordion Payment Methods)
  Widget _buildPaymentStepContent(
    BuildContext context,
    CheckoutState state,
    CartState cartState,
    bool isWide,
  ) {
    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Column (60%): Price Breakdown + Cashback + Payment Accordions
          Expanded(
            flex: 60,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopPriceBreakdownCard(cartState),
                const SizedBox(height: 16),
                _buildCashbackOffersBanner(),
                const SizedBox(height: 20),
                _buildAccordionPaymentSection(context, state, cartState),
              ],
            ),
          ),
          const SizedBox(width: 24),
          // Right Column (40%): Order Summary & Place Order Button
          Expanded(
            flex: 40,
            child: _buildDesktopOrderSummaryCard(
              context,
              state,
              cartState,
              buttonText: _isProcessingPayment ? 'Processing...' : 'Place Order',
              onPressed: () => _handleCheckoutAction(context, state, cartState),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTopPriceBreakdownCard(cartState),
        const SizedBox(height: 16),
        _buildCashbackOffersBanner(),
        const SizedBox(height: 20),
        _buildAccordionPaymentSection(context, state, cartState),
        const SizedBox(height: 30),
      ],
    );
  }

  // Shipping Address Card Widget
  Widget _buildShippingAddressSection(BuildContext context) {
    Future<void> openAddressPicker() async {
      final addressCubit = context.read<AddressCubit>();
      final Address? newAddress = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AddressSelectionScreen(initialAddress: _shippingAddress),
        ),
      );
      if (newAddress != null) {
        final newEntity = AddressEntity(
          id: newAddress.id,
          name: newAddress.title,
          fullAddress: newAddress.fullAddress,
          city: newAddress.city,
          state: newAddress.state,
          pincode: newAddress.pincode,
          label: newAddress.label,
          isDefault: true,
          country: newAddress.country,
          latitude: newAddress.latitude,
          longitude: newAddress.longitude,
        );
        await addressCubit.saveAddress(newEntity);
        if (mounted) {
          setState(() => _shippingAddress = newEntity);
        }
      }
    }

    final titleText = _shippingAddress.title.isNotEmpty ? _shippingAddress.title : 'Home';
    final fullAddrText = _shippingAddress.fullAddress.isNotEmpty
        ? _shippingAddress.fullAddress
        : 'Select delivery address';
    final cityStatePinText = [
      if (_shippingAddress.city.isNotEmpty) _shippingAddress.city,
      if (_shippingAddress.state.isNotEmpty) _shippingAddress.state,
      if (_shippingAddress.pincode.isNotEmpty) _shippingAddress.pincode,
    ].join(', ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Shipping Address',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: openAddressPicker,
              child: const Text(
                '+ Add / Change',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder),
            boxShadow: AppColors.cardShadow,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.accentOrange.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  color: AppColors.accentOrange,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          titleText,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _shippingAddress.label,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      fullAddrText,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.3,
                      ),
                    ),
                    if (cityStatePinText.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        cityStatePinText,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: openAddressPicker,
                child: const Text(
                  'Change',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Checkout Products Details Card
  Widget _buildCheckoutProductsSection(BuildContext context, CartState cartState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Order Items (${cartState.items.length})',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () => context.pop(),
              child: const Text(
                'Edit Cart',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder),
            boxShadow: AppColors.cardShadow,
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: cartState.items.length,
            separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.cardBorder),
            itemBuilder: (context, index) {
              final item = cartState.items[index];
              final prod = item.product;
              final imgUrl = ApiConstants.sanitizeImageUrl(prod.mainImage);

              return Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.cardPink,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          imgUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.smart_toy_rounded,
                            color: AppColors.primary,
                            size: 26,
                          ),
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
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Qty: ${item.quantity}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${CurrencyFormatter.format(prod.price)} each',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      CurrencyFormatter.format(item.totalPrice),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTopPriceBreakdownCard(CartState cartState) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F6FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'MRP (incl. of all taxes)',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              Text(
                CurrencyFormatter.format(cartState.subtotal),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Text(
                    'Fees',
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                  SizedBox(width: 2),
                  Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.textMuted),
                ],
              ),
              Text(
                cartState.shippingFee == 0 ? 'FREE' : CurrencyFormatter.format(cartState.shippingFee),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: cartState.shippingFee == 0 ? AppColors.successGreen : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          if (cartState.totalSavings > 0) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Text(
                      'Discounts',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                    SizedBox(width: 2),
                    Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.textMuted),
                  ],
                ),
                Text(
                  '-${CurrencyFormatter.format(cartState.totalSavings)}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.successGreen,
                  ),
                ),
              ],
            ),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: AppColors.cardBorder),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Text(
                    'Total Amount',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                  SizedBox(width: 2),
                  Icon(Icons.keyboard_arrow_up, size: 18, color: AppColors.primary),
                ],
              ),
              Text(
                CurrencyFormatter.format(cartState.totalAmount),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCashbackOffersBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFA5D6A7)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  '5% Cashback',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Claim now with payment offers',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF388E3C),
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              _buildOfferIconBadge('UPI', Colors.blue.shade700),
              const SizedBox(width: 4),
              _buildOfferIconBadge('Card', Colors.indigo.shade700),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFC8E6C9)),
                ),
                child: const Text(
                  '+3',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOfferIconBadge(String label, Color color) {
    return Container(
      width: 26,
      height: 26,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          label[0],
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }

  Widget _buildAccordionPaymentSection(
    BuildContext context,
    CheckoutState state,
    CartState cartState,
  ) {
    final categories = [
      {
        'id': 'recommended',
        'icon': Icons.thumb_up_alt_outlined,
        'title': 'Recommended for You',
        'subtitle': 'Fastest & most reliable payment',
        'tag': null,
        'methodId': 'upi',
      },
      {
        'id': 'upi',
        'icon': Icons.account_balance_wallet_outlined,
        'title': 'UPI',
        'subtitle': 'Pay by any UPI app',
        'tag': 'Up to ₹100 cashback • 2 offers available',
        'methodId': 'upi',
      },
      {
        'id': 'card',
        'icon': Icons.credit_card_rounded,
        'title': 'Credit / Debit / ATM Card',
        'subtitle': 'Add and secure cards as per RBI guidelines',
        'tag': 'Get upto 5% cashback • 2 offers available',
        'methodId': 'card',
      },
      {
        'id': 'wallet',
        'icon': Icons.calendar_today_rounded,
        'title': 'EMI / Net Banking',
        'subtitle': 'Credit Card EMI & 50+ Banks NetBanking',
        'tag': null,
        'methodId': 'wallet',
      },
      {
        'id': 'cod',
        'icon': Icons.payments_outlined,
        'title': 'Cash on Delivery',
        'subtitle': 'Pay cash when item is delivered',
        'tag': null,
        'methodId': 'cod',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: categories.map((cat) {
        final catId = cat['id'] as String;
        final isExpanded = _expandedCategory == catId;
        final methodId = cat['methodId'] as String;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isExpanded ? AppColors.primary : AppColors.cardBorder,
              width: isExpanded ? 1.5 : 1,
            ),
            boxShadow: isExpanded
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : AppColors.cardShadow,
          ),
          child: Column(
            children: [
              InkWell(
                onTap: () {
                  setState(() {
                    _expandedCategory = isExpanded ? '' : catId;
                  });
                  context.read<CheckoutBloc>().add(
                        SelectPaymentMethod(paymentMethod: methodId),
                      );
                },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isExpanded
                              ? AppColors.primary.withValues(alpha: 0.1)
                              : const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          cat['icon'] as IconData,
                          size: 20,
                          color: isExpanded ? AppColors.primary : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cat['title'] as String,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            if (cat['subtitle'] != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                cat['subtitle'] as String,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                            if (cat['tag'] != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                cat['tag'] as String,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.successGreen,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Icon(
                        isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
              if (isExpanded) ...[
                const Divider(height: 1, color: AppColors.cardBorder),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildExpandedCategoryContent(context, catId, methodId, cartState),
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildExpandedCategoryContent(
    BuildContext context,
    String categoryId,
    String methodId,
    CartState cartState,
  ) {
    if (categoryId == 'cod') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFFE082)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Color(0xFFF57F17), size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'No advance payment required. Pay total amount in cash upon package delivery.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF5D4037)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              text: _isProcessingPayment ? 'Processing...' : 'Place Order with Cash on Delivery',
              onPressed: _isProcessingPayment
                  ? null
                  : () => _handleCheckoutAction(context, context.read<CheckoutBloc>().state, cartState),
            ),
          ),
        ],
      );
    }

    String infoMessage = 'Pay securely via Razorpay payment gateway.';
    if (categoryId == 'upi') {
      infoMessage = 'Select Google Pay, PhonePe, Paytm or enter UPI ID on Razorpay.';
    } else if (categoryId == 'card') {
      infoMessage = 'All major Visa, MasterCard, RuPay & Maestro cards accepted.';
    } else if (categoryId == 'wallet') {
      infoMessage = 'Net Banking across 50+ banks & Wallets available via Razorpay.';
    } else if (categoryId == 'recommended') {
      infoMessage = 'Recommended fast checkout via Instant UPI / Razorpay.';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.softPink,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              const Icon(Icons.shield_outlined, color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  infoMessage,
                  style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: CustomButton(
            text: _isProcessingPayment
                ? 'Opening Razorpay...'
                : 'Pay ${CurrencyFormatter.format(cartState.totalAmount)}',
            onPressed: _isProcessingPayment
                ? null
                : () => _handleCheckoutAction(context, context.read<CheckoutBloc>().state, cartState),
          ),
        ),
      ],
    );
  }

  // Mobile Order Summary Price Details Card
  Widget _buildOrderSummarySection(BuildContext context, CartState cartState) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Price Details',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          _buildSummaryRow('Subtotal (${cartState.items.length} items)', CurrencyFormatter.format(cartState.subtotal)),
          if (cartState.totalSavings > 0) ...[
            const SizedBox(height: 8),
            _buildSummaryRow('Total Savings', '-${CurrencyFormatter.format(cartState.totalSavings)}', valueColor: AppColors.successGreen),
          ],
          const SizedBox(height: 8),
          _buildSummaryRow(
            'Delivery Charges',
            cartState.shippingFee == 0 ? 'FREE' : CurrencyFormatter.format(cartState.shippingFee),
            valueColor: cartState.shippingFee == 0 ? AppColors.successGreen : null,
          ),
          const Divider(height: 24, color: AppColors.cardBorder),
          _buildSummaryRow('Total Amount', CurrencyFormatter.format(cartState.totalAmount), isTotal: true),
        ],
      ),
    );
  }

  // Desktop Order Summary Card (Right Side)
  Widget _buildDesktopOrderSummaryCard(
    BuildContext context,
    CheckoutState state,
    CartState cartState, {
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Price Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 16),
          _buildSummaryRow('Subtotal (${cartState.items.length} items)', CurrencyFormatter.format(cartState.subtotal)),
          if (cartState.totalSavings > 0) ...[
            const SizedBox(height: 10),
            _buildSummaryRow('Total Savings', '-${CurrencyFormatter.format(cartState.totalSavings)}', valueColor: AppColors.successGreen),
          ],
          const SizedBox(height: 10),
          _buildSummaryRow(
            'Delivery Charges',
            cartState.shippingFee == 0 ? 'FREE' : CurrencyFormatter.format(cartState.shippingFee),
            valueColor: cartState.shippingFee == 0 ? AppColors.successGreen : null,
          ),
          const Divider(height: 28, color: AppColors.cardBorder),
          _buildSummaryRow('Total Amount', CurrencyFormatter.format(cartState.totalAmount), isTotal: true),
          const SizedBox(height: 24),
          CustomButton(
            text: buttonText,
            onPressed: onPressed,
          ),
        ],
      ),
    );
  }

  void _handleCheckoutAction(BuildContext context, CheckoutState state, CartState cartState) async {
    if (_isProcessingPayment) return;

    final overStockItems = cartState.items.where((i) => i.quantity > i.product.stock || i.product.stock <= 0).toList();
    if (overStockItems.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Some items in your cart exceed available stock. Please return to cart and adjust quantities.'),
          backgroundColor: AppColors.discountRed,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    if (state.currentStep < 3) {
      context.read<CheckoutBloc>().add(const GoToStep(step: 3));
      return;
    }

    final paymentMethod = state.selectedPaymentMethod;

    if (paymentMethod == 'cod') {
      context.read<OrderBloc>().add(
            CreateOrder(
              items: cartState.items,
              shippingAddress: _shippingAddress,
              paymentMethod: 'Cash on Delivery (COD)',
              subtotal: cartState.subtotal,
              discount: cartState.discount,
              shippingFee: cartState.shippingFee,
              total: cartState.totalAmount,
            ),
          );
      return;
    }

    // Razorpay Online Payment Flow (UPI, Card, Wallets)
    setState(() => _isProcessingPayment = true);

    final messenger = ScaffoldMessenger.of(context);
    final orderBloc = context.read<OrderBloc>();

    try {
      final authState = context.read<AuthBloc>().state;
      final user = authState is Authenticated ? authState.user : null;

      final userName = user?.name ?? 'Customer';
      final userEmail = user?.email ?? 'customer@funfillers.com';
      final String userPhone = (user != null && user.phone != null && user.phone!.isNotEmpty) ? user.phone! : '+91 9876543210';

      // 1. Create order on Go backend
      final orderResponse = await RazorpayService.createRazorpayOrder(
        amount: cartState.totalAmount,
        currency: 'INR',
      );

      final razorpayOrderId = (orderResponse['order_id'] ?? '').toString();
      final razorpayKeyId = (orderResponse['key_id'] ?? '').toString();

      // 2 & 3. Launch Razorpay Standard Web Modal & Verify HMAC-SHA256 Signature
      final result = await RazorpayService.openCheckout(
        orderId: razorpayOrderId,
        keyIdOverride: razorpayKeyId.isNotEmpty ? razorpayKeyId : null,
        amount: cartState.totalAmount,
        name: userName,
        email: userEmail,
        phone: userPhone,
        selectedMethod: state.selectedPaymentMethod,
        description: 'FUNFILLERS Order Payment (${cartState.items.length} items)',
      );

      if (!mounted) return;

      if (result.isSuccess) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Payment verified successfully! Placing order...'),
            backgroundColor: AppColors.successGreen,
          ),
        );
        orderBloc.add(
          CreateOrder(
            items: cartState.items,
            shippingAddress: _shippingAddress,
            paymentMethod: 'Razorpay Online (${result.paymentId})',
            subtotal: cartState.subtotal,
            discount: cartState.discount,
            shippingFee: cartState.shippingFee,
            total: cartState.totalAmount,
          ),
        );
      } else {
        messenger.showSnackBar(
          SnackBar(
            content: Text(result.errorMessage ?? 'Payment was cancelled or failed.'),
            backgroundColor: AppColors.discountRed,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Payment initialization error: $e'),
            backgroundColor: AppColors.discountRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessingPayment = false);
      }
    }
  }

  // Step Progress Circle Widget
  Widget _buildStepCircle({
    required int step,
    required String label,
    required bool isActive,
    required bool isCompleted,
  }) {
    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isCompleted
                ? AppColors.successGreen
                : (isActive ? AppColors.textPrimary : AppColors.cardBorder),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : Text(
                    '$step',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            color: isActive ? AppColors.textPrimary : AppColors.textMuted,
          ),
        ),
      ],
    );
  }

  // Step Line Widget
  Widget _buildStepLine({required bool isActive}) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 16, left: 8, right: 8),
        color: isActive ? AppColors.primary : AppColors.cardBorder,
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 15 : 13,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal ? AppColors.textPrimary : AppColors.textSecondary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 16 : 13,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            color: valueColor ?? (isTotal ? AppColors.textPrimary : AppColors.textPrimary),
          ),
        ),
      ],
    );
  }
}
