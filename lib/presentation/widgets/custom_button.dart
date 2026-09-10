import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isSecondary;
  final bool isOutlined;
  final bool isLoading;

  const CustomButton({
    super.key,
    String? text,
    String? label,
    this.onPressed,
    this.icon,
    this.isSecondary = false,
    this.isOutlined = false,
    this.isLoading = false,
  }) : text = text ?? label ?? '';

  @override
  Widget build(BuildContext context) {
    Color bg = onPressed == null
        ? AppColors.inputBackground
        : (isSecondary
            ? AppColors.primaryLight
            : (isOutlined ? Colors.transparent : AppColors.primary));
    Color fg = onPressed == null
        ? AppColors.textMuted
        : (isOutlined ? AppColors.primary : Colors.white);

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: fg,
        elevation: isOutlined ? 0 : 2,
        shadowColor: AppColors.primary.withValues(alpha: 0.25),
        minimumSize: const Size(double.infinity, 52),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: isOutlined
              ? const BorderSide(color: AppColors.primary, width: 1.5)
              : BorderSide.none,
        ),
      ),
      child: isLoading
          ? SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.5, color: fg),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20, color: fg),
                  const SizedBox(width: 8),
                ],
                Text(
                  text,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: fg,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
    );
  }
}
