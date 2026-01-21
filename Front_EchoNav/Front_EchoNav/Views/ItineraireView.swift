import SwiftUI

struct ItineraireView: View {
    @Binding var selectedTab: Int
    @EnvironmentObject var destinationStorage: DestinationStorage
    @State private var showAddressInput = false
    
    var body: some View {
        ZStack {
            Color.lightGray
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                VStack(spacing: 20) {
                    Spacer()
                        .frame(height: 60)
                    
                    // Liste des destinations
                    VStack(spacing: 16) {
                        ForEach(destinationStorage.destinations) { destination in
                            DestinationButton(destination: destination)
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer()
                    
                    // Bouton plus central
                    Button(action: {
                        showAddressInput = true
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.primaryBlue)
                                .frame(width: 80, height: 80)
                                .shadow(color: Color.primaryBlue.opacity(0.3), radius: 15, x: 0, y: 10)
                            
                            Image(systemName: "plus")
                                .font(.system(size: 36, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                    .accessibilityIdentifier("addDestinationButton")
                    .accessibilityLabel("Ajouter une destination")
                    .padding(.bottom, 20)
                    
                    Spacer()
                        .frame(height: 20)
                }
                
                // Navigation Bar
                CustomNavBar(selectedTab: $selectedTab)
                    .padding(.bottom, 20)
            }
            
            // Page d'ajout d'adresse en plein écran
            if showAddressInput {
                AddressInputView(isPresented: $showAddressInput)
                    .transition(.move(edge: .bottom))
                    .zIndex(1)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showAddressInput)
    }
}
