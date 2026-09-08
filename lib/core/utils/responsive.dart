import 'package:flutter/material.dart';

class Responsive extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const Responsive({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < 600;

  static bool isTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= 600 &&
      MediaQuery.sizeOf(context).width < 1024;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= 1024;

  static int getGridCrossAxisCount(BuildContext context, {int mobileCount = 2}) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= 1200) return 6;
    if (width >= 900) return 4;
    if (width >= 600) return 3;
    return mobileCount;
  }

  static double getGridChildAspectRatio(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= 1200) return 0.75;
    if (width >= 900) return 0.72;
    if (width >= 600) return 0.70;
    return 0.68;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= 1024 && desktop != null) {
      return desktop!;
    }
    if (width >= 600 && tablet != null) {
      return tablet!;
    }
    return mobile;
  }
}

class MaxWidthContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;

  const MaxWidthContainer({
    super.key,
    required this.child,
    this.maxWidth = 1240,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
          child: child,
        ),
      ),
    );
  }
}
