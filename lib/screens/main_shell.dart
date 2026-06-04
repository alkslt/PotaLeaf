import 'package:flutter/material.dart';
import '../widgets/custom_bottom_nav.dart';
import '../widgets/ambient_background.dart';
import '../theme/app_colors.dart';
import 'home_screen.dart';
import 'analyze_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';

/// Main navigation shell — hosts bottom nav and page switching.
/// Tabs: HOME (0), KATALOG (1), PINDAI (2, center button), RIWAYAT (3), PROFIL (4)
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => MainShellState();
}

class MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  void setIndex(int index) {
    setState(() => _currentIndex = index);
  }

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
    final isTablet = MediaQuery.of(context).size.width >= 600;

    final pagesStack = IndexedStack(
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
    );

    if (isTablet) {
      return Scaffold(
        body: Row(
          children: [
            SafeArea(
              right: false,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xB50C0F0A),
                  border: Border(
                    right: BorderSide(color: AppColors.lightGray, width: 0.8),
                  ),
                ),
                child: NavigationRail(
                  selectedIndex: _currentIndex,
                  onDestinationSelected: _onNavTap,
                  backgroundColor: Colors.transparent,
                  labelType: NavigationRailLabelType.all,
                  selectedLabelTextStyle: const TextStyle(
                    color: AppColors.limeAccent,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.6,
                  ),
                  unselectedLabelTextStyle: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.6,
                  ),
                  selectedIconTheme: const IconThemeData(color: AppColors.limeAccent, size: 24),
                  unselectedIconTheme: const IconThemeData(color: AppColors.textSecondary, size: 24),
                  indicatorColor: AppColors.limeAccent.withValues(alpha: 0.12),
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.home_outlined),
                      selectedIcon: Icon(Icons.home_rounded),
                      label: Text('HOME'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.search_rounded),
                      selectedIcon: Icon(Icons.search_rounded),
                      label: Text('DETEKSI'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.history_toggle_off_rounded),
                      selectedIcon: Icon(Icons.history_rounded),
                      label: Text('RIWAYAT'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.person_outline_rounded),
                      selectedIcon: Icon(Icons.person_rounded),
                      label: Text('PROFIL'),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: AmbientBackground(
                child: pagesStack,
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: AmbientBackground(
        child: pagesStack,
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }
}
