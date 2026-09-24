import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// Application title
  ///
  /// In en, this message translates to:
  /// **'D&D'**
  String get appTitle;

  /// Navigation item label for the Characters screen
  ///
  /// In en, this message translates to:
  /// **'Characters'**
  String get navCharacters;

  /// Navigation item label for the Diaries screen
  ///
  /// In en, this message translates to:
  /// **'Diaries'**
  String get navDiaries;

  /// Navigation item label for the Spells screen
  ///
  /// In en, this message translates to:
  /// **'Spells'**
  String get navSpells;

  /// Navigation item label for the Information screen
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get navInformation;

  /// Authentication action
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// Button label to create a character
  ///
  /// In en, this message translates to:
  /// **'Create Character'**
  String get createCharacter;

  /// Generic cancel action
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Generic save action
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Retry action
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Generic add action
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// Generic remove action
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// Fallback label for unknown values
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// Language selector label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Title of the warning dialog when switching to Spanish
  ///
  /// In en, this message translates to:
  /// **'Language change'**
  String get languageWarningTitle;

  /// Warning content shown before changing the app language to Spanish
  ///
  /// In en, this message translates to:
  /// **'Changing to Spanish will switch the app language, but some resources such as spell information may still remain in English.'**
  String get languageWarningMessage;

  /// Confirmation button in the locale warning dialog
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// English language option
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Spanish language option
  ///
  /// In en, this message translates to:
  /// **'Español'**
  String get spanish;

  /// Login callout text encouraging sign in for cloud sync
  ///
  /// In en, this message translates to:
  /// **'Sign in to backup your data and access it from anywhere'**
  String get signInBackupDescription;

  /// Section title for physical traits in character appearance
  ///
  /// In en, this message translates to:
  /// **'Physical Traits'**
  String get physicalTraits;

  /// Label for character height
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get height;

  /// Hint text for the height field
  ///
  /// In en, this message translates to:
  /// **'Enter height'**
  String get heightHint;

  /// Label for character age
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// Hint text for the age field
  ///
  /// In en, this message translates to:
  /// **'Enter age'**
  String get ageHint;

  /// Label for character eye color
  ///
  /// In en, this message translates to:
  /// **'Eye Color'**
  String get eyeColor;

  /// Hint text for the eye color field
  ///
  /// In en, this message translates to:
  /// **'Enter eye color'**
  String get eyeColorHint;

  /// Section title for character appearance details
  ///
  /// In en, this message translates to:
  /// **'Character Appereance'**
  String get characterAppearance;

  /// Helper text describing the character appearance editor
  ///
  /// In en, this message translates to:
  /// **'Describe the character\'s appearance, mannerisms, and notable details.'**
  String get describeCharacterAppearance;

  /// Placeholder text for the appearance description editor
  ///
  /// In en, this message translates to:
  /// **'Write a description of their appearance, clothing, expression, posture, and notable features...'**
  String get appearanceEditorPlaceholder;

  /// Edit action label
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Diary action label
  ///
  /// In en, this message translates to:
  /// **'Diary'**
  String get diary;

  /// Character action to add to a group
  ///
  /// In en, this message translates to:
  /// **'Add to a group'**
  String get addToGroup;

  /// Character action to edit a group
  ///
  /// In en, this message translates to:
  /// **'Modify group'**
  String get modifyGroup;

  /// Character action to remove a character from a group
  ///
  /// In en, this message translates to:
  /// **'Remove from group'**
  String get removeFromGroup;

  /// Delete action label
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Title for the cloud download confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Download Changes'**
  String get downloadChanges;

  /// Explanation for the cloud download confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Changes from other devices are available. Download them now?\n\nThis will replace your local data with the latest changes from the cloud.'**
  String get downloadChangesDescription;

  /// Download action label
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// Title for the cloud sync options sheet
  ///
  /// In en, this message translates to:
  /// **'Cloud Sync Options'**
  String get cloudSyncOptions;

  /// Subtitle showing the authenticated user email
  ///
  /// In en, this message translates to:
  /// **'Signed in as: {email}'**
  String signedInAs(Object email);

  /// Button label to upload local changes to the cloud
  ///
  /// In en, this message translates to:
  /// **'Sync Now'**
  String get syncNow;

  /// Subtitle for manual sync action
  ///
  /// In en, this message translates to:
  /// **'Upload all local changes to cloud'**
  String get syncNowDescription;

  /// Action to replace local data with cloud data
  ///
  /// In en, this message translates to:
  /// **'Download from Cloud'**
  String get downloadFromCloud;

  /// Subtitle for cloud download action
  ///
  /// In en, this message translates to:
  /// **'Replace local data with cloud data'**
  String get downloadFromCloudDescription;

  /// Subtitle for the sign out action
  ///
  /// In en, this message translates to:
  /// **'Sign out and disable cloud sync'**
  String get signOutAndDisableCloudSync;

  /// Subtitle for the account deletion action
  ///
  /// In en, this message translates to:
  /// **'Permanently delete your account and all cloud data'**
  String get deleteAccountAndCloudData;

  /// Title for the confirmation dialog before sync
  ///
  /// In en, this message translates to:
  /// **'Confirm Sync'**
  String get confirmSync;

  /// Confirmation text before uploading local data to the cloud
  ///
  /// In en, this message translates to:
  /// **'This sync will permanently change the data from the cloud. Are you sure you want to continue?'**
  String get confirmSyncDescription;

  /// Action label to confirm a sync
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get syncLabel;

  /// Title for the first account deletion confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Delete Account?'**
  String get deleteAccountQuestion;

  /// Heading for the account deletion warning
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete:'**
  String get deleteAccountWarningTitle;

  /// Account deletion warning item
  ///
  /// In en, this message translates to:
  /// **'• Your account'**
  String get deleteAccountWarningAccount;

  /// Account deletion warning item
  ///
  /// In en, this message translates to:
  /// **'• All cloud-synced characters'**
  String get deleteAccountWarningCharacters;

  /// Account deletion warning item
  ///
  /// In en, this message translates to:
  /// **'• All cloud-synced diaries'**
  String get deleteAccountWarningDiaries;

  /// Important note in the account deletion warning
  ///
  /// In en, this message translates to:
  /// **'Note: Local data on this device will NOT be deleted.'**
  String get deleteAccountWarningNote;

  /// Final warning sentence in the account deletion dialog
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get deleteAccountWarningPermanent;

  /// Title for the final account deletion confirmation
  ///
  /// In en, this message translates to:
  /// **'Are you absolutely sure?'**
  String get accountDeletionConfirmationTitle;

  /// Final account deletion confirmation message
  ///
  /// In en, this message translates to:
  /// **'Your account and all cloud data will be permanently deleted. This action cannot be undone.\n\nDo you want to proceed?'**
  String get accountDeletionConfirmationMessage;

  /// Final destructive action to delete the user account
  ///
  /// In en, this message translates to:
  /// **'Delete My Account'**
  String get deleteMyAccount;

  /// Loading text shown while the account is being deleted
  ///
  /// In en, this message translates to:
  /// **'Deleting account...'**
  String get deletingAccount;

  /// Error when cloud data cannot be deleted
  ///
  /// In en, this message translates to:
  /// **'Failed to delete cloud data: {error}'**
  String failedToDeleteCloudData(Object error);

  /// Success message after deleting an account
  ///
  /// In en, this message translates to:
  /// **'Account deleted successfully'**
  String get accountDeletedSuccessfully;

  /// Error when account deletion fails
  ///
  /// In en, this message translates to:
  /// **'Failed to delete account: {error}'**
  String failedToDeleteAccount(Object error);

  /// Exception raised while deleting an account
  ///
  /// In en, this message translates to:
  /// **'Error deleting account: {error}'**
  String errorDeletingAccount(Object error);

  /// Success message after downloading cloud changes
  ///
  /// In en, this message translates to:
  /// **'Changes downloaded successfully!'**
  String get changesDownloadedSuccessfully;

  /// Success message when a new account is created and signed in
  ///
  /// In en, this message translates to:
  /// **'Account created and signed in successfully!'**
  String get accountCreatedAndSignedInSuccessfully;

  /// Success message after sign in
  ///
  /// In en, this message translates to:
  /// **'Signed in successfully!'**
  String get signedInSuccessfully;

  /// Generic login failure message
  ///
  /// In en, this message translates to:
  /// **'Authentication failed'**
  String get authenticationFailed;

  /// Fallback error message for unexpected exceptions
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred: {error}'**
  String unexpectedError(Object error);

  /// Warning banner message with a dynamic value
  ///
  /// In en, this message translates to:
  /// **'Warning: {message}'**
  String warningWithValue(Object message);

  /// User sign out action
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// Delete user account action
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// Success message after signing out
  ///
  /// In en, this message translates to:
  /// **'Signed out successfully'**
  String get signedOutSuccessfully;

  /// Error message when signing out fails
  ///
  /// In en, this message translates to:
  /// **'Error signing out: {error}'**
  String errorSigningOut(Object error);

  /// Error message when cloud download fails
  ///
  /// In en, this message translates to:
  /// **'Download failed: {error}'**
  String downloadFailed(Object error);

  /// Exception message when a download operation throws
  ///
  /// In en, this message translates to:
  /// **'Download error: {error}'**
  String downloadError(Object error);

  /// Spell detail label for casting time
  ///
  /// In en, this message translates to:
  /// **'Casting Time'**
  String get castingTime;

  /// Spell detail label for range
  ///
  /// In en, this message translates to:
  /// **'Range'**
  String get range;

  /// Spell detail label for components
  ///
  /// In en, this message translates to:
  /// **'Components'**
  String get components;

  /// Spell detail label for duration
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// Spell detail label for ritual
  ///
  /// In en, this message translates to:
  /// **'Ritual'**
  String get ritual;

  /// Generic affirmative response
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// Spell detail label for description
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get descriptionLabel;

  /// Spell detail label for higher-level effects
  ///
  /// In en, this message translates to:
  /// **'At Higher Levels'**
  String get atHigherLevels;

  /// Title for the characters list screen
  ///
  /// In en, this message translates to:
  /// **'D&D Characters'**
  String get dndCharacters;

  /// Search field placeholder for characters
  ///
  /// In en, this message translates to:
  /// **'Search characters...'**
  String get searchCharacters;

  /// Empty state for character list
  ///
  /// In en, this message translates to:
  /// **'No characters found. Create your first character!'**
  String get createFirstCharacter;

  /// Callout title for cloud sync in character list
  ///
  /// In en, this message translates to:
  /// **'Sync Across Devices'**
  String get syncAcrossDevices;

  /// Title for the diaries overview screen
  ///
  /// In en, this message translates to:
  /// **'Character Diaries'**
  String get characterDiaries;

  /// Empty state for diaries overview
  ///
  /// In en, this message translates to:
  /// **'No characters found.\nCreate your first character to start writing diaries!'**
  String get noCharactersFoundDiary;

  /// Button to go back to characters from diary overview
  ///
  /// In en, this message translates to:
  /// **'Go to Characters'**
  String get goToCharacters;

  /// Title of the information screen
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get information;

  /// Category title for feats
  ///
  /// In en, this message translates to:
  /// **'Feats'**
  String get feats;

  /// Category title for classes
  ///
  /// In en, this message translates to:
  /// **'Classes'**
  String get classes;

  /// Category title for races
  ///
  /// In en, this message translates to:
  /// **'Races'**
  String get races;

  /// Category title for weapons
  ///
  /// In en, this message translates to:
  /// **'Weapons'**
  String get weapons;

  /// Category title for backgrounds
  ///
  /// In en, this message translates to:
  /// **'Backgrounds'**
  String get backgrounds;

  /// Search field placeholder for backgrounds
  ///
  /// In en, this message translates to:
  /// **'Search backgrounds...'**
  String get searchBackgrounds;

  /// Empty state for backgrounds list
  ///
  /// In en, this message translates to:
  /// **'No backgrounds found.'**
  String get noBackgroundsFound;

  /// Search field placeholder for classes
  ///
  /// In en, this message translates to:
  /// **'Search classes...'**
  String get searchClasses;

  /// Empty state for classes list
  ///
  /// In en, this message translates to:
  /// **'No classes found'**
  String get noClassesFound;

  /// Label for the class hit die
  ///
  /// In en, this message translates to:
  /// **'Hit Die:'**
  String get hitDieLabel;

  /// Search field placeholder for feats
  ///
  /// In en, this message translates to:
  /// **'Search feats...'**
  String get searchFeats;

  /// Empty state for feats list
  ///
  /// In en, this message translates to:
  /// **'No feats found.'**
  String get noFeatsFound;

  /// Search field placeholder for races
  ///
  /// In en, this message translates to:
  /// **'Search races...'**
  String get searchRaces;

  /// Empty state for races list
  ///
  /// In en, this message translates to:
  /// **'No races found.'**
  String get noRacesFound;

  /// Search field placeholder for weapons
  ///
  /// In en, this message translates to:
  /// **'Search weapons...'**
  String get searchWeapons;

  /// Empty state for weapons list
  ///
  /// In en, this message translates to:
  /// **'No weapons found'**
  String get noWeaponsFound;

  /// Label for the source of a lore item
  ///
  /// In en, this message translates to:
  /// **'Source:'**
  String get sourceLabel;

  /// Label for list of active filters
  ///
  /// In en, this message translates to:
  /// **'Active Filters:'**
  String get activeFilters;

  /// Action to clear all filters
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// Section title for character ability scores
  ///
  /// In en, this message translates to:
  /// **'Ability Scores'**
  String get abilityScores;

  /// Section title for character saving throws
  ///
  /// In en, this message translates to:
  /// **'Saving Throws'**
  String get savingThrows;

  /// Dialog title to add a custom class slot
  ///
  /// In en, this message translates to:
  /// **'Add Class Slot'**
  String get addClassSlot;

  /// Label for a custom slot name
  ///
  /// In en, this message translates to:
  /// **'Slot Name'**
  String get slotName;

  /// Label for maximum slots in a customized resource
  ///
  /// In en, this message translates to:
  /// **'Max Slots'**
  String get maxSlots;

  /// Label for used slots in a customized resource
  ///
  /// In en, this message translates to:
  /// **'Used Slots'**
  String get usedSlots;

  /// Title for the dialog to edit a custom slot
  ///
  /// In en, this message translates to:
  /// **'Modify {slotName}'**
  String modifySlot(Object slotName);

  /// Text for the maximum slot configuration label
  ///
  /// In en, this message translates to:
  /// **'Maximum slots:'**
  String get maximumSlots;

  /// Text for the used slot configuration label
  ///
  /// In en, this message translates to:
  /// **'Used slots:'**
  String get slotUsedLabel;

  /// Quick action to set slot count to 4
  ///
  /// In en, this message translates to:
  /// **'Set 4'**
  String get setFour;

  /// Quick action to set slot count to 6
  ///
  /// In en, this message translates to:
  /// **'Set 6'**
  String get setSix;

  /// Quick action to set slot count to 8
  ///
  /// In en, this message translates to:
  /// **'Set 8'**
  String get setEight;

  /// Quick action to use all slots
  ///
  /// In en, this message translates to:
  /// **'Use All'**
  String get useAll;

  /// Quick action to mark half of the slots as used
  ///
  /// In en, this message translates to:
  /// **'Half Used'**
  String get halfUsed;

  /// Confirmation action in dialogs
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// Dialog title to rename a custom slot
  ///
  /// In en, this message translates to:
  /// **'Edit Slot Name'**
  String get editSlotName;

  /// Dialog title to delete a custom slot
  ///
  /// In en, this message translates to:
  /// **'Delete Slot'**
  String get deleteSlot;

  /// Prefix label for the amount of slots available
  ///
  /// In en, this message translates to:
  /// **'Slots:'**
  String get slotsLabel;

  /// Prefix label for the amount of used slots
  ///
  /// In en, this message translates to:
  /// **'Used:'**
  String get usedLabel;

  /// Action to restore all spell slots
  ///
  /// In en, this message translates to:
  /// **'Restore all slots'**
  String get restoreAllSlots;

  /// Dialog title for spell preparation tips
  ///
  /// In en, this message translates to:
  /// **'Spell Preparation Info'**
  String get spellPreparationInfo;

  /// Dismiss button in informational dialogs
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get gotIt;

  /// Dialog title and action to remove a spell from a character
  ///
  /// In en, this message translates to:
  /// **'Remove Spell'**
  String get removeSpell;

  /// Confirmation for removing a spell from the character
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove \"{spellName}\" from your character\'s spell list?'**
  String removeSpellConfirmation(Object spellName);

  /// Dialog title for reordering character tabs
  ///
  /// In en, this message translates to:
  /// **'Reorder Tabs'**
  String get reorderTabs;

  /// Action to reset the tab order to default
  ///
  /// In en, this message translates to:
  /// **'Reset to Default'**
  String get resetToDefault;

  /// Prefix label for a search filter chip
  ///
  /// In en, this message translates to:
  /// **'Search:'**
  String get searchFilterLabel;

  /// Prefix label for a type filter chip
  ///
  /// In en, this message translates to:
  /// **'Type:'**
  String get typeFilterLabel;

  /// Title for spells list screen
  ///
  /// In en, this message translates to:
  /// **'D&D Spells'**
  String get dndSpells;

  /// Tooltip for filtering spells
  ///
  /// In en, this message translates to:
  /// **'Filter spells'**
  String get filterSpells;

  /// Search field placeholder for spells
  ///
  /// In en, this message translates to:
  /// **'Search spells...'**
  String get searchSpells;

  /// Filter label for spell level
  ///
  /// In en, this message translates to:
  /// **'Level:'**
  String get levelFilter;

  /// Filter label for spell class
  ///
  /// In en, this message translates to:
  /// **'Class:'**
  String get classFilter;

  /// Filter label for spell school
  ///
  /// In en, this message translates to:
  /// **'School:'**
  String get schoolFilter;

  /// Generic label for all options
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// Label for cantrip spell level
  ///
  /// In en, this message translates to:
  /// **'Cantrip'**
  String get cantrip;

  /// Label for a spell level
  ///
  /// In en, this message translates to:
  /// **'Level {level}'**
  String levelLabel(Object level);

  /// Generic error label
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Empty state for spells list
  ///
  /// In en, this message translates to:
  /// **'No spells found. Try adjusting your search or filters.'**
  String get noSpellsFound;

  /// Cloud sync section title in login screen
  ///
  /// In en, this message translates to:
  /// **'Cloud Sync'**
  String get cloudSync;

  /// Login screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Sign in to sync your characters and journals across all your devices'**
  String get signInSyncDescription;

  /// Email field label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Email field hint
  ///
  /// In en, this message translates to:
  /// **'Enter your email address'**
  String get enterYourEmail;

  /// Validation message for empty email
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get pleaseEnterYourEmail;

  /// Validation message for invalid email
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get pleaseEnterValidEmail;

  /// Password field label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Password field hint
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterYourPassword;

  /// Validation message for empty password
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get pleaseEnterYourPassword;

  /// Validation message for short password
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMinLength;

  /// Forgot password action label
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// Information text when registration is disabled
  ///
  /// In en, this message translates to:
  /// **'Account creation is temporarily disabled. Please sign in with an existing account or try again later.'**
  String get accountCreationDisabled;

  /// Information text for login flow
  ///
  /// In en, this message translates to:
  /// **'If you don\'t have an account yet, we\'ll create one for you automatically when you sign in.'**
  String get accountCreationInfo;

  /// Loading text while signing in
  ///
  /// In en, this message translates to:
  /// **'Signing In...'**
  String get signingIn;

  /// Title for feature list on login screen
  ///
  /// In en, this message translates to:
  /// **'With Cloud Sync you can:'**
  String get syncFeatureTitle;

  /// Feature point in login screen
  ///
  /// In en, this message translates to:
  /// **'Access your characters from any device'**
  String get cloudSyncFeature1;

  /// Feature point in login screen
  ///
  /// In en, this message translates to:
  /// **'Automatic backup of all your data'**
  String get cloudSyncFeature2;

  /// Feature point in login screen
  ///
  /// In en, this message translates to:
  /// **'Sync journals and character sheets'**
  String get cloudSyncFeature3;

  /// Feature point in login screen
  ///
  /// In en, this message translates to:
  /// **'Never lose your campaign data'**
  String get cloudSyncFeature4;

  /// Remote-config disabled sign-in message
  ///
  /// In en, this message translates to:
  /// **'Sign in is temporarily disabled. Please try again later or contact support.'**
  String get signInTemporarilyDisabled;

  /// Loading message while downloading cloud data
  ///
  /// In en, this message translates to:
  /// **'Downloading your data from cloud...'**
  String get downloadingCloudData;

  /// Success message after cloud sync
  ///
  /// In en, this message translates to:
  /// **'Data sync successfully!'**
  String get dataSyncSuccessfully;

  /// Error message when cloud download fails
  ///
  /// In en, this message translates to:
  /// **'Could not download cloud data: {error}'**
  String couldNotDownloadCloudData(Object error);

  /// Title for reset password dialog
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// Description in reset password dialog
  ///
  /// In en, this message translates to:
  /// **'Enter your email address and we\'ll send you a link to reset your password.'**
  String get resetPasswordDescription;

  /// Button to send reset password email
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get sendResetLink;

  /// Error when email is empty in reset dialog
  ///
  /// In en, this message translates to:
  /// **'Please enter your email address'**
  String get pleaseEnterEmailAddress;

  /// Success message after reset email sent
  ///
  /// In en, this message translates to:
  /// **'Password reset email sent! Check your inbox (or spam folder).'**
  String get passwordResetEmailSent;

  /// Title for character creation screen
  ///
  /// In en, this message translates to:
  /// **'Create New Character'**
  String get createNewCharacter;

  /// Subtitle for character creation screen
  ///
  /// In en, this message translates to:
  /// **'Fill in the details below to create your character'**
  String get fillCharacterDetails;

  /// Character name label
  ///
  /// In en, this message translates to:
  /// **'Character Name'**
  String get characterName;

  /// Validation requirement for character name
  ///
  /// In en, this message translates to:
  /// **'Character name is required'**
  String get characterNameRequired;

  /// Label for character level field
  ///
  /// In en, this message translates to:
  /// **'Character Level'**
  String get characterLevel;

  /// Validation requirement for character level
  ///
  /// In en, this message translates to:
  /// **'Character level is required'**
  String get characterLevelRequired;

  /// Label for character class field
  ///
  /// In en, this message translates to:
  /// **'Class'**
  String get classLabel;

  /// Label for custom subclass input
  ///
  /// In en, this message translates to:
  /// **'Custom Subclass'**
  String get customSubclass;

  /// Label for optional subclass selector
  ///
  /// In en, this message translates to:
  /// **'Subclass (Optional)'**
  String get subclassOptional;

  /// Action to clear a selected subclass
  ///
  /// In en, this message translates to:
  /// **'Clear Subclass'**
  String get clearSubclass;

  /// Tooltip to switch from custom subclass to preset list
  ///
  /// In en, this message translates to:
  /// **'Choose from preset subclasses'**
  String get chooseSubclass;

  /// Placeholder text for the custom subclass option
  ///
  /// In en, this message translates to:
  /// **'Custom Subclass...'**
  String get customSubclassPlaceholder;

  /// Label for optional race selector
  ///
  /// In en, this message translates to:
  /// **'Race (Optional)'**
  String get raceOptional;

  /// Action to clear a selected race
  ///
  /// In en, this message translates to:
  /// **'Clear Race'**
  String get clearRace;

  /// Label for optional background selector
  ///
  /// In en, this message translates to:
  /// **'Background (Optional)'**
  String get backgroundOptional;

  /// Action to clear a selected background
  ///
  /// In en, this message translates to:
  /// **'Clear Background'**
  String get clearBackground;

  /// Loading text while creating a character
  ///
  /// In en, this message translates to:
  /// **'Creating...'**
  String get creatingCharacter;

  /// Validation message for character level bounds
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid level between {min} and {max}'**
  String validLevelRange(Object min, Object max);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
