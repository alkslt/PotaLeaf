import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// High-Fidelity glassmorphic bottom navigation bar for PotaLeaf dark theme.
/// Tabs: HOME, DETEKSI, PINDAI (center), RIWAYAT, PROFIL
class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xB50C0F0A), // Translucent dark backing
            border: const Border(
              top: BorderSide(color: AppColors.lightGray, width: 0.8),
            ),
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 68,
              child: Row(
                children: [
                  _buildTab(0, Icons.home_outlined, Icons.home_rounded, 'HOME'),
                  _buildTab(1, Icons.search_rounded, Icons.search_rounded, 'DETEKSI'),
                  _buildTab(2, Icons.history_toggle_off_rounded, Icons.history_rounded, 'RIWAYAT'),
                  _buildTab(3, Icons.person_outline_rounded, Icons.person_rounded, 'PROFIL'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Standard nav tab item.
  Widget _buildTab(int index, IconData icon, IconData activeIcon, String label) {
    final isActive = currentIndex == index;
    final color = isActive ? AppColors.limeAccent : AppColors.textSecondary;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTap(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.limeAccent.withValues(alpha: 0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                isActive ? activeIcon : icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 9,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
