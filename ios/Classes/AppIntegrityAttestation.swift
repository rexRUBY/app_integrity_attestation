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
        print("attest에 사용 한 키")
        print(keyId)
        guard let data = challenge.data(using: .utf8) else {
            let err = NSError(domain: "AppIntegrity", code: 401,
                              userInfo: [NSLocalizedDescriptionKey: "Invalid challenge"])
            completion(nil, err)
            return
        }

        let hash = Data(SHA256.hash(data: data))

        service.attestKey(keyId, clientDataHash: hash) { att, error in
            if let error = error {
                completion(nil, error)
            } else {
                completion(att?.base64EncodedString(), nil)
            }
        }
    }

    // ============================
    // 3) Assertion
    // ============================
    func assertionKey(keyId: String, clientDataHash: String, completion: @escaping (String?, Error?) -> Void) {

        // 1. Base64url 형태를 Swift가 인식할 수 있는 일반 Base64 형태로 변환 (패딩 포함)
        let base64String = clientDataHash.base64urlToBase64()

        // 2. Data(base64Encoded:)를 사용해서 32바이트 해시 Data로 디코딩
        guard let hashData = Data(base64Encoded: base64String) else {
            let err = NSError(domain: "AppIntegrity", code: 400,
                              userInfo: [NSLocalizedDescriptionKey: "Invalid client data hash format (Base64url decoding failed)"])
            completion(nil, err)
            return
        }

        // 3. 정확하게 복원된 Data를 서비스 함수에 전달
        service.generateAssertion(keyId, clientDataHash: hashData) { assertion, error in
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