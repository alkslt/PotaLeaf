import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import '../models/detection_result.dart';
import '../services/history_service.dart';
import '../services/auth_service.dart';
import '../widgets/frosted_container.dart';
import 'history_detail_screen.dart';

/// Home dashboard matching the high-fidelity Figma UI design with frosted cards.
class HomeScreen extends StatefulWidget {
  final VoidCallback onNavigateToDeteksi;
  final VoidCallback onNavigateToRiwayat;

  const HomeScreen({
    super.key,
    required this.onNavigateToDeteksi,
    required this.onNavigateToRiwayat,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HistoryService _historyService = HistoryService();
  List<DetectionResult> _historyList = [];
  bool _isLoading = true;
  String _userName = 'Pengguna';

  String get _firstName {
    final trimmed = _userName.trim();
    if (trimmed.isEmpty) return 'Pengguna';
    return trimmed.split(' ').first;
  }

  @override
  void initState() {
    super.initState();
    _loadHistory();
    _loadUserName();
    HistoryService.historyUpdateNotifier.addListener(_loadHistory);
    AuthService.userUpdateNotifier.addListener(_loadUserName);
  }

  @override
  void dispose() {
    HistoryService.historyUpdateNotifier.removeListener(_loadHistory);
    AuthService.userUpdateNotifier.removeListener(_loadUserName);
    super.dispose();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('user_name') ?? 'Pengguna';
    if (mounted) {
      setState(() {
        _userName = name;
      });
    }
  }

  Future<void> _loadHistory() async {
    try {
      final data = await _historyService.getHistory();
      if (mounted) {
        setState(() {
          _historyList = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
    final samples = DetectionResult.staticSamples; // Show all 7 samples

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Greeting Header ──
                Text(
                  'Hi, $_firstName!',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Ayo cek kesehatan tanamanmu',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),

                // ── Card: Kenali Kondisi Tanamanmu ──
                FrostedContainer(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Subtitle
                      Row(
                        children: [
                          const Icon(Icons.eco_outlined, color: AppColors.white, size: 16),
                          const SizedBox(width: 6),
                          const Text(
                            'Kenali Kondisi Tanamanmu',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Category badges (all 7 categories)
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: [
                            _buildMiniBadge('Virus', AppColors.virusBadge),
                            _buildMiniBadge('Pest', AppColors.pestBadge),
                            _buildMiniBadge('Healthy', AppColors.healthyBadge),
                            _buildMiniBadge('Fungi', AppColors.fungiBadge),
                            _buildMiniBadge('Bacteria', AppColors.bacteriaBadge),
                            _buildMiniBadge('Nematode', AppColors.nematodeBadge),
                            _buildMiniBadge('Phytophthora', AppColors.phytophthoraBadge),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Horizontal grid of the 7 leaf examples
                      SizedBox(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: samples.length,
                          itemBuilder: (context, index) {
                            final item = samples[index];
                            return _buildLeafSampleCard(item);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // ── Section: Deteksi Penyakit Segera ──
                Row(
                  children: [
                    const Icon(Icons.search_rounded, color: AppColors.white, size: 18),
                    const SizedBox(width: 8),
                    const Text(
                      'Deteksi Penyakit Segera',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Premium Gradient capsule "Ambil Gambar" button
                Container(
                  width: double.infinity,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: const LinearGradient(
                      colors: AppColors.buttonGradient,
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFBBF06A).withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: widget.onNavigateToDeteksi,
                      borderRadius: BorderRadius.circular(24),
                      child: const Center(
                        child: Text(
                          'Ambil Gambar',
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
                const SizedBox(height: 32),

                // ── Section: Riwayat Deteksi ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.history_toggle_off_rounded, color: AppColors.white, size: 18),
                        const SizedBox(width: 8),
                        const Text(
                          'Riwayat Deteksi',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                    if (_historyList.isNotEmpty)
                      GestureDetector(
                        onTap: widget.onNavigateToRiwayat,
                        child: const Text(
                          'Lihat Semua',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFBBF06A),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                // Vertical Stack of History (latest 3 items)
                _isLoading
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFBBF06A)),
                          ),
                        ),
                      )
                    : _historyList.isEmpty
                        ? _buildHistoryPlaceholder()
                        : Column(
                            children: _historyList
                                .take(3)
                                .map((item) => _buildHistoryVerticalCard(item))
                                .toList(),
                          ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMiniBadge(String label, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 0.6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildLeafSampleCard(DetectionResult item) {
    return GestureDetector(
      onTap: () => _showDiseaseDialog(context, item),
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          color: const Color(0x14FFFFFF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.lightGray.withValues(alpha: 0.3),
            width: 0.6,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
                child: _buildImage(
                  item.imageUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              child: Text(
                item.diseaseName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryPlaceholder() {
    return FrostedContainer(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_toggle_off_rounded,
            color: AppColors.textSecondary,
            size: 32,
          ),
          SizedBox(height: 8),
          Text(
            'Belum ada riwayat pendeteksian',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryVerticalCard(DetectionResult item) {
    return FrostedContainer(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.zero,
      borderRadius: 16,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => HistoryDetailScreen(result: item),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Leaf Crop image
              Container(
                width: 56,
                height: 56,
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
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    // Subtitle "Kondisi"
                    Text(
                      item.diseaseName.toLowerCase() == 'healthy'
                          ? 'Kondisi: Sehat'
                          : 'Kondisi: Penyakit',
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

              // Right side details: accuracy & date
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${item.confidence.toStringAsFixed(0)}% Akurasi',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFBBF06A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(item.date),
                    style: const TextStyle(
                      fontSize: 9,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.gray),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }



  void _showDiseaseDialog(BuildContext context, DetectionResult item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: AppColors.darkGray,
        title: Row(
          children: [
            const Icon(Icons.eco_outlined, color: Color(0xFFBBF06A), size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                item.diseaseName,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
            child: const Text('Tutup', style: TextStyle(color: Color(0xFFBBF06A), fontWeight: FontWeight.bold)),
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
