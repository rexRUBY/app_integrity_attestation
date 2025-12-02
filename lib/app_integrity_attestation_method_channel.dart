import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:io';

import 'app_integrity_attestation_platform_interface.dart';

class MethodChannelAppIntegrityAttestation
    extends AppIntegrityAttestationPlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('app_integrity_attestation');

  // Android ========================================================

  @override
  Future<String?> getIntegrityToken({
    required String requestHash,
    required String cloudProjectNumber,
  }) async {
    if (!Platform.isAndroid) return null;

    try {
      final token = await methodChannel.invokeMethod<String>(
        'getIntegrityToken',
        {"requestHash": requestHash, "cloudProjectNumber": cloudProjectNumber},
      );
      return token;
    } on PlatformException catch (e) {
      print("Android Integrity Token 발급 실패: ${e.message}");
      return null;
    }
  }

  // IOS ============================================================

  // 1. Key ID 생성
  @override
  Future<String?> generateKey() async {
    if (!Platform.isIOS) return null;

    try {
      final String? keyId = await methodChannel.invokeMethod<String>(
        'generateKey',
      );
      return keyId;
    } on PlatformException catch (e) {
      print("generateKey() > iOS Key 생성 실패: ${e.message}");
      return null;
    }
  }

  // 2. 보증서(Attestation) 발급
  @override
  Future<String?> attestKey({
    required String keyId,
    required String challenge,
  }) async {
    if (!Platform.isIOS) return null;

    try {
      final String? attestation = await methodChannel.invokeMethod<String>(
        'attestKey',
        {"keyId": keyId, "challenge": challenge},
      );
      return attestation;
    } on PlatformException catch (e) {
      print(
        "attestKey(keyId: ${keyId}, challenge: ${challenge}) => iOS 보증서 발급 실패: ${e.message}",
      );
      return null;
    }
  }

  // 3. 요청 서명 (Assertion Object 반환)
  @override
  Future<String?> assertionKey({
    required String keyId,
    required String challenge,
    required String requestData,
  }) async {
    if (!Platform.isIOS) return null;
    try {
      final String? assertion = await methodChannel.invokeMethod<String>(
        'assertionKey',
        {"keyId": keyId, "challenge": challenge, "requestData": requestData},
      );
      return assertion;
    } on PlatformException catch (e) {
      print(
        "assertionKey(keyId: ${keyId}, clientDataHash: ${challenge}) => iOS 요청 서명 발급 실패: ${e.message}",
      );
      return null;
    }
  }
}
