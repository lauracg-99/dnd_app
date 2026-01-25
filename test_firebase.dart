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
    print('✅ Firebase initialized successfully');
    
    // Test Firebase Auth
    final auth = FirebaseAuth.instance;
    print('✅ Firebase Auth available');
    
    // Check current user
    final user = auth.currentUser;
    print('📱 Current user: ${user?.email ?? "Not signed in"}');
    
    // Test sign in with dummy credentials to see the exact error
    try {
      await auth.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password123',
      );
    } catch (e) {
      print('🔍 Sign in test error: $e');
      if (e is FirebaseAuthException) {
        print('🔍 Error code: ${e.code}');
        print('🔍 Error message: ${e.message}');
      }
    }
    
  } catch (e) {
    print('❌ Firebase initialization error: $e');
  }
}
