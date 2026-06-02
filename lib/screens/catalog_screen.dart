import 'dart:io';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/detection_result.dart';

/// Catalog screen displaying all plant disease templates in a responsive 2-column grid.
/// Supports real-time text search and category tab filtration.
class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'Semua';
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<DetectionResult> get _filteredItems {
    List<DetectionResult> list = DetectionResult.staticSamples;

    // Filter by category
    if (_selectedCategory != 'Semua') {
      list = list.where((item) => item.diseaseType == _selectedCategory).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      list = list
          .where((item) =>
              item.diseaseName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              item.diseaseType.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    return list;
  }

  Color _getTypeColor(String type) {
    switch (type) {
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

  /// Helper to render image from various sources (asset, file, or network)
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
    final displayItems = _filteredItems;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──
              const Text(
                'Katalog Penyakit',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Pelajari berbagai jenis penyakit tanaman dan solusinya',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),

              // ── Search Input ──
              TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: InputDecoration(
                  hintText: 'Cari nama penyakit...',
                  hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 13),
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.gray, size: 20),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                          child: const Icon(Icons.clear_rounded, color: AppColors.gray, size: 20),
                        )
                      : null,
                  filled: true,
                  fillColor: AppColors.surface,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: AppColors.lightGray.withValues(alpha: 0.5)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.limeAccent, width: 1.2),
                  ),
                ),
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 16),

              // ── Category Filters ──
              _buildCategoryFilters(),
              const SizedBox(height: 16),

              // ── Grid of Diseases ──
              Expanded(
                child: displayItems.isEmpty
                    ? _buildEmptyState()
                    : GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          childAspectRatio: 0.85,
                        ),
                        itemCount: displayItems.length,
                        itemBuilder: (context, index) {
                          final item = displayItems[index];
                          return _buildCatalogGridCard(item);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilters() {
    final categories = ['Semua', 'Virus', 'Pest', 'Healthy', 'Fungi', 'Bacteria'];

    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = _selectedCategory == cat;
          final Color badgeColor;
          if (cat == 'Semua') {
            badgeColor = AppColors.limeAccent;
          } else {
            badgeColor = _getTypeColor(cat);
          }

          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? badgeColor.withValues(alpha: 0.18)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? badgeColor.withValues(alpha: 0.8)
                      : AppColors.lightGray.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  cat,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected
                      ? badgeColor
                      : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCatalogGridCard(DetectionResult item) {
    final typeColor = _getTypeColor(item.diseaseType);

    return GestureDetector(
      onTap: () => _showDiseaseDialog(context, item),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.lightGray.withValues(alpha: 0.4), width: 0.8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail Image & Type Badge
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                      child: _buildImage(
                        item.imageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: typeColor.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.diseaseType,
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Card Text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.diseaseName,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Lihat Solusi →',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.limeAccent,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.lightGray.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.search_off_rounded, size: 40, color: AppColors.gray),
          ),
          const SizedBox(height: 12),
          const Text(
            'Tidak ada penyakit ditemukan',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 4),
          const Text(
            'Coba ketik kata kunci pencarian yang lain.',
            style: TextStyle(fontSize: 11, color: AppColors.textHint),
          ),
        ],
      ),
    );
  }

  void _showDiseaseDialog(BuildContext context, DetectionResult item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: AppColors.darkGray,
        title: Row(
          children: [
            const Icon(Icons.eco, color: AppColors.limeAccent, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                item.diseaseName,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.85,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _buildImage(
                    item.imageUrl,
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 14),
                _infoSection('Kategori', item.diseaseType),
                _infoSection('Gejala', item.gejala),
                _infoSection('Penyebab', item.penyebab),
                _infoSection('Cara Pencegahan', item.caraPencegahan),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup', style: TextStyle(color: AppColors.limeAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _infoSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text(content, style: const TextStyle(fontSize: 12, height: 1.5, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}
