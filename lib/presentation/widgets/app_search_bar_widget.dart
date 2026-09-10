import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class AppSearchBarWidget extends StatelessWidget {
  final String hintText;
  final VoidCallback? onTap;
  final bool readOnly;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final bool showBackButton;
  final VoidCallback? onBackTap;

  const AppSearchBarWidget({
    super.key,
    this.hintText = 'Search teddy bear, rc car...',
    this.onTap,
    this.readOnly = false,
    this.controller,
    this.onChanged,
    this.onClear,
    this.showBackButton = false,
    this.onBackTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (showBackButton) ...[
          GestureDetector(
            onTap: onBackTap ?? () => Navigator.maybePop(context),
            child: Container(
              height: 52,
              width: 52,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: Color(0xFF334155),
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 10),
        ],
        Expanded(
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.search_rounded,
                    color: Color(0xFF475569),
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: readOnly || onTap != null
                        ? Text(
                            hintText,
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 14.5,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )
                        : TextField(
                            controller: controller,
                            onChanged: onChanged,
                            autofocus: true,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              hintText: hintText,
                              hintStyle: const TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 14.5,
                                fontWeight: FontWeight.w500,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                  ),
                  if (!readOnly && controller != null && controller!.text.isNotEmpty)
                    GestureDetector(
                      onTap: onClear,
                      child: const Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Icon(
                          Icons.clear_rounded,
                          color: Color(0xFF94A3B8),
                          size: 20,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
