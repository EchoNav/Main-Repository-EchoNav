import SwiftUI

struct ParametresView: View {
    @Binding var selectedTab: Int
    @EnvironmentObject var appSettings: AppSettings
    let parametres = [
        ParametreSection(titre: "Son", items: [.volume]),
        ParametreSection(titre: "Type d'espace", items: [.milieuUrbain, .espaceInterieur])
    ]
    var body: some View {
        ZStack {
            Color.lightGray
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                VStack(spacing: 24) {
                    Spacer()
                        .frame(height: 60)
                    
                    VStack(spacing: 20) {
                        ForEach(parametres) { section in
                            ParametreCard(
                                section: section,
                                volume: $appSettings.volume,
                                isUrbanSpace: $appSettings.isUrbanSpace
                            )
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer()
                }
                
                CustomNavBar(selectedTab: $selectedTab)
                    .padding(.bottom, 20)
            }
        }
    }
}
