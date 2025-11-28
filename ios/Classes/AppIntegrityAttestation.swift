import Foundation
import DeviceCheck
import CryptoKit

public class AppIntegrityAttestation {
    
    private let service = DCAppAttestService.shared

    public init() {}

    // ==============================================
    // 1) fresh key 생성(재사용 여부는 플러터에서 구현 해야 함)
    // ==============================================
    func generateKey(completion: @escaping (String?, Error?) -> Void) {
        guard service.isSupported else {
            let err = NSError(
                domain: "AppIntegrity",
                code: 400,
                userInfo: [NSLocalizedDescriptionKey: "Device not supported"]
            )
            completion(nil, err)
            return
        }

        // 기존 키 전부 제거
        clearKeyIdFromStorage()

        // 완전히 fresh key 생성
        service.generateKey { keyId, error in
            if let keyId = keyId {
                self.saveKeyIdToStorage(keyId)
            }
            completion(keyId, error)
        }
    }

    // ============================
    // 2) Attestation
    // ============================
    func attestKey(keyId: String, challenge: String, completion: @escaping (String?, Error?) -> Void) {
        print("attest에 사용한 키:")
        print(keyId)

        // 1) Base64URL → Base64 변환
        let base64String = challenge.base64urlToBase64()

        // 2) Base64 디코딩해서 원본 바이트 복원
        guard let rawChallenge = Data(base64Encoded: base64String) else {
            let err = NSError(
                domain: "AppIntegrity",
                code: 401,
                userInfo: [
                    NSLocalizedDescriptionKey: "Invalid Base64 challenge (decoding failed)"
                ]
            )
            completion(nil, err)
            return
        }

        // 3) SHA256(clientData) 계산
        let clientDataHash = Data(SHA256.hash(data: rawChallenge))



        // 4) iOS 시스템 App Attest API 호출
        service.attestKey(keyId, clientDataHash: clientDataHash) { attestation, error in
            if let error = error {
                completion(nil, error)
            } else {
                completion(attestation?.base64EncodedString(), nil)
            }
        }
    }


    // ============================
    // 3) Assertion
    // ============================
    func assertionKey(
        keyId: String,
        challenge: String,          // 서버가 준 challenge(Base64URL 문자열)
        completion: @escaping (String?, Error?) -> Void
    ) {
        // 1. Base64URL → Base64 → raw bytes 디코딩
        let base64String = challenge.base64urlToBase64()
        guard let rawChallenge = Data(base64Encoded: base64String) else {
            let err = NSError(
                domain: "AppIntegrity",
                code: 400,
                userInfo: [NSLocalizedDescriptionKey: "Invalid challenge format (base64 decode fail)"]
            )
            completion(nil, err)
            return
        }

        // 2. SHA-256(rawChallenge) → 32 bytes digest 생성 (AppAttest 규격)
        let hash = Data(SHA256.hash(data: rawChallenge))

        print("iOS assertion clientDataHash hex =",
              hash.map { String(format:"%02x", $0) }.joined())
        // 반드시 길이 32여야 한다.
        print("iOS assertion clientDataHash len =", hash.count)

        // 3. 생성한 32바이트 digest를 iOS에 그대로 전달
        service.generateAssertion(keyId, clientDataHash: hash) { assertion, error in
            if let error = error {
                completion(nil, error)
            } else {
                completion(assertion?.base64EncodedString(), nil)
            }
        }
    }

    // ============================
    // Storage
    // ============================
    private func saveKeyIdToStorage(_ keyId: String) {
        UserDefaults.standard.set(keyId, forKey: "appAttestKeyId")
    }

    private func getKeyIdFromStorage() -> String? {
        UserDefaults.standard.string(forKey: "appAttestKeyId")
    }

    private func clearKeyIdFromStorage() {
        UserDefaults.standard.removeObject(forKey: "appAttestKeyId")
    }
}

// ============================
// Helper
// ============================
extension String {
    // Base64url 문자열을 일반 Base64 문자열로 변환하고 패딩을 추가
    func base64urlToBase64() -> String {
        var base64 = self
            .replacingOccurrences(of: "-", with: "+") // URL-safe '-'를 '+'로
            .replacingOccurrences(of: "_", with: "/") // URL-safe '_'를 '/'로

        // 자바에서 withoutPadding()을 썼으므로, 패딩을 다시 추가 (Base64는 4의 배수여야 함)
        while base64.count % 4 != 0 {
            base64.append("=")
        }
        return base64
    }
}