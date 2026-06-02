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

  late AnimationController _scanAnimController;

  @override
  void initState() {
    super.initState();
    _scanAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
  }

  @override
  void dispose() {
    _scanAnimController.dispose();
    super.dispose();
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
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: _hasImage ? _buildScanningPreviewState() : _buildLandingPickerState(),
      ),
    );
  }

  /// State 1: Picking Options Layout matching Figma Analyze Page
  Widget _buildLandingPickerState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text(
            'Deteksi Penyakit',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.white,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 24),

          // Card 1: Ambil Gambar (Frosted Glass)
          FrostedContainer(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.camera_alt_rounded, color: AppColors.white, size: 22),
                    const SizedBox(width: 12),
                    const Text(
                      'Ambil Gambar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Gradient capsule Mulai button
                Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(26),
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
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _pickImage(ImageSource.camera),
                      borderRadius: BorderRadius.circular(26),
                      child: const Center(
                        child: Text(
                          'Mulai',
                          style: TextStyle(
                            color: Color(0xFF0F120D),
                            fontSize: 15,
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
          const SizedBox(height: 20),

          // Card 2: Unggah Gambar dari Galeri (Frosted Glass)
          GestureDetector(
            onTap: () => _pickImage(ImageSource.gallery),
            child: FrostedContainer(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: const Column(
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
              ),
            ),
          ),
          const Spacer(),

          // Small Link for Examples
          Center(
            child: TextButton.icon(
              onPressed: _showSamplePicker,
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
          const SizedBox(height: 16),

          // Footer: Disabled Analisis Penyakit button (represented beautifully as frosted outline card)
          Container(
            width: double.infinity,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.lightGray.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: AppColors.lightGray.withValues(alpha: 0.3),
                width: 1.0,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              'Analisis Penyakit',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.white.withValues(alpha: 0.4),
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  /// State 2: Camera scan active stream preview with target corner brackets overlay
  Widget _buildScanningPreviewState() {
    return Column(
      children: [
        // Top Custom Header matching Frame 5
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              // Circular Green Back Button
              GestureDetector(
                onTap: _clearImage,
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ambil Gambar',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.white,
                      ),
                    ),
                    const Text(
                      'Posisikan dengan sejajar',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Live/Selected Leaf scan preview with corner bracket overlay
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Stack(
              children: [
                // Rounded corner leaf preview
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: _selectedSample != null
                        ? _buildImage(_selectedSample!.imageUrl)
                        : _buildImage(_pickedFile!.path),
                  ),
                ),

                // Corner bracket paint overlay
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: AnimatedBuilder(
                      animation: _scanAnimController,
                      builder: (context, child) {
                        return CustomPaint(
                          painter: ScannerOverlayPainter(
                            animationValue: _scanAnimController.value,
                            cornerLength: 36,
                            strokeWidth: 4,
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Scanning transparent loader bar
                if (_isScanning)
                  Positioned(
                    bottom: 24,
                    left: 24,
                    right: 24,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFBBF06A)),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _scanStatus,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.white,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Scanner Footer: Camera shutter button, cancel thumbnail
        Padding(
          padding: const EdgeInsets.only(left: 36, right: 36, bottom: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left: Refresh/Cancel icon
              if (!_isScanning)
                IconButton(
                  onPressed: _clearImage,
                  icon: const Icon(Icons.refresh_rounded, color: AppColors.white, size: 24),
                )
              else
                const SizedBox(width: 48),

              // Center: Circular camera trigger shutter button (starts analysis) with linear gradient
              GestureDetector(
                onTap: _isScanning ? null : _startAnalysis,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: _isScanning
                        ? null
                        : const LinearGradient(
                            colors: AppColors.buttonGradient,
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                    color: _isScanning ? AppColors.surface : null,
                    shape: BoxShape.circle,
                    boxShadow: _isScanning
                        ? null
                        : [
                            BoxShadow(
                              color: const Color(0xFFBBF06A).withValues(alpha: 0.35),
                              blurRadius: 14,
                              offset: const Offset(0, 3),
                            ),
                          ],
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    color: Color(0xFF0F120D),
                    size: 28,
                  ),
                ),
              ),

              // Right: Thumbnail of the gallery/chosen item
              GestureDetector(
                onTap: _isScanning ? null : _showSamplePicker,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.white.withValues(alpha: 0.6), width: 1.2),
                    color: AppColors.surface,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(7),
                    child: _selectedSample != null
                        ? _buildImage(_selectedSample!.imageUrl)
                        : _pickedFile != null
                            ? _buildImage(_pickedFile!.path)
                            : const Icon(Icons.photo_library_outlined, size: 16, color: AppColors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
