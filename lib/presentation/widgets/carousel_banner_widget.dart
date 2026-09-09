import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';
import '../../core/constants/api_constants.dart';
import '../../core/theme/app_colors.dart';

class BannerItemData {
  final String id;
  final String imageUrl;
  final String mediaType; // 'image' or 'video'

  const BannerItemData({
    required this.id,
    required this.imageUrl,
    this.mediaType = 'image',
  });

  bool get isVideo {
    if (mediaType == 'video') return true;
    final lower = imageUrl.toLowerCase();
    return lower.endsWith('.mp4') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.webm') ||
        lower.endsWith('.mkv');
  }
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

  static const List<BannerItemData> _fallbackBanners = [
    BannerItemData(
      id: 'fallback_1',
      imageUrl:
          'https://images.unsplash.com/photo-1587654780291-39c9404d746b?auto=format&fit=crop&w=1200&q=80',
      mediaType: 'image',
    ),
    BannerItemData(
      id: 'fallback_2',
      imageUrl:
          'https://images.unsplash.com/photo-1566576721346-d4a3b4eaeb55?auto=format&fit=crop&w=1200&q=80',
      mediaType: 'image',
    ),
    BannerItemData(
      id: 'fallback_3',
      imageUrl:
          'https://images.unsplash.com/photo-1513542789411-b6a5d4f31634?auto=format&fit=crop&w=1200&q=80',
      mediaType: 'image',
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
          final type = item['mediaType']?.toString() ?? 'image';

          if (sanitizedImg.isNotEmpty) {
            fetched.add(BannerItemData(
              id: item['id']?.toString() ?? 'banner_$i',
              imageUrl: sanitizedImg,
              mediaType: type,
            ));
          }
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
      // Network fail — fall back to curated sample banners
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
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_pageController.hasClients && _banners.isNotEmpty) {
        final nextPage = (_currentPage + 1) % _banners.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 600),
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
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: AppColors.inputBackground,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 2,
            ),
          ),
        ),
      );
    }

    if (_banners.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        // ── 16:9 Aspect Ratio Carousel Slider ────────────────────────────────
        AspectRatio(
          aspectRatio: 16 / 9,
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
              return GestureDetector(
                onTap: widget.onBannerTap,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: banner.isVideo
                      ? _CarouselVideoPlayer(videoUrl: banner.imageUrl)
                      : Image.network(
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
                            color: AppColors.inputBackground,
                            child: const Center(
                              child: Icon(
                                Icons.image_not_supported_rounded,
                                size: 48,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                        ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),

        // ── Indicator Dots ──────────────────────────────────────────────────
        if (_banners.length > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_banners.length, (index) {
              final isActive = _currentPage == index;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                height: 7,
                width: isActive ? 24 : 7,
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.primary
                      : AppColors.primary.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
      ],
    );
  }
}

/// Helper widget to play looping video inside the 16:9 carousel banner
class _CarouselVideoPlayer extends StatefulWidget {
  final String videoUrl;

  const _CarouselVideoPlayer({required this.videoUrl});

  @override
  State<_CarouselVideoPlayer> createState() => _CarouselVideoPlayerState();
}

class _CarouselVideoPlayerState extends State<_CarouselVideoPlayer> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    final sanitized = ApiConstants.sanitizeImageUrl(widget.videoUrl);
    final controller = VideoPlayerController.networkUrl(Uri.parse(sanitized));

    _controller = controller
      ..setLooping(true)
      ..setVolume(0.0);

    try {
      await controller.initialize();
      if (mounted) {
        setState(() => _isInitialized = true);
        controller.play();
      }
    } catch (_) {
      // Graceful error fallback
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitialized && _controller != null) {
      return FittedBox(
        fit: BoxFit.cover,
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          width: _controller!.value.size.width > 0
              ? _controller!.value.size.width
              : 16.0,
          height: _controller!.value.size.height > 0
              ? _controller!.value.size.height
              : 9.0,
          child: VideoPlayer(_controller!),
        ),
      );
    }

    return Container(
      color: AppColors.inputBackground,
      child: const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
          strokeWidth: 2,
        ),
      ),
    );
  }
}
