import 'dart:ui';
import 'package:flutter/material.dart';

/// Premium Frosted Glassmorphism card container.
/// Uses BackdropFilter locally to blur glowing background circles underneath it.
class FrostedContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double? width;
  final double? height;
  final BoxBorder? border;

  const FrostedContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.borderRadius = 20,
    this.width,
    this.height,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 18,
            spreadRadius: -4,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              // Semitransparent white/lime base to give that premium frosted sheen
              color: const Color(0x14FFFFFF),
              borderRadius: BorderRadius.circular(borderRadius),
              border: border ?? Border.all(
                color: const Color(0x1F86A46A), // Translucent green-white border matching Figma
                width: 1.2,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
