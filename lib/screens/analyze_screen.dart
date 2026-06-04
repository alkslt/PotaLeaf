import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_colors.dart';
import '../models/detection_result.dart';
import '../services/history_service.dart';
import '../services/tflite_service.dart';
import '../widgets/scanner_overlay_painter.dart';
import '../widgets/frosted_container.dart';
import 'result_screen.dart';
import 'main_shell.dart';

/// Analyze screen matching Figma's specifications with frosted glass and gradient buttons.
class AnalyzeScreen extends StatefulWidget {
  const AnalyzeScreen({super.key});

  @override
  State<AnalyzeScreen> createState() => _AnalyzeScreenState();
}

class _AnalyzeScreenState extends State<AnalyzeScreen>
    with SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();

  XFile? _pickedFile;
  DetectionResult? _selectedSample;
  bool _isScanning = false;
  String _scanStatus = '';
  List<DetectionResult> _historyList = [];

  late AnimationController _scanAnimController;

  @override
  void initState() {
    super.initState();
    _scanAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _loadHistory();
    HistoryService.historyUpdateNotifier.addListener(_loadHistory);
  }

  @override
  void dispose() {
    HistoryService.historyUpdateNotifier.removeListener(_loadHistory);
    _scanAnimController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    try {
      final data = await HistoryService().getHistory();
      if (mounted) {
        setState(() {
          _historyList = data;
        });
      }
    } catch (_) {}
  }

  bool get _hasImage => _pickedFile != null || _selectedSample != null;

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

  Future<void> _pickImage(ImageSource source) async {
    try {
      final image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _pickedFile = image;
          _selectedSample = null;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal mengambil gambar: $e',
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

  void _showSamplePicker() {
    final samples = DetectionResult.staticSamples;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: AppColors.darkGray,
        title: const Text(
          'Pilih dari contoh penyakit',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.white),
        ),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.85,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: samples.length,
            itemBuilder: (context, index) {
              final sample = samples[index];
              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedSample = sample;
                    _pickedFile = null;
                  });
                  Navigator.pop(ctx);
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.lightGray.withValues(alpha: 0.5), width: 0.8),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: _buildImage(
                          sample.imageUrl,
                          width: 55,
                          height: 55,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sample.diseaseName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.white,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              sample.diseaseType,
                              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.check_circle_outline, color: Color(0xFFBBF06A), size: 18),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: AppColors.gray)),
          ),
        ],
      ),
    );
  }

  void _clearImage() {
    setState(() {
      _pickedFile = null;
      _selectedSample = null;
    });
  }

  Future<void> _startAnalysis() async {
    if (!_hasImage) return;

    setState(() {
      _isScanning = true;
      _scanStatus = 'Mempersiapkan gambar...';
    });
    _scanAnimController.repeat();

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      setState(() => _scanStatus = 'Menganalisis kondisi tanaman...');

      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      setState(() => _scanStatus = 'Mencocokkan pola penyakit...');

      final Map<String, dynamic> inferenceResult;
      if (_selectedSample != null) {
        inferenceResult = await TfliteService().classifyAsset(_selectedSample!.imageUrl);
      } else {
        inferenceResult = await TfliteService().classifyImage(File(_pickedFile!.path));
      }

      final String detectedLabel = inferenceResult['diseaseName'] as String;
      final double confidence = inferenceResult['confidence'] as double;
      final String imagePath = _selectedSample != null ? _selectedSample!.imageUrl : _pickedFile!.path;

      final DetectionResult finalResult = DetectionResult.fromClassification(
        detectedLabel: detectedLabel,
        confidence: confidence,
        customImagePath: imagePath,
        isLocalFile: _selectedSample == null,
      );

      await HistoryService().saveResult(finalResult);

      _scanAnimController.stop();
      setState(() => _isScanning = false);

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ResultScreen(result: finalResult)),
      );
    } catch (e) {
      _scanAnimController.stop();
      setState(() => _isScanning = false);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal menganalisis gambar: $e',
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

  @override
  Widget build(BuildContext context) {
    void activeBackAction() {
      if (_hasImage) {
        _clearImage();
      } else {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        } else {
          context.findAncestorStateOfType<MainShellState>()?.setIndex(0);
        }
      }
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Header ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: activeBackAction,
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
                      'Deteksi Penyakit',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: AppColors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Main scroll body ──
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Card 1: Ambil Gambar
                    FrostedContainer(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.camera_alt_rounded, color: AppColors.white, size: 18),
                              const SizedBox(width: 8),
                              const Text(
                                'Ambil Gambar',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            height: 44,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(22),
                              gradient: const LinearGradient(
                                colors: AppColors.buttonGradient,
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: _isScanning ? null : () => _pickImage(ImageSource.camera),
                                borderRadius: BorderRadius.circular(22),
                                child: const Center(
                                  child: Text(
                                    'Mulai Kamera',
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
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Card 2: Unggah Gambar dari Galeri (Container Preview Latching)
                    GestureDetector(
                      onTap: _isScanning
                          ? null
                          : () => _pickImage(ImageSource.gallery),
                      child: FrostedContainer(
                        width: double.infinity,
                        height: 240,
                        padding: EdgeInsets.zero,
                        borderRadius: 20,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            if (!_hasImage)
                              const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.cloud_upload_outlined, color: AppColors.textSecondary, size: 44),
                                  SizedBox(height: 12),
                                  Text(
                                    'Unggah Gambar dari Galeri',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              )
                            else
                              Positioned.fill(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: _selectedSample != null
                                      ? _buildImage(_selectedSample!.imageUrl)
                                      : _buildImage(_pickedFile!.path),
                                ),
                              ),

                            // Scanning laser animation overlay inside container
                            if (_isScanning)
                              Positioned.fill(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: AnimatedBuilder(
                                    animation: _scanAnimController,
                                    builder: (context, child) {
                                      return CustomPaint(
                                        painter: ScannerOverlayPainter(
                                          animationValue: _scanAnimController.value,
                                          cornerLength: 30,
                                          strokeWidth: 3,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),

                            // Loading state status text overlay
                            if (_isScanning)
                              Positioned(
                                bottom: 16,
                                left: 16,
                                right: 16,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.8),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFBBF06A)),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          _scanStatus,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.white,
                                            fontStyle: FontStyle.italic,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                            // Clear button overlay if image is loaded
                            if (_hasImage && !_isScanning)
                              Positioned(
                                top: 12,
                                right: 12,
                                child: GestureDetector(
                                  onTap: _clearImage,
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: const BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.close_rounded, color: Colors.white, size: 18),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Trigger Contoh Gambar directly
                    Center(
                      child: TextButton.icon(
                        onPressed: _isScanning ? null : _showSamplePicker,
                        icon: const Icon(Icons.photo_library_outlined, size: 16, color: Color(0xFFBBF06A)),
                        label: const Text(
                          'Gunakan Contoh Gambar',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFBBF06A),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Bottom main Analisis Penyakit button
                    Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(26),
                        gradient: _hasImage
                            ? const LinearGradient(
                                colors: AppColors.buttonGradient,
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              )
                            : null,
                        color: _hasImage ? null : AppColors.lightGray.withValues(alpha: 0.1),
                        border: _hasImage
                            ? null
                            : Border.all(
                                color: AppColors.lightGray.withValues(alpha: 0.3),
                                width: 1.0,
                              ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: (_hasImage && !_isScanning) ? _startAnalysis : null,
                          borderRadius: BorderRadius.circular(26),
                          child: Center(
                            child: _isScanning
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Color(0xFF0F120D),
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : Text(
                                    'Analisis Penyakit',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      color: _hasImage
                                          ? const Color(0xFF0F120D)
                                          : AppColors.white.withValues(alpha: 0.4),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Previous analysis images row
                    if (_historyList.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      const Text(
                        'Gambar Riwayat Analisis',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 70,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: _historyList.length,
                          itemBuilder: (context, index) {
                            final item = _historyList[index];
                            final isSelected = (_selectedSample?.imageUrl == item.imageUrl || _pickedFile?.path == item.imageUrl);
                            return GestureDetector(
                              onTap: () {
                                if (!_isScanning) {
                                  setState(() {
                                    if (item.imageUrl.startsWith('assets/')) {
                                      final sampleMatch = DetectionResult.staticSamples.firstWhere(
                                        (s) => s.imageUrl == item.imageUrl,
                                        orElse: () => item,
                                      );
                                      _selectedSample = sampleMatch;
                                      _pickedFile = null;
                                    } else {
                                      _pickedFile = XFile(item.imageUrl);
                                      _selectedSample = null;
                                    }
                                  });
                                }
                              },
                              child: Container(
                                margin: const EdgeInsets.only(right: 12),
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected ? AppColors.limeAccent : Colors.transparent,
                                    width: 2.0,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: _buildImage(
                                    item.imageUrl,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
