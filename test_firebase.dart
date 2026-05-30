import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'lib/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    if (kDebugMode) {
      print('✅ Firebase initialized successfully');
    }

    // Test Firebase Auth
    final auth = FirebaseAuth.instance;
    if (kDebugMode) {
      print('✅ Firebase Auth available');
    }
    // Check current user
    final user = auth.currentUser;
    if (kDebugMode) {
      print('📱 Current user: ${user?.email ?? "Not signed in"}');
    }

    // Test sign in with dummy credentials to see the exact error
    try {
      await auth.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password123',
      );
    } catch (e) {
      if (kDebugMode) {
        print('🔍 Sign in test error: $e');
      }
      if (e is FirebaseAuthException) {
        if (kDebugMode) {
          print('🔍 Error code: ${e.code}');
          print('🔍 Error message: ${e.message}');
        }
      }
    }
  } catch (e) {
    if (kDebugMode) {
      print('❌ Firebase initialization error: $e');
    }
  }
}
