import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../../core/theme/app_colors.dart';

class BannerItemData {
  final String id;
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
    required this.id,
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

  List<BannerItemData> _banners = [];
  bool _isLoading = true;

  static const List<List<Color>> _gradientPresets = [
    [Color(0xFFFFFBEB), Color(0xFFFEF08A)],
    [Color(0xFFF0F9FF), Color(0xFFBAE6FD)],
    [Color(0xFFFDF2F8), Color(0xFFFBCFE8)],
    [Color(0xFFF0FDF4), Color(0xFFBBF7D0)],
  ];

  static const List<Color> _textPresets = [
    AppColors.primary,
    Color(0xFF0C4A6E),
    Color(0xFF831843),
    Color(0xFF14532D),
  ];

  static const List<Color> _badgeBgPresets = [
    Color(0xFFFEF3C7),
    Color(0xFFE0F2FE),
    Color(0xFFFCE7F3),
    Color(0xFFDCFCE7),
  ];

  static const List<Color> _badgeTextPresets = [
    Color(0xFF92400E),
    Color(0xFF0369A1),
    Color(0xFFBE185D),
    Color(0xFF15803D),
  ];

  static const List<BannerItemData> _fallbackBanners = [
    BannerItemData(
      id: 'fallback_1',
      title: 'Play\nLearn\nGrow',
      subtitle: 'Best Toys for a Brighter Tomorrow',
      badgeText: 'UP TO 40% OFF',
      buttonText: 'Shop Now',
      gradientColors: [Color(0xFFFFFBEB), Color(0xFFFEF08A)],
      textColor: AppColors.primary,
      badgeBgColor: Color(0xFFFEF3C7),
      badgeTextColor: Color(0xFF92400E),
      imageUrl: 'https://images.unsplash.com/photo-1587654780291-39c9404d746b?auto=format&fit=crop&w=500&q=80',
    ),
    BannerItemData(
      id: 'fallback_2',
      title: 'Outdoor\nFun &\nAdventure',
      subtitle: 'Get Ready for Active Play',
      badgeText: 'NEW ARRIVALS',
      buttonText: 'Explore Now',
      gradientColors: [Color(0xFFF0F9FF), Color(0xFFBAE6FD)],
      textColor: Color(0xFF0C4A6E),
      badgeBgColor: Color(0xFFE0F2FE),
      badgeTextColor: Color(0xFF0369A1),
      imageUrl: 'https://images.unsplash.com/photo-1566576721346-d4a3b4eaeb55?auto=format&fit=crop&w=500&q=80',
    ),
    BannerItemData(
      id: 'fallback_3',
      title: 'Creative &\nArts\nStudio',
      subtitle: 'Unleash Your Child\'s Imagination',
      badgeText: 'SPECIAL DEAL',
      buttonText: 'Grab Deal',
      gradientColors: [Color(0xFFFDF2F8), Color(0xFFFBCFE8)],
      textColor: Color(0xFF831843),
      badgeBgColor: Color(0xFFFCE7F3),
      badgeTextColor: Color(0xFFBE185D),
      imageUrl: 'https://images.unsplash.com/photo-1513542789411-b6a5d4f31634?auto=format&fit=crop&w=500&q=80',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fetchBannersFromBackend();
  }

  Future<void> _fetchBannersFromBackend() async {
    try {
      final response = await http
          .get(Uri.parse('${ApiConstants.baseUrl}/ui/banners'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body) as List<dynamic>;
        final List<BannerItemData> fetched = [];

        for (int i = 0; i < list.length; i++) {
          final item = list[i] as Map<String, dynamic>;
          final bool isActive = item['isActive'] as bool? ?? true;
          if (!isActive) continue;

          final rawImg = item['imageUrl']?.toString() ?? '';
          final sanitizedImg = ApiConstants.sanitizeImageUrl(rawImg);

          final presetIndex = i % _gradientPresets.length;
          fetched.add(BannerItemData(
            id: item['id']?.toString() ?? 'banner_$i',
            title: item['title']?.toString() ?? 'Special Offer',
            subtitle: item['subtitle']?.toString() ?? '',
            badgeText: item['tag']?.toString() ?? 'PROMO',
            buttonText: 'Shop Now',
            gradientColors: _gradientPresets[presetIndex],
            textColor: _textPresets[presetIndex],
            badgeBgColor: _badgeBgPresets[presetIndex],
            badgeTextColor: _badgeTextPresets[presetIndex],
            imageUrl: sanitizedImg,
          ));
        }

        if (mounted && fetched.isNotEmpty) {
          setState(() {
            _banners = fetched;
            _isLoading = false;
          });
          _startAutoPlay();
          return;
        }
      }
    } catch (_) {
      // Network fail — use fallbacks
    }

    if (mounted) {
      setState(() {
        _banners = _fallbackBanners;
        _isLoading = false;
      });
      _startAutoPlay();
    }
  }

  void _startAutoPlay() {
    _autoPlayTimer?.cancel();
    if (_banners.length <= 1) return;
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients && _banners.isNotEmpty) {
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
    if (_isLoading) {
      return Container(
        height: 190,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
        ),
      );
    }

    if (_banners.isEmpty) return const SizedBox.shrink();

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
              final hasContent = banner.title.trim().isNotEmpty || banner.subtitle.trim().isNotEmpty;

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    // ── 1. Full Slider Background Image ──────────────────────
                    Positioned.fill(
                      child: Image.network(
                        banner.imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        loadingBuilder: (_, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            color: AppColors.inputBackground,
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                                strokeWidth: 2,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) => Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: banner.gradientColors,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.image_not_supported_rounded,
                              size: 44,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // ── 2. Gradient overlay for high text contrast ─────────
                    if (hasContent)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Colors.black.withValues(alpha: 0.65),
                                Colors.black.withValues(alpha: 0.25),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.55, 1.0],
                            ),
                          ),
                        ),
                      ),

                    // ── 3. Optional Overlay Text & Action Button ──────────────
                    if (hasContent)
                      Positioned.fill(
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (banner.badgeText.isNotEmpty) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    banner.badgeText,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                              ],
                              Text(
                                banner.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 19,
                                  fontWeight: FontWeight.w900,
                                  height: 1.1,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black54,
                                      blurRadius: 4,
                                      offset: Offset(0, 1),
                                    ),
                                  ],
                                ),
                              ),
                              if (banner.subtitle.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  banner.subtitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: widget.onBannerTap,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: AppColors.primary,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 6,
                                  ),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 2,
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
                      ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        // Indicator Dots
        if (_banners.length > 1)
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
