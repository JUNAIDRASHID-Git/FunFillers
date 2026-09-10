import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/theme/app_colors.dart';
import '../blocs/cart/cart_bloc.dart';
import '../blocs/cart/cart_state.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_state.dart';
import '../blocs/address/address_cubit.dart';
import 'home_screen.dart';
import 'category_list_screen.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';

class MainLayoutScreen extends StatefulWidget {
  final int initialIndex;

  const MainLayoutScreen({super.key, this.initialIndex = 0});

  @override
  State<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends State<MainLayoutScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = _clampIndex(widget.initialIndex);
  }

  @override
  void didUpdateWidget(covariant MainLayoutScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialIndex != widget.initialIndex) {
      setState(() {
        _currentIndex = _clampIndex(widget.initialIndex);
      });
    }
  }

  int _clampIndex(int index) {
    if (index < 0 || index >= 4) return 0;
    return index;
  }

  void _onTabTapped(int index) {
    setState(() => _currentIndex = _clampIndex(index));
  }

  String _getSvgPath(int index, bool isSelected) {
    switch (index) {
      case 0:
        return isSelected
            ? 'assets/icons/home_selected.svg'
            : 'assets/icons/home_notselected.svg';
      case 1:
        return isSelected
            ? 'assets/icons/category_active.svg'
            : 'assets/icons/category.svg';
      case 2:
        return isSelected
            ? 'assets/icons/shopping_active.svg'
            : 'assets/icons/shopping.svg';
      case 3:
        return 'assets/icons/profile.svg';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomeScreen(onNavigateTab: _onTabTapped),
      CategoryListScreen(onNavigateTab: _onTabTapped),
      const CartScreen(),
      const ProfileScreen(),
    ];

    final isWide = MediaQuery.sizeOf(context).width >= 800;

    if (isWide) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Row(
          children: [
            // Left Sidebar Navigation for Tablets / Desktop
            Container(
              width: 240,
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  right: BorderSide(color: AppColors.cardBorder, width: 1),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  // Brand Logo Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/images/fun_fillers_logo.png',
                          height: 36,
                          errorBuilder: (_, _, _) => const Icon(
                            Icons.toys_rounded,
                            color: AppColors.primary,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'FunFillers',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Navigation Links List
                  _buildSidebarSvgItem(0, 'Home'),
                  _buildSidebarSvgItem(1, 'Category'),
                  _buildCartSidebarItem(2),
                  _buildSidebarSvgItem(3, 'Profile'),

                  const Spacer(),
                  // Footer info
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.softPink,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Column(
                        children: [
                          Icon(
                            Icons.stars_rounded,
                            color: AppColors.primary,
                            size: 24,
                          ),
                          SizedBox(height: 6),
                          Text(
                            'FunFillers Toys Store',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Main Content Body Area
            Expanded(
              child: IndexedStack(index: _clampIndex(_currentIndex), children: pages),
            ),
          ],
        ),
      );
    }

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated || state is Unauthenticated) {
          context.read<AddressCubit>().loadAddresses();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: IndexedStack(index: _clampIndex(_currentIndex), children: pages),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            border: const Border(
              top: BorderSide(color: AppColors.cardBorder, width: 1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSvgNavItem(0, 'Home'),
                  _buildSvgNavItem(1, 'Category'),
                  _buildCartNavItem(2),
                  _buildSvgNavItem(3, 'Profile'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSvgNavItem(int index, String label) {
    final isSelected = _currentIndex == index;
    final svgAsset = _getSvgPath(index, isSelected);

    return InkWell(
      onTap: () => _onTabTapped(index),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              svgAsset,
              width: 22,
              height: 22,
              colorFilter: ColorFilter.mode(
                isSelected ? AppColors.primary : AppColors.textMuted,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textMuted,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarSvgItem(int index, String label) {
    final isSelected = _currentIndex == index;
    final svgAsset = _getSvgPath(index, isSelected);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: isSelected ? AppColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          leading: SvgPicture.asset(
            svgAsset,
            width: 20,
            height: 20,
            colorFilter: ColorFilter.mode(
              isSelected ? Colors.white : AppColors.textSecondary,
              BlendMode.srcIn,
            ),
          ),
          title: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textPrimary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 14,
            ),
          ),
          onTap: () => _onTabTapped(index),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildCartSidebarItem(int index) {
    final isSelected = _currentIndex == index;
    final svgAsset = _getSvgPath(index, isSelected);

    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        final itemCount = state.totalItemCount;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Material(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            child: ListTile(
              leading: Stack(
                clipBehavior: Clip.none,
                children: [
                  SvgPicture.asset(
                    svgAsset,
                    width: 20,
                    height: 20,
                    colorFilter: ColorFilter.mode(
                      isSelected ? Colors.white : AppColors.textSecondary,
                      BlendMode.srcIn,
                    ),
                  ),
                  if (itemCount > 0)
                    Positioned(
                      top: -4,
                      right: -6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.discountRed,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Center(
                          child: Text(
                            '$itemCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              title: Text(
                'Cart',
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              onTap: () => _onTabTapped(index),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCartNavItem(int index) {
    final isSelected = _currentIndex == index;
    final svgAsset = _getSvgPath(index, isSelected);

    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        final itemCount = state.totalItemCount;

        return InkWell(
          onTap: () => _onTabTapped(index),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    SvgPicture.asset(
                      svgAsset,
                      width: 22,
                      height: 22,
                      colorFilter: ColorFilter.mode(
                        isSelected ? AppColors.primary : AppColors.textMuted,
                        BlendMode.srcIn,
                      ),
                    ),
                    if (itemCount > 0)
                      Positioned(
                        top: -4,
                        right: -6,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.discountRed,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Center(
                            child: Text(
                              '$itemCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  'Cart',
                  style: TextStyle(
                    color: isSelected ? AppColors.primary : AppColors.textMuted,
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
