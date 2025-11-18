import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'app_integrity_attestation_method_channel.dart';

abstract class AppIntegrityAttestationPlatform extends PlatformInterface {
  AppIntegrityAttestationPlatform() : super(token: _token);

  static final Object _token = Object();

  static AppIntegrityAttestationPlatform _instance = MethodChannelAppIntegrityAttestation();

  static AppIntegrityAttestationPlatform get instance => _instance;

  static set instance(AppIntegrityAttestationPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getIntegrityToken({
    required String requestHash,
    required String cloudProjectNumber,
  }) {
    throw UnimplementedError('getIntegrityToken() has not been implemented.');
  }
}