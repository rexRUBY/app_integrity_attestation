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
  String _token = '토큰 없음';
  final _plugin = AppIntegrityAttestation();

  Future<void> _getIntegrityToken() async {
    try {
      final token = await _plugin.getIntegrityToken(
        requestHash: "abcd1234",
        cloudProjectNumber: "1234567890",
      );

      setState(() {
        _token = token ?? "null 반환됨";
      });
    } on PlatformException catch (e) {
      setState(() {
        _token = "PlatformException: ${e.message}";
      });
    } catch (e) {
      setState(() {
        _token = "Error: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Integrity Plugin Example'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Token:\n$_token", textAlign: TextAlign.center),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _getIntegrityToken,
                child: const Text("무결성 토큰 요청"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}