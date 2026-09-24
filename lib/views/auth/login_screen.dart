import 'package:dnd_app/l10n/app_localizations.dart';
import 'package:dnd_app/utils/snackbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/firebase_auth_service.dart';
import '../../services/cloud_sync_service.dart';
import '../../services/remote_config_service.dart';

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
  bool _allowSignIn = true;
  bool _allowRegister = true;

  @override
  void initState() {
    super.initState();
    // Read remote config flags (RemoteConfig initialized in main)
    try {
      _allowSignIn = RemoteConfigService.instance.allowSignIn;
      _allowRegister = RemoteConfigService.instance.allowRegister;
    } catch (_) {
      // Keep defaults true on error
      _allowSignIn = true;
      _allowRegister = true;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.signIn),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: AutofillGroup(
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
                    l10n.cloudSync,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  Text(
                    l10n.signInSyncDescription,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 48),

                  // Email field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.email],
                    decoration: InputDecoration(
                      labelText: l10n.email,
                      hintText: l10n.enterYourEmail,
                      prefixIcon: const Icon(Icons.email),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.pleaseEnterYourEmail;
                      }
                      if (!RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      ).hasMatch(value)) {
                        return l10n.pleaseEnterValidEmail;
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
                    autofillHints: const [AutofillHints.password],
                    decoration: InputDecoration(
                      labelText: l10n.password,
                      hintText: l10n.enterYourPassword,
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
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
                        return l10n.pleaseEnterYourPassword;
                      }
                      if (value.length < 6) {
                        return l10n.passwordMinLength;
                      }
                      return null;
                    },
                    enabled: !_isLoading,
                    onFieldSubmitted: (_) => _handleSubmit(),
                  ),

                  const SizedBox(height: 8),

                  // Forgot password link
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _isLoading ? null : _showForgotPasswordDialog,
                      child: Text(l10n.forgotPassword),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Info text about account creation / feature flags
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
                          !_allowRegister
                              ? l10n.accountCreationDisabled
                              : l10n.accountCreationInfo,
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
                    onPressed:
                        (_isLoading || !_allowSignIn) ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child:
                        _isLoading
                            ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(l10n.signingIn),
                              ],
                            )
                            : Text(
                              l10n.signIn,
                              style: const TextStyle(fontSize: 16),
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
                    child: Text(
                      l10n.cancel,
                      style: const TextStyle(fontSize: 16),
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
                          l10n.syncFeatureTitle,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        ..._buildFeatureList(l10n),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFeatureList(AppLocalizations l10n) {
    final features = [
      l10n.cloudSyncFeature1,
      l10n.cloudSyncFeature2,
      l10n.cloudSyncFeature3,
      l10n.cloudSyncFeature4,
    ];

    return features
        .map(
          (feature) => Padding(
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
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                  ),
                ),
              ],
            ),
          ),
        )
        .toList();
  }

  Future<void> _handleSubmit() async {
    // Check remote flags before attempting auth
    if (!RemoteConfigService.instance.allowSignIn) {
      SnackbarHelper.showInfo(
        context,
        AppLocalizations.of(context)!.signInTemporarilyDisabled,
      );
      return;
    }
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
          TextInput.finishAutofillContext();
          // Accedemos al usuario nativo de Firebase
          final user = result.user;
          bool isNewUser = false;

          if (user != null &&
              user.metadata.creationTime != null &&
              user.metadata.lastSignInTime != null) {
            // Si el tiempo de creación y de último login difieren por menos de un par de segundos, es una cuenta nueva
            final difference =
                user.metadata.lastSignInTime!
                    .difference(user.metadata.creationTime!)
                    .inSeconds
                    .abs();
            isNewUser = difference < 2;
          }
          // Show success message
          SnackbarHelper.showSuccess(
            context,
            isNewUser
                ? AppLocalizations.of(
                  context,
                )!.accountCreatedAndSignedInSuccessfully
                : AppLocalizations.of(context)!.signedInSuccessfully,
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
          SnackbarHelper.showError(
            context,
            result.errorMessage ??
                AppLocalizations.of(context)!.authenticationFailed,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        SnackbarHelper.showError(
          context,
          AppLocalizations.of(context)!.unexpectedError(e),
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
        SnackbarHelper.showWarning(
          context,
          AppLocalizations.of(
            context,
          )!.warningWithValue(result.errorMessage ?? ''),
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
        SnackbarHelper.showInfo(
          context,
          AppLocalizations.of(context)!.downloadingCloudData,
          duration: const Duration(seconds: 4),
        );
      }

      final result = await _syncService.downloadAllData();
      if (mounted) {
        if (result.success) {
          SnackbarHelper.showSuccess(
            context,
            AppLocalizations.of(context)!.dataSyncSuccessfully,
          );
        } else {
          SnackbarHelper.showError(
            context,
            AppLocalizations.of(
              context,
            )!.couldNotDownloadCloudData(result.errorMessage ?? ''),
          );
        }
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
        SnackbarHelper.showWarning(
          context,
          AppLocalizations.of(
            context,
          )!.couldNotDownloadCloudData(result.errorMessage ?? ''),
        );
        // Still navigate back even on download failure
        Navigator.pop(context);
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

  /// Show forgot password dialog
  void _showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder:
          (dialogContext) => _ForgotPasswordDialog(
            authService: _authService,
            initialEmail: _emailController.text,
            parentContext: context,
          ),
    );
  }
}

class _ForgotPasswordDialog extends StatefulWidget {
  final FirebaseAuthService authService;
  final String initialEmail;
  final BuildContext parentContext;

  const _ForgotPasswordDialog({
    required this.authService,
    required this.initialEmail,
    required this.parentContext,
  });

  @override
  State<_ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<_ForgotPasswordDialog> {
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.resetPassword),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppLocalizations.of(context)!.resetPasswordDescription),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.email,
              hintText: AppLocalizations.of(context)!.enterYourEmail,
              prefixIcon: const Icon(Icons.email),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        ElevatedButton(
          onPressed: () async {
            final email = _emailController.text.trim();

            if (email.isEmpty) {
              SnackbarHelper.showError(
                context,
                AppLocalizations.of(context)!.pleaseEnterEmailAddress,
              );
              return;
            }

            // Close dialog
            Navigator.pop(context);

            // Send password reset email
            final result = await widget.authService.resetPassword(email);

            if (widget.parentContext.mounted) {
              ScaffoldMessenger.of(widget.parentContext).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(
                        result.success ? Icons.check_circle : Icons.error,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          result.success
                              ? AppLocalizations.of(
                                widget.parentContext,
                              )!.passwordResetEmailSent
                              : result.errorMessage!,
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: result.success ? Colors.green : Colors.red,
                  duration: const Duration(seconds: 5),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          child: Text(AppLocalizations.of(context)!.sendResetLink),
        ),
      ],
    );
  }
}
