import 'package:flutter/material.dart';

class AnnouncementBarWidget extends StatelessWidget {
  final String text;
  final String bgColorHex;
  final String textColorHex;
  final VoidCallback? onTap;

  const AnnouncementBarWidget({
    super.key,
    required this.text,
    this.bgColorHex = '#6C5CE7',
    this.textColorHex = '#FFFFFF',
    this.onTap,
  });

  Color _parseHex(String hex, Color fallback) {
    try {
      String clean = hex.replaceAll('#', '').trim();
      if (clean.length == 6) clean = 'FF$clean';
      return Color(int.parse(clean, radix: 16));
    } catch (_) {
      return fallback;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (text.trim().isEmpty) return const SizedBox.shrink();

    final bg = _parseHex(bgColorHex, const Color(0xFF6C5CE7));
    final txtColor = _parseHex(textColorHex, Colors.white);

    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          boxShadow: [
            BoxShadow(
              color: bg.withValues(alpha: 0.3),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                text,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: txtColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.2,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.arrow_forward_ios_rounded, color: txtColor, size: 10),
          ],
        ),
      ),
    );
  }
}
