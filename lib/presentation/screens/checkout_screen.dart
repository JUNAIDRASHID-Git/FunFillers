import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/responsive.dart';
import '../../domain/entities/address.dart';
import '../blocs/cart/cart_bloc.dart';
import '../blocs/cart/cart_state.dart';
import '../blocs/cart/cart_event.dart';
import '../blocs/checkout/checkout_bloc.dart';
import '../blocs/checkout/checkout_state.dart';
import '../blocs/checkout/checkout_event.dart';
import '../blocs/order/order_bloc.dart';
import '../blocs/order/order_event.dart';
import '../blocs/order/order_state.dart';
import '../widgets/custom_button.dart';
import '../blocs/address/address_cubit.dart';
import 'address_selection_screen.dart';
import 'order_success_screen.dart';

import '../../data/repositories/app_repository_impl.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
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

  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'id': 'card',
      'title': 'Credit / Debit Card',
      'icon': Icons.credit_card_rounded,
    },
    {
      'id': 'upi',
      'title': 'UPI',
      'icon': Icons.account_balance_wallet_outlined,
    },
    {
      'id': 'wallet',
      'title': 'Wallets',
      'icon': Icons.account_balance_outlined,
    },
    {
      'id': 'cod',
      'title': 'Cash on Delivery',
      'icon': Icons.payments_outlined,
    },
  ];

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
      child: Scaffold(
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
            'Checkout',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        body: BlocBuilder<CheckoutBloc, CheckoutState>(
          builder: (context, state) {
            return Column(
              children: [
                // Step Indicator Bar
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: MaxWidthContainer(
                    maxWidth: 800,
                    child: Row(
                      children: [
                        _buildStepCircle(1, 'Address', state.currentStep >= 1),
                        _buildStepLine(state.currentStep >= 2),
                        _buildStepCircle(2, 'Payment', state.currentStep >= 2),
                        _buildStepLine(state.currentStep >= 3),
                        _buildStepCircle(3, 'Review', state.currentStep >= 3),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 1, color: AppColors.cardBorder),

                Expanded(
                  child: SingleChildScrollView(
                    child: isWide
                        ? MaxWidthContainer(
                            maxWidth: 1200,
                            padding: const EdgeInsets.all(24),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Left 60%: Shipping Address & Payment Selection
                                Expanded(
                                  flex: 60,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildShippingAddressSection(context),
                                      const SizedBox(height: 24),
                                      _buildPaymentMethodSection(context, state),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 32),
                                // Right 40%: Order Summary & Checkout Button
                                Expanded(
                                  flex: 40,
                                  child: _buildDesktopSummaryCard(context, state),
                                ),
                              ],
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildShippingAddressSection(context),
                                const SizedBox(height: 24),
                                _buildPaymentMethodSection(context, state),
                                const SizedBox(height: 24),
                                _buildMobileSummarySection(context),
                              ],
                            ),
                          ),
                  ),
                ),

                // Mobile Bottom Floating Button (< 900px)
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
                          child: CustomButton(
                            text: state.currentStep == 1 ? 'Proceed to Payment' : 'Place Order',
                            onPressed: () => _handleCheckoutAction(context, state, cartState),
                          ),
                        ),
                      );
                    },
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

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
                '+ Add New',
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
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
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

  Widget _buildPaymentMethodSection(BuildContext context, CheckoutState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payment Method',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _paymentMethods.length,
            separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.cardBorder),
            itemBuilder: (context, index) {
              final method = _paymentMethods[index];
              final isSelected = state.selectedPaymentMethod == method['id'];

              return ListTile(
                leading: Icon(
                  method['icon'] as IconData,
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                ),
                title: Text(
                  method['title'] as String,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: AppColors.textPrimary,
                  ),
                ),
                trailing: Icon(
                  isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                  color: isSelected ? AppColors.primary : AppColors.textMuted,
                ),
                onTap: () {
                  context.read<CheckoutBloc>().add(
                        SelectPaymentMethod(paymentMethod: method['id'] as String),
                      );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMobileSummarySection(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, cartState) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Order Summary', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 12),
              _buildSummaryRow('Subtotal', CurrencyFormatter.format(cartState.subtotal)),
              if (cartState.totalSavings > 0) ...[
                const SizedBox(height: 8),
                _buildSummaryRow('Total Savings', '-${CurrencyFormatter.format(cartState.totalSavings)}', valueColor: AppColors.successGreen),
              ],
              const Divider(height: 24),
              _buildSummaryRow('Total Amount', CurrencyFormatter.format(cartState.totalAmount), isTotal: true),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDesktopSummaryCard(BuildContext context, CheckoutState state) {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, cartState) {
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
              const Text('Order Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 16),
              _buildSummaryRow('Subtotal', CurrencyFormatter.format(cartState.subtotal)),
              if (cartState.totalSavings > 0) ...[
                const SizedBox(height: 10),
                _buildSummaryRow('Total Savings', '-${CurrencyFormatter.format(cartState.totalSavings)}', valueColor: AppColors.successGreen),
              ],
              const Divider(height: 28),
              _buildSummaryRow('Total Amount', CurrencyFormatter.format(cartState.totalAmount), isTotal: true),
              const SizedBox(height: 24),
              CustomButton(
                text: state.currentStep == 1 ? 'Proceed to Payment' : 'Place Order',
                onPressed: () => _handleCheckoutAction(context, state, cartState),
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleCheckoutAction(BuildContext context, CheckoutState state, CartState cartState) {
    if (state.currentStep == 1) {
      context.read<CheckoutBloc>().add(const GoToStep(step: 2));
    } else {
      context.read<OrderBloc>().add(
            CreateOrder(
              items: cartState.items,
              shippingAddress: _shippingAddress,
              paymentMethod: state.selectedPaymentMethod,
              subtotal: cartState.subtotal,
              discount: cartState.discount,
              shippingFee: cartState.shippingFee,
              total: cartState.totalAmount,
            ),
          );
    }
  }

  Widget _buildStepCircle(int step, String label, bool isActive) {
    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isActive ? AppColors.textPrimary : AppColors.cardBorder,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
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

  Widget _buildStepLine(bool isActive) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 16, left: 8, right: 8),
        color: isActive ? AppColors.textPrimary : AppColors.cardBorder,
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 15 : 13,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: isTotal ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
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
