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
}