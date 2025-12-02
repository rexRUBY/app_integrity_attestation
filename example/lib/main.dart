import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:app_integrity_attestation/app_integrity_attestation.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // 화면에 로그 뿌려줄 변수
  String _statusLog = '버튼을 눌러 테스트하세요.';

  // iOS 테스트 흐름을 위해 KeyID 저장할 변수
  String? _iosKeyId;
  String challenge = 'abcd1234';

  final _plugin = AppIntegrityAttestation();

  // 1. [Android] Integrity Token 요청
  Future<void> _getAndroidIntegrityToken() async {
    setState(() => _statusLog = "Android 토큰 요청 중...");
    try {
      final token = await _plugin.getIntegrityToken(
        requestHash: "abcd1234",
        cloudProjectNumber: "1234567890",
      );

      setState(() {
        _statusLog = "Android Token:\n$token";
      });
    } on PlatformException catch (e) {
      setState(() => _statusLog = "Android Error: ${e.message}");
    } catch (e) {
      setState(() => _statusLog = "Error: $e");
    }
  }

  // 2. [iOS] 키 생성 (Step 1)
  Future<void> _generateIosKey() async {
    setState(() => _statusLog = "iOS Key 생성 중...");
    try {
      final keyId = await _plugin.generateKey();

      setState(() {
        _iosKeyId = keyId; // 다음 단계를 위해 저장
        _statusLog = "Key ID 생성 완료:\n$keyId\n\n이제 Attest 요청을 하세요.";
      });
    } on PlatformException catch (e) {
      setState(() => _statusLog = "iOS Key Error: ${e.message}");
    }
  }

  // 3. [iOS] 보증 요청 (Step 2)
  Future<void> _attestIosKey() async {
    if (_iosKeyId == null) {
      setState(() => _statusLog = "먼저 'iOS 키 생성'을 눌러주세요.");
      return;
    }

    setState(() => _statusLog = "iOS Attestation 요청 중...");
    try {
      // challenge는 보통 서버에서 받은 값
      final attestationObj = await _plugin.attestKey(
        keyId: _iosKeyId!,
        challenge: "test_challenge_random_string",
      );

      setState(() {
        _statusLog = "Attestation 성공(Base64):\n$attestationObj";
      });
    } on PlatformException catch (e) {
      setState(() => _statusLog = "iOS Attest Error: ${e.message}");
    }
  }

  // 4. [iOS] 서버 요청 검증용 서명 생성(Step 3)
  Future<void> _assertionIosKey() async {
    if (_iosKeyId == null) {
      setState(() => _statusLog = "Key ID가 없습니다. 처음부터 다시 진행해주세요.");
      return;
    }

    setState(() => _statusLog = "iOS Assertion(서명) 생성 중...");
    try {
      final assertionObj = await _plugin.assertionKey(keyId: _iosKeyId ?? '', challenge: challenge, requestData: "app-assertion");
      setState(() {
        _statusLog = "Assertion 성공(Base64)";
      });
    } on PlatformException catch (e) {
      setState(() => _statusLog = "iOS Assertion Error: ${e.message}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('App Integrity Example')),
        body: SingleChildScrollView(
          // 로그 길어지니까 스크롤 필수
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 결과 보여주는 창
              Container(
                padding: const EdgeInsets.all(10),
                color: Colors.grey[200],
                height: 200,
                child: SingleChildScrollView(child: Text(_statusLog)),
              ),
              const SizedBox(height: 20),

              const Text(
                "Android Test",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ElevatedButton(
                onPressed: _getAndroidIntegrityToken,
                child: const Text("Play Integrity 토큰 요청"),
              ),

              const Divider(height: 30, thickness: 2),

              const Text(
                "iOS Test (App Attest)",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ElevatedButton(
                onPressed: _generateIosKey,
                child: const Text("1. iOS 키 생성 (Generate Key)"),
              ),
              ElevatedButton(
                onPressed: _attestIosKey,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _iosKeyId != null
                      ? Colors.blue
                      : Colors.grey,
                  foregroundColor: Colors.white,
                ),
                child: const Text("2. iOS 보증 요청 (Attest Key)"),
              ),
              ElevatedButton(
                onPressed: _assertionIosKey,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _iosKeyId != null ? Colors.green : Colors.grey,
                  foregroundColor: Colors.white,
                ),
                child: const Text("3. 요청 서명 (Assertion)"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
