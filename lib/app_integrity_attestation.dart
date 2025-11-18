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
}