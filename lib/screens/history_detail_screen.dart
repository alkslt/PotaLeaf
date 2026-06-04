import 'dart:io';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/detection_result.dart';
import '../services/history_service.dart';


/// Detailed view of a past detection result with frosted glass cards.
class HistoryDetailScreen extends StatefulWidget {
  final DetectionResult result;

  const HistoryDetailScreen({super.key, required this.result});

  @override
  State<HistoryDetailScreen> createState() => _HistoryDetailScreenState();
}

class _HistoryDetailScreenState extends State<HistoryDetailScreen> {
  final HistoryService _historyService = HistoryService();

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
      case 'Nematode':
        return AppColors.nematodeBadge;
      case 'Phytophthora':
        return AppColors.phytophthoraBadge;
      default:
        return AppColors.gray;
    }
  }

  Future<void> _deleteResult() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: AppColors.darkGray,
        title: const Text('Hapus Deteksi', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.white)),
        content: const Text('Apakah Anda yakin ingin menghapus hasil analisis ini secara permanen dari riwayat?', style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal', style: TextStyle(color: AppColors.gray)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.virusBadge,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _historyService.deleteResult(widget.result.id);
      if (!mounted) return;
      Navigator.pop(context, true); // Pop back and refresh
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
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF0F120D), // Immersive dark solid background
      body: Stack(
        children: [
          // ── Background Leaf image on upper half ──
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: screenHeight * 0.48,
            child: Stack(
              fit: StackFit.expand,
              children: [
                _buildImage(result.imageUrl, fit: BoxFit.cover),
                // Smooth gradient overlay to transition to background charcoal
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.0, 0.35, 0.75, 1.0],
                      colors: [
                        Colors.black.withValues(alpha: 0.4),
                        Colors.transparent,
                        const Color(0xFF0F120D).withValues(alpha: 0.85),
                        const Color(0xFF0F120D),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Scrollable Diagnostic Cards ──
          Positioned.fill(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Spacer to push text content below upper image area
                  SizedBox(height: screenHeight * 0.24),

                  // Overlay Indicators
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Riwayat Deteksi',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: AppColors.white,
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Indikator Penyakit',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          result.diseaseName,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: _typeColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Solid Cards list
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        // Card 1: Gejala
                        _buildSolidSection('Gejala', result.gejala),
                        const SizedBox(height: 14),

                        // Card 2: Penyebab
                        _buildSolidSection('Penyebab', result.penyebab),
                        const SizedBox(height: 14),

                        // Card 3: Perawatan / Pencegahan
                        _buildSolidSection('Perawatan', result.caraPencegahan),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Circular Green Back Button on Top Left ──
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 20,
            child: GestureDetector(
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
          ),

          // ── Trash Icon on Top Right to Delete ──
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            right: 20,
            child: GestureDetector(
              onTap: _deleteResult,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.virusBadge),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSolidSection(String title, String content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1B201A), // Solid dark grey card background
        borderRadius: BorderRadius.circular(16),
      ),
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
          const SizedBox(height: 10),
          Text(
            content,
            style: const TextStyle(
              fontSize: 12.5,
              color: Color(0xFF9EAA98), // Muted green-gray text color
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
