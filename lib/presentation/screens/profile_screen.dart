import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import '../blocs/auth/auth_state.dart';
import '../blocs/address/address_cubit.dart';
import 'address_selection_screen.dart';
import 'order_history_screen.dart';
import 'wishlist_screen.dart';
import 'sign_in_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const SignInScreen()),
            (route) => false,
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'Profile',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            String name = 'Guest User';
            String email = 'guest@funfillers.com';
            String? avatarUrl;
            bool isGuest = true;
            String userId = '';

            if (state is Authenticated) {
              name = state.user.isGuest ? 'Guest User' : state.user.name;
              email = state.user.isGuest ? 'guest@funfillers.com' : state.user.email;
              avatarUrl = state.user.avatarUrl;
              isGuest = state.user.isGuest;
              userId = state.user.id;
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: MaxWidthContainer(
                maxWidth: 680,
                child: Column(
                  children: [
                    // User Profile Header Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.cardBorder),
                        boxShadow: AppColors.cardShadow,
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 88,
                            height: 88,
                            decoration: const BoxDecoration(
                              color: AppColors.cardPink,
                              shape: BoxShape.circle,
                            ),
                            child: avatarUrl != null && avatarUrl.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(44),
                                    child: Image.network(
                                      avatarUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Padding(
                                          padding: const EdgeInsets.all(22),
                                          child: SvgPicture.asset(
                                            'assets/icons/profile.svg',
                                            colorFilter: const ColorFilter.mode(
                                              AppColors.primary,
                                              BlendMode.srcIn,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  )
                                : Padding(
                                    padding: const EdgeInsets.all(22),
                                    child: SvgPicture.asset(
                                      'assets/icons/profile.svg',
                                      colorFilter: const ColorFilter.mode(
                                        AppColors.primary,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            email,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textMuted,
                            ),
                          ),
                          if (!isGuest && userId.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.cardPink.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Account ID: ${userId.length > 16 ? "${userId.substring(0, 16)}..." : userId}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Menu Items Container
                    Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.cardBorder),
                          boxShadow: AppColors.cardShadow,
                        ),
                        child: Column(
                          children: [
                            _buildMenuItem(
                              icon: Icons.assignment_outlined,
                              title: 'My Orders',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const OrderHistoryScreen(),
                                  ),
                                );
                              },
                            ),
                            _buildDivider(),
                            _buildMenuItem(
                              icon: Icons.location_on_outlined,
                              title: 'My Addresses',
                              onTap: () {
                                context.read<AddressCubit>().loadAddresses();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const AddressSelectionScreen(),
                                  ),
                                );
                              },
                            ),
                            _buildDivider(),
                            _buildMenuItem(
                              icon: Icons.favorite_outline_rounded,
                              title: 'My Favorites',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const WishlistScreen(),
                                  ),
                                );
                              },
                            ),
                            _buildDivider(),
                            _buildMenuItem(
                              icon: Icons.account_balance_wallet_outlined,
                              title: 'Wallet & Payments',
                              onTap: () {},
                            ),
                            _buildDivider(),
                            _buildMenuItem(
                              icon: Icons.settings_outlined,
                              title: 'Settings',
                              onTap: () {},
                            ),
                            _buildDivider(),
                            _buildMenuItem(
                              icon: Icons.help_outline_rounded,
                              title: 'Help & Support',
                              onTap: () {},
                            ),
                            _buildDivider(),
                            _buildMenuItem(
                              icon: Icons.info_outline_rounded,
                              title: 'About Us',
                              onTap: () {},
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Log Out Row
                    Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.cardBorder),
                          boxShadow: AppColors.cardShadow,
                        ),
                        child: ListTile(
                          leading: const Icon(
                            Icons.logout_rounded,
                            color: AppColors.discountRed,
                          ),
                          title: Text(
                            isGuest ? 'Sign In / Register' : 'Log Out',
                            style: TextStyle(
                              color: isGuest ? AppColors.primary : AppColors.discountRed,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          onTap: () {
                            if (isGuest) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const SignInScreen()),
                              );
                            } else {
                              _showLogoutDialog(context);
                            }
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textPrimary, size: 22),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: AppColors.textMuted,
      ),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, indent: 16, endIndent: 16, color: AppColors.cardBorder);
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out of FunFillers?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.discountRed,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AuthBloc>().add(SignOutRequested());
            },
            child: const Text('Log Out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
