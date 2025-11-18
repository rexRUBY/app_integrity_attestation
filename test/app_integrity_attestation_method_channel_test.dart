import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_integrity_attestation/app_integrity_attestation_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelAppIntegrityAttestation platform = MethodChannelAppIntegrityAttestation();
  const MethodChannel channel = MethodChannel('app_integrity_attestation');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return '42';
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
