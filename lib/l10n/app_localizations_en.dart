// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'D&D';

  @override
  String get navCharacters => 'Characters';

  @override
  String get navDiaries => 'Diaries';

  @override
  String get navSpells => 'Spells';

  @override
  String get navInformation => 'Information';

  @override
  String get signIn => 'Sign In';

  @override
  String get createCharacter => 'Create Character';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get retry => 'Retry';

  @override
  String get unknown => 'Unknown';

  @override
  String get language => 'Language';

  @override
  String get languageWarningTitle => 'Language change';

  @override
  String get languageWarningMessage =>
      'Changing to Spanish will switch the app language, but some resources such as spell information may still remain in English.';

  @override
  String get continueLabel => 'Continue';

  @override
  String get english => 'English';

  @override
  String get spanish => 'Español';

  @override
  String get signInBackupDescription =>
      'Sign in to backup your data and access it from anywhere';

  @override
  String get edit => 'Edit';

  @override
  String get diary => 'Diary';

  @override
  String get addToGroup => 'Add to a group';

  @override
  String get modifyGroup => 'Modify group';

  @override
  String get removeFromGroup => 'Remove from group';

  @override
  String get delete => 'Delete';

  @override
  String get downloadChanges => 'Download Changes';

  @override
  String get downloadChangesDescription =>
      'Changes from other devices are available. Download them now?\n\nThis will replace your local data with the latest changes from the cloud.';

  @override
  String get download => 'Download';

  @override
  String get cloudSyncOptions => 'Cloud Sync Options';

  @override
  String signedInAs(Object email) {
    return 'Signed in as: $email';
  }

  @override
  String get syncNow => 'Sync Now';

  @override
  String get syncNowDescription => 'Upload all local changes to cloud';

  @override
  String get downloadFromCloud => 'Download from Cloud';

  @override
  String get downloadFromCloudDescription =>
      'Replace local data with cloud data';

  @override
  String get signOutAndDisableCloudSync => 'Sign out and disable cloud sync';

  @override
  String get deleteAccountAndCloudData =>
      'Permanently delete your account and all cloud data';

  @override
  String get confirmSync => 'Confirm Sync';

  @override
  String get confirmSyncDescription =>
      'This sync will permanently change the data from the cloud. Are you sure you want to continue?';

  @override
  String get syncLabel => 'Sync';

  @override
  String get deleteAccountQuestion => 'Delete Account?';

  @override
  String get deleteAccountWarningTitle => 'This will permanently delete:';

  @override
  String get deleteAccountWarningAccount => '• Your account';

  @override
  String get deleteAccountWarningCharacters => '• All cloud-synced characters';

  @override
  String get deleteAccountWarningDiaries => '• All cloud-synced diaries';

  @override
  String get deleteAccountWarningNote =>
      'Note: Local data on this device will NOT be deleted.';

  @override
  String get deleteAccountWarningPermanent => 'This action cannot be undone.';

  @override
  String get accountDeletionConfirmationTitle => 'Are you absolutely sure?';

  @override
  String get accountDeletionConfirmationMessage =>
      'Your account and all cloud data will be permanently deleted. This action cannot be undone.\n\nDo you want to proceed?';

  @override
  String get deleteMyAccount => 'Delete My Account';

  @override
  String get deletingAccount => 'Deleting account...';

  @override
  String failedToDeleteCloudData(Object error) {
    return 'Failed to delete cloud data: $error';
  }

  @override
  String get accountDeletedSuccessfully => 'Account deleted successfully';

  @override
  String failedToDeleteAccount(Object error) {
    return 'Failed to delete account: $error';
  }

  @override
  String errorDeletingAccount(Object error) {
    return 'Error deleting account: $error';
  }

  @override
  String get changesDownloadedSuccessfully =>
      'Changes downloaded successfully!';

  @override
  String get accountCreatedAndSignedInSuccessfully =>
      'Account created and signed in successfully!';

  @override
  String get signedInSuccessfully => 'Signed in successfully!';

  @override
  String get authenticationFailed => 'Authentication failed';

  @override
  String unexpectedError(Object error) {
    return 'An unexpected error occurred: $error';
  }

  @override
  String warningWithValue(Object message) {
    return 'Warning: $message';
  }

  @override
  String get signOut => 'Sign Out';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get signedOutSuccessfully => 'Signed out successfully';

  @override
  String errorSigningOut(Object error) {
    return 'Error signing out: $error';
  }

  @override
  String downloadFailed(Object error) {
    return 'Download failed: $error';
  }

  @override
  String downloadError(Object error) {
    return 'Download error: $error';
  }

  @override
  String get castingTime => 'Casting Time';

  @override
  String get range => 'Range';

  @override
  String get components => 'Components';

  @override
  String get duration => 'Duration';

  @override
  String get ritual => 'Ritual';

  @override
  String get yes => 'Yes';

  @override
  String get descriptionLabel => 'Description';

  @override
  String get atHigherLevels => 'At Higher Levels';

  @override
  String get dndCharacters => 'D&D Characters';

  @override
  String get searchCharacters => 'Search characters...';

  @override
  String get createFirstCharacter =>
      'No characters found. Create your first character!';

  @override
  String get syncAcrossDevices => 'Sync Across Devices';

  @override
  String get characterDiaries => 'Character Diaries';

  @override
  String get noCharactersFoundDiary =>
      'No characters found.\nCreate your first character to start writing diaries!';

  @override
  String get goToCharacters => 'Go to Characters';

  @override
  String get information => 'Information';

  @override
  String get feats => 'Feats';

  @override
  String get classes => 'Classes';

  @override
  String get races => 'Races';

  @override
  String get weapons => 'Weapons';

  @override
  String get backgrounds => 'Backgrounds';

  @override
  String get dndSpells => 'D&D Spells';

  @override
  String get filterSpells => 'Filter spells';

  @override
  String get searchSpells => 'Search spells...';

  @override
  String get levelFilter => 'Level:';

  @override
  String get classFilter => 'Class:';

  @override
  String get schoolFilter => 'School:';

  @override
  String get all => 'All';

  @override
  String get cantrip => 'Cantrip';

  @override
  String levelLabel(Object level) {
    return 'Level $level';
  }

  @override
  String get error => 'Error';

  @override
  String get noSpellsFound =>
      'No spells found. Try adjusting your search or filters.';

  @override
  String get cloudSync => 'Cloud Sync';

  @override
  String get signInSyncDescription =>
      'Sign in to sync your characters and journals across all your devices';

  @override
  String get email => 'Email';

  @override
  String get enterYourEmail => 'Enter your email address';

  @override
  String get pleaseEnterYourEmail => 'Please enter your email';

  @override
  String get pleaseEnterValidEmail => 'Please enter a valid email';

  @override
  String get password => 'Password';

  @override
  String get enterYourPassword => 'Enter your password';

  @override
  String get pleaseEnterYourPassword => 'Please enter your password';

  @override
  String get passwordMinLength => 'Password must be at least 6 characters';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get accountCreationDisabled =>
      'Account creation is temporarily disabled. Please sign in with an existing account or try again later.';

  @override
  String get accountCreationInfo =>
      'If you don\'t have an account yet, we\'ll create one for you automatically when you sign in.';

  @override
  String get signingIn => 'Signing In...';

  @override
  String get syncFeatureTitle => 'With Cloud Sync you can:';

  @override
  String get cloudSyncFeature1 => 'Access your characters from any device';

  @override
  String get cloudSyncFeature2 => 'Automatic backup of all your data';

  @override
  String get cloudSyncFeature3 => 'Sync journals and character sheets';

  @override
  String get cloudSyncFeature4 => 'Never lose your campaign data';

  @override
  String get signInTemporarilyDisabled =>
      'Sign in is temporarily disabled. Please try again later or contact support.';

  @override
  String get downloadingCloudData => 'Downloading your data from cloud...';

  @override
  String get dataSyncSuccessfully => 'Data sync successfully!';

  @override
  String couldNotDownloadCloudData(Object error) {
    return 'Could not download cloud data: $error';
  }

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get resetPasswordDescription =>
      'Enter your email address and we\'ll send you a link to reset your password.';

  @override
  String get sendResetLink => 'Send Reset Link';

  @override
  String get pleaseEnterEmailAddress => 'Please enter your email address';

  @override
  String get passwordResetEmailSent =>
      'Password reset email sent! Check your inbox (or spam folder).';

  @override
  String get createNewCharacter => 'Create New Character';

  @override
  String get fillCharacterDetails =>
      'Fill in the details below to create your character';

  @override
  String get characterName => 'Character Name';

  @override
  String get characterNameRequired => 'Character name is required';

  @override
  String get characterLevel => 'Character Level';

  @override
  String validLevelRange(Object min, Object max) {
    return 'Please enter a valid level between $min and $max';
  }
}
