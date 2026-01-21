import SwiftUI

struct FaceIDButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Color.primaryBlue)
                    .frame(width: 184, height: 184)
                    .shadow(color: Color.primaryBlue.opacity(0.3), radius: 20, x: 0, y: 10)
                
                // Utiliser l'image personnalisée si disponible, sinon icône système
                if let _ = UIImage(named: "asset_faceId") {
                    Image("asset_faceId")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.white)
                } else {
                    Image(systemName: "faceid")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.white)
                }
            }
        }
        .accessibilityIdentifier("faceIDButton")
        .accessibilityLabel("Face ID")
        .accessibilityHint("Appuyez pour vous authentifier avec Face ID")
    }
}
