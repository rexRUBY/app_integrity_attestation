import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'app_integrity_attestation_platform_interface.dart';

/// An implementation of [AppIntegrityAttestationPlatform] that uses method channels.
class MethodChannelAppIntegrityAttestation extends AppIntegrityAttestationPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('app_integrity_attestation');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
