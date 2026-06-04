import 'dart:io';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/detection_result.dart';
import '../services/history_service.dart';
import '../widgets/frosted_container.dart';
import 'history_detail_screen.dart';
import 'main_shell.dart';

/// Screen displaying the list of past plant disease detections with frosted glass cards.
class HistoryScreen extends StatefulWidget {
  final VoidCallback? onNavigateToScan;

  const HistoryScreen({super.key, this.onNavigateToScan});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final HistoryService _historyService = HistoryService();
  List<DetectionResult> _historyList = [];
  bool _isLoading = true;
  String _selectedFilter = 'Semua';
  bool _isDescending = true; // True for newest first, false for oldest first

  @override
  void initState() {
    super.initState();
    _loadHistory();
    HistoryService.historyUpdateNotifier.addListener(_loadHistory);
  }

  @override
  void dispose() {
    HistoryService.historyUpdateNotifier.removeListener(_loadHistory);
    super.dispose();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    try {
      final data = await _historyService.getHistory();
      setState(() {
        _historyList = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal memuat riwayat: $e',
            style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: AppColors.darkGray,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFFBBF06A), width: 1.0),
          ),
        ),
      );
    }
  }

  void _toggleSort() {
    setState(() {
      _isDescending = !_isDescending;
    });
  }

  Future<void> _deleteItem(DetectionResult item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: AppColors.darkGray,
        title: const Text('Hapus Riwayat', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.white)),
        content: Text('Apakah Anda yakin ingin menghapus riwayat deteksi "${item.diseaseName}"?', style: const TextStyle(color: AppColors.textSecondary)),
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
      await _historyService.deleteResult(item.id);
      _loadHistory();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '"${item.diseaseName}" berhasil dihapus',
            style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: AppColors.darkGray,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFFBBF06A), width: 1.0),
          ),
        ),
      );
    }
  }

  Future<void> _clearAllHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: AppColors.darkGray,
        title: const Text('Kosongkan Riwayat', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.white)),
        content: const Text('Apakah Anda yakin ingin menghapus seluruh riwayat deteksi? Tindakan ini tidak dapat dibatalkan.', style: TextStyle(color: AppColors.textSecondary)),
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
            child: const Text('Bersihkan'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _historyService.clearHistory();
      _loadHistory();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Seluruh riwayat berhasil dikosongkan',
            style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: AppColors.darkGray,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFFBBF06A), width: 1.0),
          ),
        ),
      );
    }
  }

  List<DetectionResult> get _filteredAndSortedList {
    List<DetectionResult> list = [..._historyList];

    // Filter by type
    if (_selectedFilter != 'Semua') {
      list = list.where((item) => item.diseaseType == _selectedFilter).toList();
    }

    // Sort by date
    list.sort((a, b) {
      return _isDescending ? b.date.compareTo(a.date) : a.date.compareTo(b.date);
    });

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
      case 'Nematode':
        return AppColors.nematodeBadge;
      case 'Phytophthora':
        return AppColors.phytophthoraBadge;
      default:
        return AppColors.gray;
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
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
    final displayList = _filteredAndSortedList;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header custom matching figma back circle button ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      } else {
                        context.findAncestorStateOfType<MainShellState>()?.setIndex(0);
                      }
                    },
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
                      'Riwayat Deteksi',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                  if (_historyList.isNotEmpty)
                    TextButton.icon(
                      onPressed: _clearAllHistory,
                      icon: const Icon(Icons.delete_sweep_outlined, color: AppColors.virusBadge, size: 16),
                      label: const Text(
                        'Bersihkan',
                        style: TextStyle(
                          color: AppColors.virusBadge,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                ],
              ),
            ),

            // ── Filter Chips ──
            _buildFilterRow(),

            // ── Sort Bar ──
            if (!_isLoading && _historyList.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${displayList.length} Ditemukan',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    InkWell(
                      onTap: _toggleSort,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        child: Row(
                          children: [
                            const Text(
                              'Paling Terbaru',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFBBF06A),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              _isDescending ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                              size: 14,
                              color: const Color(0xFFBBF06A),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // ── Main Body (List / Empty / Loading) ──
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFBBF06A)),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadHistory,
                      color: const Color(0xFFBBF06A),
                      backgroundColor: AppColors.surface,
                      child: displayList.isEmpty
                          ? _buildEmptyState()
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                              physics: const BouncingScrollPhysics(),
                              itemCount: displayList.length,
                              itemBuilder: (context, index) {
                                final item = displayList[index];
                                return _buildHistoryCard(item);
                              },
                            ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterRow() {
    final filters = ['Semua', 'Virus', 'Pest', 'Healthy', 'Fungi', 'Bacteria', 'Nematode', 'Phytophthora'];

    return Container(
      height: 48,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter;
          Color activeColor = const Color(0xFFBBF06A);
          if (filter != 'Semua') {
            activeColor = _getTypeColor(filter);
          }

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                setState(() => _selectedFilter = filter);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? activeColor.withValues(alpha: 0.15) : AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isSelected ? activeColor : AppColors.lightGray.withValues(alpha: 0.6),
                    width: 1,
                  ),
                ),
                child: Text(
                  filter,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? activeColor : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    final hasNoHistoryAtAll = _historyList.isEmpty;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.6,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.mintGreen.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.history_toggle_off_rounded,
                size: 72,
                color: Color(0xFFBBF06A),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              hasNoHistoryAtAll ? 'Belum ada riwayat pendeteksian' : 'Tidak Ada Hasil Cocok',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasNoHistoryAtAll
                  ? 'Mulai analisis tanaman Anda menggunakan deteksi AI sekarang!'
                  : 'Cobalah mengubah filter kategori penyakit untuk melihat riwayat lain.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            if (hasNoHistoryAtAll && widget.onNavigateToScan != null) ...[
              const SizedBox(height: 24),
              // Premium gradient "Deteksi Sekarang" button
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: const LinearGradient(
                    colors: AppColors.buttonGradient,
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFBBF06A).withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                height: 44,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: widget.onNavigateToScan,
                    borderRadius: BorderRadius.circular(22),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.center_focus_strong_rounded, size: 18, color: Color(0xFF0F120D)),
                          SizedBox(width: 8),
                          Text(
                            'Deteksi Sekarang',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0F120D),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard(DetectionResult item) {
    return FrostedContainer(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.zero,
      borderRadius: 16,
      child: InkWell(
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => HistoryDetailScreen(result: item),
            ),
          );
          if (result == true) {
            _loadHistory();
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Leaf Crop image
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: AppColors.surface,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _buildImage(
                    item.imageUrl,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Title and Date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Disease Name
                    Text(
                      item.diseaseName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    // Subtitle "Kondisi: Kesehatan" or custom sub
                    Text(
                      item.diseaseName.toLowerCase() == 'healthy'
                          ? 'Kondisi: Sehat'
                          : 'Kondisi: Penyakit ${_formatDate(item.date)}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Delete Trash Icon next to chevron
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: AppColors.virusBadge, size: 20),
                onPressed: () => _deleteItem(item),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.gray),
            ],
          ),
        ),
      ),
    );
  }
}
