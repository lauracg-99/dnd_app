import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:dnd_app/services/remote_config_service.dart';

/// Service for handling Firebase authentication
class FirebaseAuthService {
  static final FirebaseAuthService _instance = FirebaseAuthService._internal();
  factory FirebaseAuthService() => _instance;
  FirebaseAuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream controller for authentication state changes
  final StreamController<User?> _authStateController =
      StreamController<User?>.broadcast();
  final Completer<User?> _initialAuthStateCompleter = Completer<User?>();
  StreamSubscription<User?>? _authStateSubscription;

  /// Stream of authentication state changes
  Stream<User?> get authStateChanges => _authStateController.stream;

  /// Current authenticated user
  User? get currentUser => _auth.currentUser;

  /// Whether user is currently authenticated
  bool get isAuthenticated => currentUser != null;

  /// Future that completes when the initial auth state is available
  Future<User?> get initialAuthState => _initialAuthStateCompleter.future;

  /// Initialize the authentication service
  Future<void> initialize() async {
    // Listen to Firebase auth state changes
    _authStateSubscription = _auth.authStateChanges().listen((User? user) {
      _authStateController.add(user);
      if (!_initialAuthStateCompleter.isCompleted) {
        _initialAuthStateCompleter.complete(user);
      }
      if (kDebugMode) {
        print('Auth state changed: ${user?.email ?? "null"}');
      }
    });
    // Wait for the initial auth state to be restored before continuing
    await initialAuthState;
  }

  /// Sign in with email and password
  /// If user doesn't exist, creates a new account
  Future<AuthResult> signInWithEmail(String email, String password) async {
    // Check remote config: allow sign in
    if (!RemoteConfigService.instance.allowSignIn) {
      return AuthResult.failure('Sign in is temporarily disabled.');
    }
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
        // If user not found, check remote config for registration
        if (!RemoteConfigService.instance.allowRegister) {
          return AuthResult.failure('Registration is disabled.');
        }
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
      return AuthResult.failure(
        'An unexpected error occurred. Please try again.',
      );
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

  /// Send password reset email to the user
  Future<AuthResult> resetPassword(String email) async {
    try {
      if (email.isEmpty) {
        return AuthResult.failure('Please enter your email address');
      }

      if (kDebugMode) {
        print('Sending password reset email to: $email');
      }

      await _auth.sendPasswordResetEmail(email: email);

      if (kDebugMode) {
        print('Password reset email sent successfully');
      }

      return AuthResult.success(null);
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('Error sending password reset email: ${e.message}');
      }
      return AuthResult.failure(_getErrorMessage(e));
    } catch (e) {
      if (kDebugMode) {
        print('Unexpected error during password reset: $e');
      }
      return AuthResult.failure(
        'An unexpected error occurred. Please try again.',
      );
    }
  }

  /// Delete the current user account permanently
  /// This will delete the user's authentication account from Firebase
  /// Note: Cloud data (Firestore) must be deleted separately before calling this
  Future<AuthResult> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        if (kDebugMode) {
          print('No user logged in to delete');
        }
        return AuthResult.failure('No user is currently logged in');
      }

      if (kDebugMode) {
        print('Deleting account for user: ${user.email}');
      }

      await user.delete();

      if (kDebugMode) {
        print('Successfully deleted account');
      }

      return AuthResult.success(null);
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('Error deleting account: ${e.message}');
      }

      // Handle re-authentication required error
      if (e.code == 'requires-recent-login') {
        return AuthResult.failure(
          'For security reasons, please sign out and sign in again before deleting your account.',
        );
      }

      return AuthResult.failure(_getErrorMessage(e));
    } catch (e) {
      if (kDebugMode) {
        print('Unexpected error during account deletion: $e');
      }
      return AuthResult.failure(
        'An unexpected error occurred while deleting your account. Please try again.',
      );
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
    _authStateSubscription?.cancel();
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
