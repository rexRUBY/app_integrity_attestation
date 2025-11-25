import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'app_integrity_attestation_method_channel.dart';

abstract class AppIntegrityAttestationPlatform extends PlatformInterface {
  AppIntegrityAttestationPlatform() : super(token: _token);

  static final Object _token = Object();

  static AppIntegrityAttestationPlatform _instance =
      MethodChannelAppIntegrityAttestation();

  static AppIntegrityAttestationPlatform get instance => _instance;

  static set instance(AppIntegrityAttestationPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  // Android ==========================================

  Future<String?> getIntegrityToken({
    required String requestHash,
    required String cloudProjectNumber,
  }) {
    throw UnimplementedError('getIntegrityToken() has not been implemented.');
  }

  // IOS ==============================================

  // 1. 키 생성 (Key ID 반환)
  Future<String?> generateKey() {
    throw UnimplementedError('generateKey() has not been implemented.');
  }

  // 2. 보증서 발급 (Attestation Object 반환)
  Future<String?> attestKey({
    required String keyId,
    required String challenge,
  }) {
    throw UnimplementedError('attestKey() has not been implemented.');
  }

  // 3. 서버 요청 검증용 서명 생성 (Assertion)
  Future<String?> assertionKey({
    required String keyId,
    required String clientDataHash,
  }) {
    throw UnimplementedError('assertionKey() has not been implemented.');
  }
}
