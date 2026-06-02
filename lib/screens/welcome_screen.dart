import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import '../widgets/ambient_background.dart';

/// Premium 2-page onboarding / splash flow for PotaLeaf with ambient green glow.
class WelcomeScreen extends StatefulWidget {
  final VoidCallback onFinished;

  const WelcomeScreen({super.key, required this.onFinished});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('potaleaf_onboarding_done', true);
    widget.onFinished();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AmbientBackground(
        child: Stack(
          children: [
            // ── Page View ──
            PageView(
              controller: _pageController,
              onPageChanged: (index) => setState(() => _currentPage = index),
              children: [
                _buildPage(
                  child: _buildLogoSlide(),
                ),
                _buildPage(
                  child: _buildSelamatDatangSlide(),
                ),
              ],
            ),

            // ── Dot indicators ──
            Positioned(
              bottom: 90,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(2, (index) {
                  final isActive = _currentPage == index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    width: isActive ? 10 : 7,
                    height: isActive ? 10 : 7,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive
                          ? AppColors.white
                          : AppColors.white.withValues(alpha: 0.35),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: AppColors.white.withValues(alpha: 0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              )
                            ]
                          : null,
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage({required Widget child}) {
    return Center(
      child: SafeArea(child: child),
    );
  }

  /// Slide 1: Logo Centered in frame
  Widget _buildLogoSlide() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48),
        child: Image.asset(
          'assets/logo/logo_potaleaf.png',
          width: 240,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => const Text(
            'PotaLeaf',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
              color: AppColors.limeAccent,
              letterSpacing: 2.0,
            ),
          ),
        ),
      ),
    );
  }

  /// Slide 2: "Selamat Datang" centered with premium "Mulai" button at the bottom
  Widget _buildSelamatDatangSlide() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          const Spacer(flex: 3),
          const Text(
            'Selamat Datang',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w900,
              color: AppColors.white,
              letterSpacing: 0.8,
              height: 1.2,
            ),
          ),
          const Spacer(flex: 2),

          // Premium Gradient "Mulai" button
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: const LinearGradient(
                colors: AppColors.buttonGradient,
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFBBF06A).withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            width: double.infinity,
            height: 54,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _completeOnboarding,
                borderRadius: BorderRadius.circular(28),
                child: const Center(
                  child: Text(
                    'Mulai',
                    style: TextStyle(
                      color: Color(0xFF0F120D),
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 140),
        ],
      ),
    );
  }
}
