import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Soft gradient background with decorative colour blobs, used on every screen.
class AppBackground extends StatelessWidget {
  final Widget child;
  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final colors = dark
        ? const [Color(0xFF0E1124), Color(0xFF1A1646), Color(0xFF10223F)]
        : const [Color(0xFFE3EAFF), Color(0xFFF1EBFF), Color(0xFFFFEEF5)];

    return SizedBox.expand(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -70,
              right: -50,
              child: _Blob(
                size: 220,
                color: AppColors.purple.withValues(alpha: dark ? 0.22 : 0.16),
              ),
            ),
            Positioned(
              bottom: -80,
              left: -60,
              child: _Blob(
                size: 240,
                color: AppColors.primary.withValues(alpha: dark ? 0.22 : 0.14),
              ),
            ),
            Positioned.fill(child: child),
          ],
        ),
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  final double size;
  final Color color;
  const _Blob({required this.size, required this.color});

  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
      );
}
