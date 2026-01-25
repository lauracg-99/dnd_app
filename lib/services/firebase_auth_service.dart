import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Service for handling Firebase authentication
class FirebaseAuthService {
  static final FirebaseAuthService _instance = FirebaseAuthService._internal();
  factory FirebaseAuthService() => _instance;
  FirebaseAuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Stream controller for authentication state changes
  final StreamController<User?> _authStateController = StreamController<User?>.broadcast();
  
  /// Stream of authentication state changes
  Stream<User?> get authStateChanges => _authStateController.stream;
  
  /// Current authenticated user
  User? get currentUser => _auth.currentUser;
  
  /// Whether user is currently authenticated
  bool get isAuthenticated => currentUser != null;
  
  /// Initialize the authentication service
  Future<void> initialize() async {
    // Listen to Firebase auth state changes
    _auth.authStateChanges().listen((User? user) {
      _authStateController.add(user);
      if (kDebugMode) {
        print('Auth state changed: ${user?.email ?? "null"}');
      }
    });
  }
  
  /// Sign in with email and password
  /// If user doesn't exist, creates a new account
  Future<AuthResult> signInWithEmail(String email, String password) async {
    try {
      // Try to sign in first
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (kDebugMode) {
        print('Successfully signed in: ${credential.user?.email}');
      }
      
      return AuthResult.success(credential.user!);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        // User doesn't exist or wrong password, try to create account
        try {
          final credential = await _auth.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );
          
          if (kDebugMode) {
            print('Successfully created account: ${credential.user?.email}');
          }
          
          return AuthResult.success(credential.user!);
        } on FirebaseAuthException catch (createError) {
          if (kDebugMode) {
            print('Failed to create account: ${createError.message}');
          }
          return AuthResult.failure(_getErrorMessage(createError));
        }
      } else {
        if (kDebugMode) {
          print('Sign in error: ${e.message}');
        }
        return AuthResult.failure(_getErrorMessage(e));
      }
    } catch (e) {
      if (kDebugMode) {
        print('Unexpected error during sign in: $e');
      }
      return AuthResult.failure('An unexpected error occurred. Please try again.');
    }
  }
  
  /// Sign out the current user
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      if (kDebugMode) {
        print('Successfully signed out');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error signing out: $e');
      }
      rethrow;
    }
  }
  
  /// Get user-friendly error message from FirebaseAuthException
  String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'user-not-found':
        return 'No user found for this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Try again later.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled. Please enable them in Firebase console.';
      case 'invalid-credential':
        return 'The supplied auth credential is malformed or has expired. Please check your Firebase configuration.';
      default:
        return 'Authentication failed: ${e.message}';
    }
  }
  
  /// Dispose the service
  void dispose() {
    _authStateController.close();
  }
}

/// Result of authentication operation
class AuthResult {
  final bool success;
  final User? user;
  final String? errorMessage;
  
  AuthResult.success(this.user) : success = true, errorMessage = null;
  AuthResult.failure(this.errorMessage) : success = false, user = null;
  
  @override
  String toString() {
    if (success) {
      return 'AuthResult.success(user: ${user?.email})';
    } else {
      return 'AuthResult.failure(error: $errorMessage)';
    }
  }
}
