import SwiftUI

struct CustomNavBar: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        HStack(spacing: 0) {
            // Bouton Nav
            NavBarButton(
                imageNameBlue: "asset_nav_blue",
                imageNameGrey: "asset_nav_grey",
                text: "Nav",
                isSelected: selectedTab == 0,
                action: {
                    selectedTab = 0
                }
            )
            
            Spacer()
            
            // Bouton Itinéraire
            NavBarButton(
                imageNameBlue: "asset_onde_blue",
                imageNameGrey: "asset_onde_grey",
                text: "Itinéraire",
                isSelected: selectedTab == 1,
                action: {
                    selectedTab = 1
                }
            )
            
            Spacer()
            
            // Bouton Paramètre
            NavBarButton(
                imageNameBlue: "asset_param_blue",
                imageNameGrey: "asset_param_grey",
                text: "Paramètre",
                isSelected: selectedTab == 2,
                action: {
                    selectedTab = 2
                }
            )
        }
        .padding(.horizontal, 30)
        .padding(.vertical, 24)
        .background(Color.white)
        .cornerRadius(25)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        .frame(width: 377)
    }
}

struct NavBarButton: View {
    let imageNameBlue: String
    let imageNameGrey: String
    let text: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(isSelected ? imageNameBlue : imageNameGrey)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                
                Text(text)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(isSelected ? Color.primaryBlue : Color.secondaryText)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
        .accessibilityIdentifier("\(text)Button")
        .accessibilityLabel(text)
        .accessibilityHint(isSelected ? "Sélectionné" : "Appuyez pour accéder à \(text)")
    }
}
