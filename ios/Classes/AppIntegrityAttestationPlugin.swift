import Flutter
import UIKit

public class AppIntegrityAttestationPlugin: NSObject, FlutterPlugin {
    
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

        case "getIntegrityToken":
             // 안드로이드용은 무시
             result(FlutterMethodNotImplemented)

        default:
            result(FlutterMethodNotImplemented)
        }
    }
}