import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import '../services/tflite_service.dart';
import '../services/auth_service.dart';
import '../widgets/frosted_container.dart';
import 'information_screen.dart';
import 'login_screen.dart';
import 'main_shell.dart';

/// Profile page designed exactly matching Figma's specifications with frosted glass panels, about button, and onboarding reset.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _saved = false;
  String _displayName = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = await AuthService.getCurrentUser();
    if (mounted) {
      setState(() {
        _nameController.text = user['name'] ?? '';
        _emailController.text = user['email'] ?? '';
        _displayName = user['name'] ?? '';
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('potaleaf_onboarding_done', false);
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: AppColors.darkGray,
        title: const Text(
          'Onboarding Direset',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.white),
        ),
        content: const Text(
          'Splash onboarding akan ditampilkan kembali saat Anda membuka ulang aplikasi ini.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.limeAccent,
              foregroundColor: AppColors.charcoal,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _onSave() async {
    try {
      await AuthService.updateProfile(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
      );
      if (mounted) {
        setState(() {
          _saved = true;
          _displayName = _nameController.text.trim();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Profil berhasil disimpan!',
              style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
            ),
            backgroundColor: AppColors.darkGray,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AppColors.limeAccent, width: 1.0),
            ),
            duration: const Duration(seconds: 1),
          ),
        );
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) setState(() => _saved = false);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan profil: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> _onLogout() async {
    await AuthService.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Custom Header matching Frame 7
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
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
                          'Profil',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                      // Info developer icon - navigates to Information/About screen
                      IconButton(
                        icon: const Icon(Icons.info_outline_rounded, color: AppColors.white, size: 20),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const InformationScreen()),
                          );
                        },
                        tooltip: 'Informasi Pengembang',
                      ),
                      // Reset onboarding icon button - restores onboarding
                      IconButton(
                        icon: const Icon(Icons.restart_alt_rounded, color: AppColors.white, size: 20),
                        onPressed: _resetOnboarding,
                        tooltip: 'Reset Onboarding',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Tabby Cat Avatar with thick glowing lime border
                Center(
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          // Soft green glow behind avatar
                          Container(
                            width: 132,
                            height: 132,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFBBF06A).withValues(alpha: 0.25),
                                  blurRadius: 28,
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                          ),
                          // Profile Placeholder Icon Container
                          Container(
                            width: 114,
                            height: 114,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0x1AFFFFFF),
                              border: Border.all(
                                color: const Color(0x99BBF06A),
                                width: 3.0,
                              ),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.person_rounded,
                                size: 54,
                                color: AppColors.limeAccent,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _displayName.isNotEmpty ? _displayName : 'Pengguna PotaLeaf',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Frosted Glass Container Panel Wrapping Input Fields
                FrostedContainer(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Field 1: Name
                      _buildFieldLabel('Name'),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: 'Name',
                          filled: true,
                          fillColor: const Color(0x0AFFFFFF),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.transparent),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFBBF06A), width: 1.0),
                          ),
                        ),
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.white),
                      ),
                      const SizedBox(height: 16),

                      // Field 2: Gmail
                      _buildFieldLabel('Gmail'),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          hintText: 'Gmail',
                          filled: true,
                          fillColor: const Color(0x0AFFFFFF),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.transparent),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFBBF06A), width: 1.0),
                          ),
                        ),
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.white),
                      ),
                      const SizedBox(height: 24),

                      // Premium Gradient "Simpan" button (Left-to-Right orientation)
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: const LinearGradient(
                              colors: AppColors.buttonGradient,
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFBBF06A).withValues(alpha: 0.25),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          width: 100,
                          height: 38,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _onSave,
                              borderRadius: BorderRadius.circular(20),
                              child: Center(
                                child: Text(
                                  _saved ? '✓ Saved' : 'Simpan',
                                  style: const TextStyle(
                                    color: Color(0xFF0F120D),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Dynamic active TFLite model info frosted card
                const SizedBox(height: 16),
                FrostedContainer(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.psychology_outlined, color: Color(0xFFBBF06A), size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Model TFLite Aktif',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFBBF06A).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFBBF06A).withValues(alpha: 0.3), width: 0.6),
                        ),
                        child: Text(
                          TfliteService().activeModelName,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFBBF06A),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // premium "About" button replacing static credits (Left-to-Right orientation)
                const SizedBox(height: 28),
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(
                        colors: AppColors.buttonGradient,
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFBBF06A).withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    width: 120,
                    height: 38,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const InformationScreen()),
                          );
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: const Center(
                          child: Text(
                            'About',
                            style: TextStyle(
                              color: Color(0xFF0F120D),
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.virusBadge, width: 1.5),
                    ),
                    width: 120,
                    height: 38,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _onLogout,
                        borderRadius: BorderRadius.circular(20),
                        child: const Center(
                          child: Text(
                            'Keluar',
                            style: TextStyle(
                              color: AppColors.virusBadge,
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: AppColors.textSecondary,
      ),
    );
  }
}
