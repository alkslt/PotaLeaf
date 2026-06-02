import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/ambient_background.dart';

/// Immersive high-fidelity Information Screen matching Figma's "Infromation Page" perfectly.
class InformationScreen extends StatelessWidget {
  const InformationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AmbientBackground(
        child: SafeArea(
          child: Stack(
            children: [
              // ── Main Scrollable Content ──
              Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 48),

                      // Logo Image from assets matching Figma
                      Image.asset(
                        'assets/logo/logo_potaleaf.png',
                        width: 200,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => const Text(
                          'PotaLeaf',
                          style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.w900,
                            fontStyle: FontStyle.italic,
                            color: AppColors.limeAccent,
                            letterSpacing: 2.0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 36),

                      // Immersive Description Paragraph
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'Aplikasi deteksi penyakit daun kentang berbasis Artificial Intelligence yang dapat mengidentifikasi jenis penyakit melalui citra daun secara cepat dan mudah.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                            height: 1.6,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 72),

                      // Section Title: Pengembang
                      const Text(
                        'Pengembang',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: AppColors.limeAccent,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Developer Name
                      const Text(
                        'Alya Massardi',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // College
                      Text(
                        'Politeknik Negeri Sriwijaya',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white.withValues(alpha: 0.7),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Major
                      Text(
                        'Jurusan Teknik Komputer',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white.withValues(alpha: 0.7),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ),

              // ── Top Left Floating Dark Back Button ──
              Positioned(
                top: 12,
                left: 20,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0x33FFFFFF), // Frosted/translucent dark button
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0x1F86A46A),
                        width: 1.0,
                      ),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 16,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
