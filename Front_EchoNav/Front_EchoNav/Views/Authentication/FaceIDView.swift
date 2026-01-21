import SwiftUI

struct FaceIDView: View {
    @StateObject private var faceIDManager = FaceIDManager()
    @State private var navigateToLidar = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    // Détecter si on est en mode test UI
    private var isUITesting: Bool {
        return ProcessInfo.processInfo.arguments.contains("UI-Testing")
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.lightGray
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Spacer()
                    
                    // Titre de l'application
                    Text("EchoNav")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(Color.primaryBlue)
                        .padding(.bottom, 100)
                    
                    // Bouton Face ID
                    FaceIDButton {
                        authenticateWithFaceID()
                    }
                    .padding(.bottom, 20)
                    
                    // Message d'erreur si l'authentification échoue
                    if showError {
                        Text(errorMessage)
                            .font(.system(size: 15))
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                            .padding(.top, 20)
                    }
                    
                    Spacer()
                    Spacer()
                }
                .navigationDestination(isPresented: $navigateToLidar) {
                    LidarView()
                        .navigationBarHidden(true)
                }
            }
        }
        .onAppear {
            // Vérifier le type de biométrie disponible
            let biometricType = faceIDManager.biometricType()
            switch biometricType {
            case .faceID:
                print("Face ID disponible")
            case .touchID:
                print("Touch ID disponible")
            case .none:
                print("Aucune authentification biométrique disponible")
            }
        }
    }
    
    private func authenticateWithFaceID() {
        print("Démarrage de l'authentification Face ID")
        showError = false
        
        // Mode test : bypass Face ID automatiquement
        if isUITesting {
            print("Mode test UI détecté - Bypass Face ID")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                navigateToLidar = true
            }
            return
        }
        
        // Mode production : vraie authentification Face ID
        faceIDManager.authenticate { success, error in
            if success {
                print("Authentification réussie")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    navigateToLidar = true
                }
            } else {
                print("Authentification échouée: \(error ?? "Erreur inconnue")")
                errorMessage = error ?? "Authentification échouée"
                showError = true
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    showError = false
                }
            }
        }
    }
}

#Preview {
    FaceIDView()
}
