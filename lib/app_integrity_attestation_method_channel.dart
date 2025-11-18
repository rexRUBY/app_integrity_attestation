import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'app_integrity_attestation_platform_interface.dart';

class MethodChannelAppIntegrityAttestation extends AppIntegrityAttestationPlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('app_integrity_attestation');

  @override
  Future<String?> getIntegrityToken({
    required String requestHash,
    required String cloudProjectNumber,
  }) async {
    final token = await methodChannel.invokeMethod<String>(
      'getIntegrityToken',
      {
        "requestHash": requestHash,
        "cloudProjectNumber": cloudProjectNumber,
      },
    );
    return token;
  }
}