import 'dart:ui';
import 'package:flutter/material.dart';

/// Immersive green glowing ambient background for PotaLeaf high-fidelity screens.
class AmbientBackground extends StatelessWidget {
  final Widget child;

  const AmbientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Solid deep dark green-charcoal base from Figma
        Container(
          color: const Color(0xFF10130E),
        ),
        // Glow circle top right (soft warm olive)
        Positioned(
          top: -100,
          right: -80,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF5A7A3A).withValues(alpha: 0.22),
            ),
          ),
        ),
        // Glow circle bottom left (vibrant olive-lime)
        Positioned(
          bottom: -100,
          left: -80,
          child: Container(
            width: 440,
            height: 440,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF7B9C49).withValues(alpha: 0.18),
            ),
          ),
        ),
        // Glow circle center right (lime accent glow)
        Positioned(
          top: MediaQuery.of(context).size.height * 0.35,
          right: -150,
          child: Container(
            width: 340,
            height: 340,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFBBF06A).withValues(alpha: 0.10),
            ),
          ),
        ),
        // Blur filter to blend everything seamlessly
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 95, sigmaY: 95),
            child: Container(color: Colors.transparent),
          ),
        ),
        // The actual child screen content
        child,
      ],
    );
  }
}
