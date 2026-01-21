import SwiftUI

struct LidarView: View {
    @State private var selectedTab = 0 // Tab Nav sélectionnée par défaut
    
    var body: some View {
        ZStack {
            // Afficher le contenu selon l'onglet sélectionné
            if selectedTab == 0 {
                // Page Nav (LiDAR)
                navContent
            } else if selectedTab == 1 {
                // Page Itinéraire
                ItineraireView(selectedTab: $selectedTab)
            } else {
                // Page Paramètres
                ParametresView(selectedTab: $selectedTab)
            }
        }
    }
    
    // Contenu de la page Nav (LiDAR)
    private var navContent: some View {
        ZStack {
            Color.lightGray
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                // Titre
                Text("EchoNav")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(Color.primaryBlue)
                    .padding(.bottom, 60)
                
                // Gros bouton central avec logo
                Button(action: {
                    startLidarScan()
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 30)
                            .fill(Color.primaryBlue)
                            .frame(width: 200, height: 200)
                            .shadow(color: Color.primaryBlue.opacity(0.3), radius: 25, x: 0, y: 15)
                        
                        Image("logo_echoNav")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .foregroundColor(.white)
                    }
                }
                
                Spacer()
                
                // Navigation Bar
                CustomNavBar(selectedTab: $selectedTab)
                    .padding(.bottom, 20)
            }
        }
    }
    

    
    private func startLidarScan() {
        print("Démarrage du scan LiDAR")
    }
}

#Preview {
    LidarView()
}
