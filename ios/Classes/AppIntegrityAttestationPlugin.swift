import Flutter
import UIKit
import CryptoKit // 해시 연산을 위해 필요할 수 있음

public class AppIntegrityAttestationPlugin: NSObject, FlutterPlugin {

    // 네가 구현한 로직 클래스 인스턴스
    private let implementation = AppIntegrityAttestation()

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "app_integrity_attestation", binaryMessenger: registrar.messenger())
        let instance = AppIntegrityAttestationPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {

        case "generateKey":
            implementation.generateKey { keyId, error in
                if let error = error {
                    result(FlutterError(code: "GENERATE_ERROR", message: error.localizedDescription, details: nil))
                } else {
                    result(keyId)
                }
            }

        case "attestKey":
            guard let args = call.arguments as? [String: Any],
                  let keyId = args["keyId"] as? String,
                  let challenge = args["challenge"] as? String else {
                result(FlutterError(code: "INVALID_ARGS", message: "Args missing", details: nil))
                return
            }

            implementation.attestKey(keyId: keyId, challenge: challenge) { base64, error in
                if let error = error {
                    result(FlutterError(code: "ATTEST_ERROR", message: error.localizedDescription, details: nil))
                } else {
                    result(base64)
                }
            }

        case "assertionKey":
            guard let args = call.arguments as? [String: Any],
                  let keyId = args["keyId"] as? String,
                  let challenge = args["challenge"] as? String,
                  let requestData = args["requestData"] as? String else {
                result(FlutterError(code: "INVALID_ARGS", message: "Args missing", details: nil))
                return
            }
            implementation.assertionKey(keyId: keyId, challenge: challenge, requestData: requestData) { assertionString, error in
                if let error = error {
                    result(FlutterError(code: "ASSERTION_ERROR", message: error.localizedDescription, details: nil))
                } else {
                    result(assertionString)
                }
            }

        // 🔥 [추가된 부분] 원스톱 디버깅용 케이스
        case "debugOneStop":
            self.runDebugOneStopTest(result: result)

        case "getIntegrityToken":
             // 안드로이드용은 무시
             result(FlutterMethodNotImplemented)

        default:
            result(FlutterMethodNotImplemented)
        }
    }

    // =================================================================
    // 🕵️‍♂️ [디버깅용 함수] 키 생성부터 검증 데이터 출력까지 한 방에 해결!
    // =================================================================
    private func runDebugOneStopTest(result: @escaping FlutterResult) {
        print("\n🚀 [원스톱 테스트] 시작합니다... 로그를 확인하세요!\n")

        // 1. 키 생성
        implementation.generateKey { keyId, error in
            guard let keyId = keyId, error == nil else {
                print("❌ 키 생성 실패: \(error?.localizedDescription ?? "")")
                result(FlutterError(code: "ERR", message: "키 생성 실패", details: nil))
                return
            }
            print("🔑 1. Key ID 생성 완료: \(keyId)")

            // 2. 테스트용 챌린지 준비 (여기서는 임의의 문자열을 Base64URL 처럼 만듦)
            // 'assertionKey' 함수가 Base64URL을 기대하므로 패딩 없는 Base64 문자열을 준비
            let testChallengeStr = "DEBUG_CHALLENGE_12345"
            let challengeData = testChallengeStr.data(using: .utf8)!
            // URL Safe하게 만들기 위해 + -> -, / -> _ 교체하고 = 제거
            let challengeBase64Url = challengeData.base64EncodedString()
                .replacingOccurrences(of: "+", with: "-")
                .replacingOccurrences(of: "/", with: "_")
                .replacingOccurrences(of: "=", with: "")

            // 3. Attestation 수행 (공개키 추출용)
            self.implementation.attestKey(keyId: keyId, challenge: challengeBase64Url) { attestationBase64, error in
                guard let attestation = attestationBase64, error == nil else {
                    print("❌ Attestation 실패")
                    result(FlutterError(code: "ERR", message: "Attestation 실패", details: nil))
                    return
                }

                print("\n📜 [로그 1] Attestation Object (자바 변수 attestationObjectStr 에 복붙):")
                print(attestation)

                // 4. Assertion 수행 (서명 추출용)
                let testData = "init app"

                self.implementation.assertionKey(keyId: keyId, challenge: challengeBase64Url, requestData: testData) { assertionBase64, error in
                    guard let assertion = assertionBase64, error == nil else {
                        print("❌ Assertion 실패")
                        result(FlutterError(code: "ERR", message: "Assertion 실패", details: nil))
                        return
                    }



                    print("\n📝 [로그 2] Assertion Object (자바 변수 assertionStr 에 복붙):")
                    print(assertion)

                    print("\n✅ [테스트 완료] 아래 내용을 자바 'OneShotVerifier'에 그대로 넣으세요.")
                    print("--------------------------------------------------")
                    print("// Java 테스트용 변수값")
                    print("String challengeStr = \"\(challengeBase64Url)\";")
                    print("String originalData = \"\(testData)\";")
                    print("--------------------------------------------------")

                    result("SUCCESS")
                }
            }
        }
    }
}