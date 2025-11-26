import Foundation
import DeviceCheck
import CryptoKit

public class AppIntegrityAttestation {
    
    private let service = DCAppAttestService.shared

    // 생성자
    public init() {}

    // 1. 키 발급
    func generateKey(completion: @escaping (String?, Error?) -> Void) {
            // 1. 디바이스 지원 여부 체크 (기존 코드 유지)
            if !service.isSupported {
                let error = NSError(domain: "AppIntegrity", code: 400, userInfo: [NSLocalizedDescriptionKey: "Device not supported"])
                completion(nil, error)
                return
            }

            // 2. [핵심] 이미 저장된 키 ID가 있는지 먼저 확인!
            if let existingKeyId = self.getKeyIdFromStorage() {
                print("기존 키가 존재해서 이걸 반환함: \(existingKeyId)")
                completion(existingKeyId, nil)
                return
            }

            // 3. 없으면 새로 생성
            service.generateKey { keyId, error in
                if let error = error as NSError?, error.code == -25299 {
                     // 옵션 A: 중복 에러가 나면 기존 키를 강제로 다시 조회해서 반환 시도
                     // 옵션 B: (더 추천) 기존 키를 삭제하고 다시 생성 (Reset)
                     print("키체인 중복 에러 발생. 기존 키 정리 후 재시도 필요.")
                }
                // 정상 생성된 경우
                if let newKeyId = keyId {
                    self.saveKeyIdToStorage(newKeyId) // 생성된 ID 저장
                }
                completion(keyId, error)
            }
    }

    // 2. 보증서 발급
    func attestKey(keyId: String, challenge: String, completion: @escaping (String?, Error?) -> Void) {
        print("attest에서 받은 키 값:\(keyId)")
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

    private func saveKeyIdToStorage(_ keyId: String) {
        UserDefaults.standard.set(keyId, forKey: "appAttestKeyId")
    }

    private func getKeyIdFromStorage() -> String? {
        return UserDefaults.standard.string(forKey: "appAttestKeyId")
    }
}