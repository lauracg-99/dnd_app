import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/firebase_auth_service.dart';
import '../../services/cloud_sync_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final FirebaseAuthService _authService = FirebaseAuthService();
  final CloudSyncService _syncService = CloudSyncService();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _isCreatingAccount = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In / Sign Up'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                
                // Cloud illustration
                Icon(
                  Icons.cloud,
                  size: 120,
                  color: Theme.of(context).primaryColor,
                ),
                
                const SizedBox(height: 32),
                
                // Title
                Text(
                  'Cloud Sync',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  'Sign in to sync your characters and journals across all your devices',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 48),
                
                // Email field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter your email address',
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                  enabled: !_isLoading,
                ),
                
                const SizedBox(height: 20),
                
                // Password field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                  enabled: !_isLoading,
                  onFieldSubmitted: (_) => _handleSubmit(),
                ),
                
                const SizedBox(height: 32),
                
                // Info text about account creation
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue.shade700,
                        size: 24,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'If you don\'t have an account yet, we\'ll create one for you automatically when you sign in.',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Submit button
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('Signing In...'),
                          ],
                        )
                      : const Text(
                          'Sign In',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
                
                const SizedBox(height: 24),
                
                // Cancel button
                OutlinedButton(
                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Features list
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'With Cloud Sync you can:',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ..._buildFeatureList(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFeatureList() {
    final features = [
      'Access your characters from any device',
      'Automatic backup of all your data',
      'Sync journals and character sheets',
      'Never lose your campaign data',
    ];
    
    return features.map((feature) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            size: 16,
            color: Colors.green.shade600,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              feature,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    )).toList();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      // Attempt to sign in (will create account if it doesn't exist)
      final result = await _authService.signInWithEmail(email, password);

      if (mounted) {
        if (result.success) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _isCreatingAccount 
                    ? 'Account created and signed in successfully!'
                    : 'Signed in successfully!',
              ),
              backgroundColor: Colors.green,
            ),
          );

          // Check if user has existing cloud data
          final hasCloudData = await _syncService.hasExistingCloudData();
          
          if (hasCloudData) {
            // Download existing data from cloud for returning users
            await _downloadExistingData();
          } else {
            // Upload existing data to cloud if this is a new account or user has no cloud data
            await _uploadExistingData();
          }
        } else {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.errorMessage!),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An unexpected error occurred: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _uploadExistingData() async {
    try {
      final result = await _syncService.uploadAllLocalData();
      if (mounted && !result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Warning: ${result.errorMessage}'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 4),
          ),
        );
      }
      // Navigate back after upload completes (regardless of success/failure)
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        // Don't show error for sync failure, just log it
        debugPrint('Error uploading existing data: $e');
        // Still navigate back on error
        Navigator.pop(context);
      }
    }
  }

  Future<void> _downloadExistingData() async {
    try {
      // Show loading message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Downloading your data from cloud...'),
            duration: Duration(seconds: 2),
          ),
        );
      }

      final result = await _syncService.downloadAllData();
      if (mounted) {
        if (result.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Data downloaded successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          // Trigger UI refresh on characters list after successful download
          // Use a small delay to ensure data is properly saved to local storage
          Future.delayed(const Duration(milliseconds: 500), () {
            // Force refresh of characters list when we return to it
            if (mounted) {
              // This will be picked up by the characters list screen's auth state listener
              // or when the screen rebuilds after navigation
              Navigator.pop(context);
            }
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not download cloud data: ${result.errorMessage}'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 4),
            ),
          );
          // Still navigate back even on download failure
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        // Don't show error for sync failure, just log it
        debugPrint('Error downloading existing data: $e');
        // Still navigate back on error
        Navigator.pop(context);
      }
    }
  }
}
