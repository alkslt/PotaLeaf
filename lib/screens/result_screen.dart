import 'dart:io';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/detection_result.dart';
import '../widgets/frosted_container.dart';

/// High-Fidelity Result screen matching Figma's specifications with frosted glass and gradient save button.
class ResultScreen extends StatefulWidget {
  final DetectionResult result;

  const ResultScreen({super.key, required this.result});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  Color get _typeColor {
    switch (widget.result.diseaseType) {
      case 'Virus':
        return AppColors.virusBadge;
      case 'Pest':
        return AppColors.pestBadge;
      case 'Healthy':
        return AppColors.healthyBadge;
      case 'Fungi':
        return AppColors.fungiBadge;
      case 'Bacteria':
        return AppColors.bacteriaBadge;
      default:
        return AppColors.gray;
    }
  }

  String _getDiseaseDescription(String name) {
    switch (name.toLowerCase()) {
      case 'bacteria':
        return 'Penyakit bakteri pada daun kentang umumnya disebabkan oleh bakteri seperti Ralstonia solanacearum yang menyerang jaringan pembuluh tanaman dan menghambat distribusi air serta nutrisi. Penyakit ini dapat menyebabkan penurunan hasil panen secara signifikan.';
      case 'fungi':
        return 'Penyakit jamur (Fungi) pada kentang disebabkan oleh berbagai jenis cendawan seperti Alternaria solani atau Fusarium spp yang menyerang daun, batang, maupun umbi. Penyakit ini berkembang cepat pada kondisi lembab dan suhu yang sesuai.';
      case 'healthy':
        return 'Daun kentang sehat menunjukkan kondisi pertumbuhan normal tanpa adanya infeksi penyakit maupun serangan hama. Fotosintesis berlangsung optimal sehingga mendukung perkembangan umbi.';
      case 'nematode':
        return 'Nematoda merupakan cacing mikroskopis yang hidup di dalam tanah dan menyerang akar tanaman kentang. Serangan nematoda menghambat penyerapan air dan nutrisi sehingga pertumbuhan tanaman terganggu.';
      case 'pest':
        return 'Hama pada tanaman kentang merupakan organisme seperti serangga, ulat, kutu daun, atau belalang yang merusak jaringan daun dan mengganggu pertumbuhan tanaman.';
      case 'phytophthora':
        return 'Phytophthora atau Late Blight merupakan salah satu penyakit paling berbahaya pada kentang yang disebabkan oleh Phytophthora infestans. Penyakit ini dapat merusak dengan cepat pada kondisi dingin dan basah.';
      case 'virus':
        return 'Penyakit virus pada kentang disebabkan oleh berbagai jenis virus seperti Potato Virus Y (PVY) dan Potato Virus X (PVX). Virus dapat menurunkan kualitas dan produktivitas tanaman secara signifikan.';
      default:
        return 'Kondisi tanaman menunjukkan karakteristik tertentu. Lakukan pemantauan berkala dan berikan perawatan yang sesuai.';
    }
  }

  Widget _buildImage(String path, {double? width, double? height, BoxFit fit = BoxFit.cover}) {
    if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => Container(
          width: width,
          height: height,
          color: AppColors.mintGreen.withValues(alpha: 0.3),
          child: const Icon(Icons.broken_image_rounded, color: AppColors.darkGreen),
        ),
      );
    } else if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => Container(
          width: width,
          height: height,
          color: AppColors.mintGreen.withValues(alpha: 0.3),
          child: const Icon(Icons.broken_image_rounded, color: AppColors.darkGreen),
        ),
      );
    } else {
      return Image.file(
        File(path),
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => Container(
          width: width,
          height: height,
          color: AppColors.mintGreen.withValues(alpha: 0.3),
          child: const Icon(Icons.broken_image_rounded, color: AppColors.darkGreen),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.result;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Stack(
          children: [
            // ── Scrollable Body content ──
            Column(
              children: [
                // Header custom matching figma back circle button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppColors.darkGreen,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.arrow_back_ios_new_rounded, size: 14, color: AppColors.white),
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Text(
                          'Hasil Deteksi',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Main scrollable details
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 100), // padding bottom for float button
                    child: Column(
                      children: [
                        // Large Circular leaf image crop with glowing radial shadow backdrop
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            // Ambient radial glow behind circular image
                            Container(
                              width: 180,
                              height: 180,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: _typeColor.withValues(alpha: 0.3),
                                    blurRadius: 36,
                                    spreadRadius: 8,
                                  ),
                                ],
                              ),
                            ),
                            // Perfect circular crop of the leaf image
                            Container(
                              width: 160,
                              height: 160,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFFBBF06A).withValues(alpha: 0.4),
                                  width: 1.5,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(80),
                                child: _buildImage(
                                  result.imageUrl,
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Disease name in bold white
                        Text(
                          result.diseaseName,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: AppColors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),

                        // Subtitle: Akurasi : 95 %
                        Text(
                          'Akurasi : ${result.confidence.toStringAsFixed(0)} %',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFBBF06A),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Card 1: Deskripsi
                        _buildFrostedSection('Deskripsi', _getDiseaseDescription(result.diseaseName)),
                        const SizedBox(height: 14),

                        // Card 2: Gejala
                        _buildFrostedSection('Gejala', result.gejala),
                        const SizedBox(height: 14),

                        // Card 3: Penyebab
                        _buildFrostedSection('Penyebab', result.penyebab),
                        const SizedBox(height: 14),

                        // Card 4: Perawatan
                        _buildFrostedSection('Perawatan', result.caraPencegahan),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // ── Floating bottom right Simpan button ──
            Positioned(
              bottom: 24,
              right: 24,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: const LinearGradient(
                    colors: AppColors.buttonGradient,
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFBBF06A).withValues(alpha: 0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                width: 100,
                height: 44,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(24),
                    child: const Center(
                      child: Text(
                        'Simpan',
                        style: TextStyle(
                          color: Color(0xFF0F120D),
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFrostedSection(String title, String content) {
    return FrostedContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      borderRadius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
