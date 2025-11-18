import 'package:flutter_test/flutter_test.dart';
import 'package:app_integrity_attestation/app_integrity_attestation.dart';
import 'package:app_integrity_attestation/app_integrity_attestation_platform_interface.dart';
import 'package:app_integrity_attestation/app_integrity_attestation_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockAppIntegrityAttestationPlatform
    with MockPlatformInterfaceMixin
    implements AppIntegrityAttestationPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final AppIntegrityAttestationPlatform initialPlatform = AppIntegrityAttestationPlatform.instance;

  test('$MethodChannelAppIntegrityAttestation is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelAppIntegrityAttestation>());
  });

  test('getPlatformVersion', () async {
    AppIntegrityAttestation appIntegrityAttestationPlugin = AppIntegrityAttestation();
    MockAppIntegrityAttestationPlatform fakePlatform = MockAppIntegrityAttestationPlatform();
    AppIntegrityAttestationPlatform.instance = fakePlatform;

    expect(await appIntegrityAttestationPlugin.getPlatformVersion(), '42');
  });
}
