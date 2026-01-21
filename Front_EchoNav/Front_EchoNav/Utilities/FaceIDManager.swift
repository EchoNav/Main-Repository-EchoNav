import Foundation
import LocalAuthentication

class FaceIDManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var authenticationError: String?
    
    enum AuthenticationType {
        case faceID
        case touchID
        case none
    }
    
    // Vérifier quel type d'authentification biométrique est disponible
    func biometricType() -> AuthenticationType {
        let context = LAContext()
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return .none
        }
        
        switch context.biometryType {
        case .faceID:
            return .faceID
        case .touchID:
            return .touchID
        default:
            return .none
        }
    }
    
    // Authentifier avec Face ID / Touch ID
    func authenticate(completion: @escaping (Bool, String?) -> Void) {
        let context = LAContext()
        var error: NSError?
        
        // Vérifier si la biométrie est disponible
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            let message = error?.localizedDescription ?? "L'authentification biométrique n'est pas disponible"
            DispatchQueue.main.async {
                self.authenticationError = message
                completion(false, message)
            }
            return
        }
        
        // Raison affichée à l'utilisateur
        let reason = "Authentifiez-vous pour accéder à EchoNav"
        
        // Lancer l'authentification
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
            DispatchQueue.main.async {
                if success {
                    self.isAuthenticated = true
                    self.authenticationError = nil
                    completion(true, nil)
                } else {
                    let message = authenticationError?.localizedDescription ?? "Authentification échouée"
                    self.authenticationError = message
                    self.isAuthenticated = false
                    completion(false, message)
                }
            }
        }
    }
}
