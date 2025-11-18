import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'app_integrity_attestation_method_channel.dart';

abstract class AppIntegrityAttestationPlatform extends PlatformInterface {
  /// Constructs a AppIntegrityAttestationPlatform.
  AppIntegrityAttestationPlatform() : super(token: _token);

  static final Object _token = Object();

  static AppIntegrityAttestationPlatform _instance = MethodChannelAppIntegrityAttestation();

  /// The default instance of [AppIntegrityAttestationPlatform] to use.
  ///
  /// Defaults to [MethodChannelAppIntegrityAttestation].
  static AppIntegrityAttestationPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [AppIntegrityAttestationPlatform] when
  /// they register themselves.
  static set instance(AppIntegrityAttestationPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
