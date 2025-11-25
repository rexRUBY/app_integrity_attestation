import Foundation
import DeviceCheck
import CryptoKit

public class AppIntegrityAttestation {
    
    private let service = DCAppAttestService.shared

    // 생성자
    public init() {}

    // 1. 키 생성
    func generateKey(completion: @escaping (String?, Error?) -> Void) {
        if !service.isSupported {
            let error = NSError(domain: "AppIntegrity", code: 400, userInfo: [NSLocalizedDescriptionKey: "Device not supported"])
            completion(nil, error)
            return
        }
        service.generateKey { keyId, error in
            completion(keyId, error)
        }
    }

    // 2. 보증서 발급
    func attestKey(keyId: String, challenge: String, completion: @escaping (String?, Error?) -> Void) {
        guard let challengeData = challenge.data(using: .utf8) else {
            let error = NSError(domain: "AppIntegrity", code: 401, userInfo: [NSLocalizedDescriptionKey: "Invalid challenge"])
            completion(nil, error)
            return
        }
        
        let challengeHash = Data(SHA256.hash(data: challengeData))
        
        service.attestKey(keyId, clientDataHash: challengeHash) { attestationObject, error in
            if let error = error {
                completion(nil, error)
                return
            }
            let base64String = attestationObject?.base64EncodedString()
            completion(base64String, nil)
        }
    }

    // 3. 요청 서명
    func assertionKey(keyId: String, clientDataHash: String, completion: @escaping (String?, Error?) -> Void) {
        // 1. String을 Data로 변환 (UTF8)
        guard let dataToHash = clientDataHash.data(using: .utf8) else {
            let error = NSError(domain: "AppIntegrity", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid client data string"])
            completion(nil, error)
            return
        }

        // 여기서 SHA256 해시를 생성 (지문 만들기)
        let hashedData = Data(SHA256.hash(data: dataToHash))

        // DCAppAttestService 호출
        service.generateAssertion(keyId, clientDataHash: hashedData) { assertionObject, error in
            if let error = error {
                // 실패 시 에러 반환
                completion(nil, error)
                return
            }

            // 성공 시 Assertion Object를 Base64 문자열로 변환해서 반환
            let base64String = assertionObject?.base64EncodedString()
            completion(base64String, nil)
        }
    }
}