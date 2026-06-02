import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/app_theme.dart';
import 'screens/welcome_screen.dart';
import 'screens/main_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PotaLeafApp());
}

class PotaLeafApp extends StatefulWidget {
  const PotaLeafApp({super.key});

  @override
  State<PotaLeafApp> createState() => _PotaLeafAppState();
}

class _PotaLeafAppState extends State<PotaLeafApp> {
  bool _showOnboarding = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    final done = prefs.getBool('potaleaf_onboarding_done') ?? false;
    setState(() {
      _showOnboarding = !done;
      _isLoading = false;
    });
  }

  void _onOnboardingFinished() {
    setState(() {
      _showOnboarding = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PotaLeaf',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: _isLoading
          ? const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            )
          : _showOnboarding
              ? WelcomeScreen(onFinished: _onOnboardingFinished)
              : const MainShell(),
    );
  }
}
