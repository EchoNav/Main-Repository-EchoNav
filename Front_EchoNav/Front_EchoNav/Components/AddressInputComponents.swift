import SwiftUI

// Barre de recherche
struct SearchBar: View {
    @Binding var text: String
    let placeholder: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 18))
                .foregroundColor(Color.secondaryText)
            
            if text.isEmpty {
                Text(placeholder)
                    .font(.system(size: 17))
                    .foregroundColor(Color.secondaryText)
            } else {
                Text(text)
                    .font(.system(size: 17))
                    .foregroundColor(Color.primaryText)
            }
            
            Spacer()
            
            Image(systemName: "mic.fill")
                .font(.system(size: 18))
                .foregroundColor(Color.secondaryText)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
        .accessibilityIdentifier("addressSearchBar")
    }
}

// Bouton microphone avec animation
struct MicrophoneButton: View {
    @Binding var isRecording: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                // Cercles d'animation pendant l'enregistrement
                if isRecording {
                    Circle()
                        .stroke(Color.primaryBlue, lineWidth: 3)
                        .frame(width: 180, height: 180)
                        .scaleEffect(isRecording ? 1.2 : 1.0)
                        .opacity(isRecording ? 0.3 : 1.0)
                        .animation(
                            Animation.easeInOut(duration: 1.5)
                                .repeatForever(autoreverses: true),
                            value: isRecording
                        )
                    
                    Circle()
                        .stroke(Color.primaryBlue, lineWidth: 3)
                        .frame(width: 220, height: 220)
                        .scaleEffect(isRecording ? 1.3 : 1.0)
                        .opacity(isRecording ? 0.2 : 1.0)
                        .animation(
                            Animation.easeInOut(duration: 1.5)
                                .repeatForever(autoreverses: true)
                                .delay(0.3),
                            value: isRecording
                        )
                    
                    Circle()
                        .stroke(Color.primaryBlue, lineWidth: 3)
                        .frame(width: 260, height: 260)
                        .scaleEffect(isRecording ? 1.4 : 1.0)
                        .opacity(isRecording ? 0.1 : 1.0)
                        .animation(
                            Animation.easeInOut(duration: 1.5)
                                .repeatForever(autoreverses: true)
                                .delay(0.6),
                            value: isRecording
                        )
                }
                
                // Bouton central
                Circle()
                    .fill(Color.primaryBlue)
                    .frame(width: 140, height: 140)
                    .shadow(color: Color.primaryBlue.opacity(0.3), radius: 20, x: 0, y: 10)
                
                Image(systemName: "mic.fill")
                    .font(.system(size: 50, weight: .medium))
                    .foregroundColor(.white)
            }
        }
        .accessibilityIdentifier("microphoneButton")
        .accessibilityLabel("Microphone")
        .accessibilityHint(isRecording ? "Enregistrement en cours, appuyez pour arrêter" : "Appuyez pour commencer l'enregistrement")
    }
}

// Bouton de validation
struct ValidationButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Color.primaryBlue)
                    .frame(width: 140, height: 140)
                    .shadow(color: Color.primaryBlue.opacity(0.3), radius: 20, x: 0, y: 10)
                
                Image(systemName: "checkmark")
                    .font(.system(size: 60, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        .accessibilityIdentifier("validationButton")
        .accessibilityLabel("Valider")
        .accessibilityHint("Appuyez pour valider et passer à l'étape suivante")
    }
}
