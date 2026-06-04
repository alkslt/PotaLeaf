import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/app_theme.dart';
import 'screens/welcome_screen.dart';
import 'screens/main_shell.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService.init();
  runApp(const PotaLeafApp());
}

class PotaLeafApp extends StatefulWidget {
  const PotaLeafApp({super.key});

  @override
  State<PotaLeafApp> createState() => _PotaLeafAppState();
}

class _PotaLeafAppState extends State<PotaLeafApp> {
  bool _showOnboarding = true;
  bool _isLoggedIn = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAppStatus();
  }

  Future<void> _checkAppStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final done = prefs.getBool('potaleaf_onboarding_done') ?? false;
    final loggedIn = await AuthService.isLoggedIn();
    setState(() {
      _showOnboarding = !done;
      _isLoggedIn = loggedIn;
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
              backgroundColor: Color(0xFF0F120D),
              body: Center(
                child: CircularProgressIndicator(color: Color(0xFFBBF06A)),
              ),
            )
          : _showOnboarding
              ? WelcomeScreen(onFinished: _onOnboardingFinished)
              : _isLoggedIn
                  ? const MainShell()
                  : const LoginScreen(),
    );
  }
}
