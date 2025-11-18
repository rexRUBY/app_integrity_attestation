
import 'app_integrity_attestation_platform_interface.dart';

class AppIntegrityAttestation {
  Future<String?> getPlatformVersion() {
    return AppIntegrityAttestationPlatform.instance.getPlatformVersion();
  }
}
