import 'package:flutter/material.dart';
import '../widgets/custom_bottom_nav.dart';
import '../widgets/ambient_background.dart';
import 'home_screen.dart';
import 'analyze_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';

/// Main navigation shell — hosts bottom nav and page switching.
/// Tabs: HOME (0), KATALOG (1), PINDAI (2, center button), RIWAYAT (3), PROFIL (4)
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  void _onNavTap(int index) {
    setState(() => _currentIndex = index);
  }

  void _navigateToDeteksi() {
    setState(() => _currentIndex = 1); // Navigates to DETEKSI scanner tab (index 1)
  }

  void _navigateToRiwayat() {
    setState(() => _currentIndex = 2); // Navigates to RIWAYAT history tab (index 2)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AmbientBackground(
        child: IndexedStack(
          index: _currentIndex,
          children: [
            // 0: Home dashboard
            HomeScreen(
              onNavigateToDeteksi: _navigateToDeteksi,
              onNavigateToRiwayat: _navigateToRiwayat,
            ),
            // 1: Analyze screen (camera and file scanner)
            const AnalyzeScreen(),
            // 2: History list screen
            HistoryScreen(
              onNavigateToScan: _navigateToDeteksi,
            ),
            // 3: Profile & developer credits
            const ProfileScreen(),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }
}
