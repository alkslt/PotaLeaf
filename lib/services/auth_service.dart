import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  AuthService._();

  static bool isFirebaseInitialized = false;

  /// Initialize Firebase with a try-catch block for safe fallback
  static Future<void> init() async {
    try {
      await Firebase.initializeApp();
      isFirebaseInitialized = true;
      if (kDebugMode) {
        print("Firebase initialized successfully.");
      }
    } catch (e) {
      isFirebaseInitialized = false;
      if (kDebugMode) {
        print("Firebase initialization failed (using offline fallback mode): $e");
      }
    }
  }

  /// Register user with Email, Password and Name
  static Future<Map<String, String>?> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    if (isFirebaseInitialized) {
      try {
        final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );
        if (credential.user != null) {
          await credential.user!.updateDisplayName(name.trim());
          await credential.user!.reload();
          final updatedUser = FirebaseAuth.instance.currentUser;
          
          final userData = {
            'uid': updatedUser?.uid ?? '',
            'name': name.trim(),
            'email': email.trim(),
          };
          await _cacheUserLocally(userData);
          return userData;
        }
      } catch (e) {
        rethrow;
      }
    } else {
      // Mock Fallback mode
      final prefs = await SharedPreferences.getInstance();
      
      // Save to registered users list to support proper login checks
      final usersJson = prefs.getString('mock_users') ?? '{}';
      final users = Map<String, dynamic>.from(jsonDecode(usersJson));
      
      if (users.containsKey(email.trim().toLowerCase())) {
        throw FirebaseAuthException(
          code: 'email-already-in-use',
          message: 'The email address is already in use by another account.',
        );
      }
      
      final mockUid = 'mock_uid_${DateTime.now().millisecondsSinceEpoch}';
      users[email.trim().toLowerCase()] = {
        'uid': mockUid,
        'name': name.trim(),
        'email': email.trim(),
        'password': password, // strictly for mock verification
      };
      
      await prefs.setString('mock_users', jsonEncode(users));
      
      final userData = {
        'uid': mockUid,
        'name': name.trim(),
        'email': email.trim(),
      };
      await _cacheUserLocally(userData);
      return userData;
    }
    return null;
  }

  /// Login user with Email and Password
  static Future<Map<String, String>?> logIn({
    required String email,
    required String password,
  }) async {
    if (isFirebaseInitialized) {
      try {
        final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );
        if (credential.user != null) {
          final user = credential.user!;
          final userData = {
            'uid': user.uid,
            'name': user.displayName ?? 'Pengguna PotaLeaf',
            'email': user.email ?? email.trim(),
          };
          await _cacheUserLocally(userData);
          return userData;
        }
      } catch (e) {
        rethrow;
      }
    } else {
      // Mock Fallback mode
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString('mock_users') ?? '{}';
      final users = Map<String, dynamic>.from(jsonDecode(usersJson));
      
      final cleanEmail = email.trim().toLowerCase();
      if (!users.containsKey(cleanEmail)) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'No user found for that email.',
        );
      }
      
      final storedUser = users[cleanEmail] as Map<String, dynamic>;
      if (storedUser['password'] != password) {
        throw FirebaseAuthException(
          code: 'wrong-password',
          message: 'Wrong password provided for that user.',
        );
      }
      
      final userData = {
        'uid': storedUser['uid'] as String,
        'name': storedUser['name'] as String,
        'email': storedUser['email'] as String,
      };
      await _cacheUserLocally(userData);
      return userData;
    }
    return null;
  }

  /// Sign In with Google (SSO)
  static Future<Map<String, String>?> signInWithGoogle() async {
    if (isFirebaseInitialized) {
      try {
        final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
        if (googleUser == null) return null; // aborted

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final UserCredential userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);

        if (userCredential.user != null) {
          final user = userCredential.user!;
          final userData = {
            'uid': user.uid,
            'name': user.displayName ?? googleUser.displayName ?? 'Google User',
            'email': user.email ?? googleUser.email,
          };
          await _cacheUserLocally(userData);
          return userData;
        }
      } catch (e) {
        rethrow;
      }
    } else {
      // Mock Google SSO Fallback
      final userData = {
        'uid': 'mock_google_uid_${DateTime.now().millisecondsSinceEpoch}',
        'name': 'Google User Mock',
        'email': 'google_mock@potaleaf.com',
      };
      await _cacheUserLocally(userData);
      return userData;
    }
    return null;
  }

  /// Sign Out
  static Future<void> signOut() async {
    if (isFirebaseInitialized) {
      try {
        await FirebaseAuth.instance.signOut();
        await GoogleSignIn().signOut();
      } catch (_) {}
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_uid');
    await prefs.remove('user_name');
    await prefs.remove('user_email');
    await prefs.setBool('is_logged_in', false);
  }

  /// Cache active user details locally
  static Future<void> _cacheUserLocally(Map<String, String> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_uid', userData['uid'] ?? '');
    await prefs.setString('user_name', userData['name'] ?? '');
    await prefs.setString('user_email', userData['email'] ?? '');
    await prefs.setBool('is_logged_in', true);
  }

  /// Check if user is logged in
  static Future<bool> isLoggedIn() async {
    if (isFirebaseInitialized) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // sync to preferences just in case
        await _cacheUserLocally({
          'uid': user.uid,
          'name': user.displayName ?? 'Pengguna PotaLeaf',
          'email': user.email ?? '',
        });
        return true;
      }
    }
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_logged_in') ?? false;
  }

  /// Get locally cached user details
  static Future<Map<String, String>> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'uid': prefs.getString('user_uid') ?? '',
      'name': prefs.getString('user_name') ?? 'Pengguna PotaLeaf',
      'email': prefs.getString('user_email') ?? '',
    };
  }

  /// Update user profile locally and/or in firebase
  static Future<void> updateProfile({required String name, required String email}) async {
    if (isFirebaseInitialized) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.updateDisplayName(name);
        if (email.trim() != user.email) {
          await user.verifyBeforeUpdateEmail(email.trim());
        }
        await user.reload();
      }
    }
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
    await prefs.setString('user_email', email);

    // Also update in mock database if it exists
    if (!isFirebaseInitialized) {
      final currentUid = prefs.getString('user_uid') ?? '';
      final usersJson = prefs.getString('mock_users') ?? '{}';
      final users = Map<String, dynamic>.from(jsonDecode(usersJson));
      
      String? foundKey;
      Map<String, dynamic>? foundUser;
      
      users.forEach((key, val) {
        if (val['uid'] == currentUid) {
          foundKey = key;
          foundUser = Map<String, dynamic>.from(val);
        }
      });

      if (foundKey != null && foundUser != null) {
        users.remove(foundKey);
        foundUser!['name'] = name;
        foundUser!['email'] = email;
        users[email.toLowerCase().trim()] = foundUser!;
        await prefs.setString('mock_users', jsonEncode(users));
      }
    }
  }
}
