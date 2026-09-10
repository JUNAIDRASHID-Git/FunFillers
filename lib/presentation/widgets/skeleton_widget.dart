import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class ShimmerEffect extends StatefulWidget {
  final Widget child;
  final Color baseColor;
  final Color highlightColor;

  const ShimmerEffect({
    super.key,
    required this.child,
    this.baseColor = const Color(0xFFE2E8F0),
    this.highlightColor = const Color(0xFFF8FAFC),
  });

  @override
  State<ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: const [0.0, 0.5, 1.0],
              transform: _SlidingGradientTransform(slidePercent: _controller.value),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  final double slidePercent;
  const _SlidingGradientTransform({required this.slidePercent});

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * (slidePercent * 2 - 1), 0, 0);
  }
}

class SkeletonBox extends StatelessWidget {
  final double? width;
  final double? height;
  final double borderRadius;

  const SkeletonBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

// ── SKELETON PRESETS ─────────────────────────────────────────────────────────

class ProductCardSkeleton extends StatelessWidget {
  const ProductCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerEffect(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(19)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SkeletonBox(width: 120, height: 14, borderRadius: 4),
                  const SizedBox(height: 8),
                  const SkeletonBox(width: 80, height: 12, borderRadius: 4),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      SkeletonBox(width: 70, height: 16, borderRadius: 4),
                      SkeletonBox(width: 32, height: 32, borderRadius: 10),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductGridSkeleton extends StatelessWidget {
  final int itemCount;
  final double aspectRatio;

  const ProductGridSkeleton({
    super.key,
    this.itemCount = 6,
    this.aspectRatio = 0.72,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 220,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: aspectRatio,
      ),
      itemBuilder: (context, index) => const ProductCardSkeleton(),
    );
  }
}

class CarouselBannerSkeleton extends StatelessWidget {
  const CarouselBannerSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final bool isDesktop = screenWidth >= 900;
    final bool isTablet = screenWidth >= 600 && screenWidth < 900;

    final double maxBannerHeight = isDesktop ? 340.0 : isTablet ? 280.0 : 220.0;
    final double bannerAspectRatio = isDesktop ? 2.6 / 1 : isTablet ? 2.1 / 1 : 16 / 9;

    return ShimmerEffect(
      child: Container(
        constraints: BoxConstraints(maxHeight: maxBannerHeight),
        child: AspectRatio(
          aspectRatio: bannerAspectRatio,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ),
    );
  }
}

class CategoryCircleSkeleton extends StatelessWidget {
  const CategoryCircleSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerEffect(
      child: Padding(
        padding: const EdgeInsets.only(right: 14),
        child: Column(
          children: const [
            SkeletonBox(width: 58, height: 58, borderRadius: 29),
            SizedBox(height: 6),
            SkeletonBox(width: 48, height: 10, borderRadius: 4),
          ],
        ),
      ),
    );
  }
}

class CategoryListSkeleton extends StatelessWidget {
  const CategoryListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 8,
        itemBuilder: (context, index) => const CategoryCircleSkeleton(),
      ),
    );
  }
}

class ProductDetailsSkeleton extends StatelessWidget {
  const ProductDetailsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerEffect(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            SkeletonBox(width: double.infinity, height: 320, borderRadius: 24),
            SizedBox(height: 24),
            SkeletonBox(width: 200, height: 22, borderRadius: 6),
            SizedBox(height: 10),
            SkeletonBox(width: 140, height: 14, borderRadius: 4),
            SizedBox(height: 20),
            SkeletonBox(width: 100, height: 26, borderRadius: 6),
            SizedBox(height: 24),
            SkeletonBox(width: 120, height: 16, borderRadius: 4),
            SizedBox(height: 10),
            SkeletonBox(width: double.infinity, height: 80, borderRadius: 12),
          ],
        ),
      ),
    );
  }
}
