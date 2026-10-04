import 'package:flutter/material.dart';
import '../theme/filmbase_theme.dart';

class GlowBackdrop extends StatelessWidget {
  final Color color;
  final bool fromRight;

  const GlowBackdrop({
    super.key,
    this.color = FilmbaseColors.accent,
    this.fromRight = true,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: -120,
      left: fromRight ? null : -50,
      right: fromRight ? -50 : null,
      child: Container(
        width: 280,
        height: 280,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.10),
        ),
      ),
    );
  }
}

class GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const GlassIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: FilmbaseColors.hairline),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: FilmbaseColors.text, size: 20),
        onPressed: onPressed,
      ),
    );
  }
}

class ScreenHeader extends StatelessWidget {
  final String title;
  final bool showBack;
  final List<Widget>? actions;

  const ScreenHeader({
    super.key,
    required this.title,
    this.showBack = false,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        children: [
          if (showBack) ...[
            GlassIconButton(
              icon: Icons.arrow_back_ios_new_rounded,
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(width: 14),
          ],
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: FilmbaseColors.text,
                letterSpacing: -0.6,
              ),
            ),
          ),
          if (actions != null) ...actions!,
        ],
      ),
    );
  }
}

class SurfaceCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final BorderRadius? radius;

  const SurfaceCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.radius,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = radius ?? BorderRadius.circular(18);
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: FilmbaseColors.surface,
        borderRadius: borderRadius,
        border: Border.all(color: FilmbaseColors.hairline),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          child: padding == null ? child : Padding(padding: padding!, child: child),
        ),
      ),
    );
  }
}
