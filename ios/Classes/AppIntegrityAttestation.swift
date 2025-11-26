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
        guard let data = clientDataHash.data(using: .utf8) else {
            let err = NSError(domain: "AppIntegrity", code: 400,
                              userInfo: [NSLocalizedDescriptionKey: "Invalid client data string"])
            completion(nil, err)
            return
        }

        let hash = Data(SHA256.hash(data: data))

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