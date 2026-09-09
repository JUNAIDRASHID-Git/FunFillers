import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class BannerItemData {
  final String title;
  final String subtitle;
  final String badgeText;
  final String buttonText;
  final List<Color> gradientColors;
  final Color textColor;
  final Color badgeBgColor;
  final Color badgeTextColor;
  final String imageUrl;

  const BannerItemData({
    required this.title,
    required this.subtitle,
    required this.badgeText,
    required this.buttonText,
    required this.gradientColors,
    required this.textColor,
    required this.badgeBgColor,
    required this.badgeTextColor,
    required this.imageUrl,
  });
}

class CarouselBannerWidget extends StatefulWidget {
  final VoidCallback? onBannerTap;

  const CarouselBannerWidget({
    super.key,
    this.onBannerTap,
  });

  @override
  State<CarouselBannerWidget> createState() => _CarouselBannerWidgetState();
}

class _CarouselBannerWidgetState extends State<CarouselBannerWidget> {
  late final PageController _pageController;
  int _currentPage = 0;
  Timer? _autoPlayTimer;

  late final List<BannerItemData> _banners;

  @override
  void initState() {
    super.initState();
    _banners = [
      const BannerItemData(
        title: 'Play\nLearn\nGrow',
        subtitle: 'Best Toys for a Brighter Tomorrow',
        badgeText: 'UP TO 40% OFF',
        buttonText: 'Shop Now',
        gradientColors: [Color(0xFFFFFBEB), Color(0xFFFEF08A)],
        textColor: AppColors.primary,
        badgeBgColor: Color(0xFFFEF3C7),
        badgeTextColor: Color(0xFF92400E),
        imageUrl:
            'https://images.unsplash.com/photo-1587654780291-39c9404d746b?auto=format&fit=crop&w=500&q=80',
      ),
      const BannerItemData(
        title: 'Outdoor\nFun &\nAdventure',
        subtitle: 'Get Ready for Active Play',
        badgeText: 'NEW ARRIVALS',
        buttonText: 'Explore Now',
        gradientColors: [Color(0xFFF0F9FF), Color(0xFFBAE6FD)],
        textColor: Color(0xFF0C4A6E),
        badgeBgColor: Color(0xFFE0F2FE),
        badgeTextColor: Color(0xFF0369A1),
        imageUrl:
            'https://images.unsplash.com/photo-1566576721346-d4a3b4eaeb55?auto=format&fit=crop&w=500&q=80',
      ),
      const BannerItemData(
        title: 'Creative &\nArts\nStudio',
        subtitle: 'Unleash Your Child\'s Imagination',
        badgeText: 'SPECIAL DEAL',
        buttonText: 'Grab Deal',
        gradientColors: [Color(0xFFFDF2F8), Color(0xFFFBCFE8)],
        textColor: Color(0xFF831843),
        badgeBgColor: Color(0xFFFCE7F3),
        badgeTextColor: Color(0xFFBE185D),
        imageUrl:
            'https://images.unsplash.com/photo-1513542789411-b6a5d4f31634?auto=format&fit=crop&w=500&q=80',
      ),
      const BannerItemData(
        title: 'Puzzles &\nBoard\nGames',
        subtitle: 'Family Fun Time for All Ages',
        badgeText: 'BUY 1 GET 1 50% OFF',
        buttonText: 'View All',
        gradientColors: [Color(0xFFF0FDF4), Color(0xFFBBF7D0)],
        textColor: Color(0xFF14532D),
        badgeBgColor: Color(0xFFDCFCE7),
        badgeTextColor: Color(0xFF15803D),
        imageUrl:
            'https://images.unsplash.com/photo-1610890716171-6b1bb98ffd09?auto=format&fit=crop&w=500&q=80',
      ),
    ];
    _pageController = PageController();
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients) {
        final nextPage = (_currentPage + 1) % _banners.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 190,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: _banners.length,
            itemBuilder: (context, index) {
              final banner = _banners[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: banner.gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.black.withValues(alpha: 0.06),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Badge Tag
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: banner.badgeBgColor,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              banner.badgeText,
                              style: TextStyle(
                                color: banner.badgeTextColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            banner.title,
                            style: TextStyle(
                              color: banner.textColor,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            banner.subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: banner.textColor.withValues(alpha: 0.8),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: widget.onBannerTap,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              banner.buttonText,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        banner.imageUrl,
                        width: 110,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          width: 110,
                          height: 120,
                          color: AppColors.primary.withValues(alpha: 0.1),
                          child: const Icon(
                            Icons.smart_toy_rounded,
                            size: 50,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        // Indicator Dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_banners.length, (index) {
            final isActive = _currentPage == index;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              height: 7,
              width: isActive ? 22 : 7,
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.primary
                    : AppColors.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }
}
