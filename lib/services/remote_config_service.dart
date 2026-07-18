import 'package:firebase_remote_config/firebase_remote_config.dart';

/// Simple Remote Config service to expose feature flags
class RemoteConfigService {
  RemoteConfigService._internal();
  static final RemoteConfigService _instance = RemoteConfigService._internal();
  static RemoteConfigService get instance => _instance;

  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  /// Initialize with sensible defaults and fetch server values
  Future<void> initialize() async {
    try {
      await _remoteConfig.setDefaults(<String, dynamic>{
        'allow_sign_in': true,
        'allow_register': true,
      });

      // Short cache and fetch immediately
      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(minutes: 5),
      ));

      await _remoteConfig.fetchAndActivate();
    } catch (e) {
      // Fail softly; app will use defaults
      if (e is Exception) {}
    }
  }

  bool get allowSignIn => _remoteConfig.getBool('allow_sign_in');
  bool get allowRegister => _remoteConfig.getBool('allow_register');
}
