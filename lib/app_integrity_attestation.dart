import 'app_integrity_attestation_platform_interface.dart';

class AppIntegrityAttestation {
  Future<String?> getIntegrityToken({
    required String requestHash,
    required String cloudProjectNumber,
  }) {
    return AppIntegrityAttestationPlatform.instance.getIntegrityToken(
      requestHash: requestHash,
      cloudProjectNumber: cloudProjectNumber,
    );
  }

  Future<String?> generateKey() {
    return AppIntegrityAttestationPlatform.instance.generateKey();
  }

  Future<String?> attestKey({
    required String keyId,
    required String challenge,
  }) {
    return AppIntegrityAttestationPlatform.instance.attestKey(
      keyId: keyId,
      challenge: challenge,
    );
  }

  Future<String?> assertionKey({
    required String keyId,
    required String clientDataHash,
    required String requestData,
  }) {
    return AppIntegrityAttestationPlatform.instance.assertionKey(
      keyId: keyId,
      clientDataHash: clientDataHash,
      requestData: requestData
    );
  }
}
