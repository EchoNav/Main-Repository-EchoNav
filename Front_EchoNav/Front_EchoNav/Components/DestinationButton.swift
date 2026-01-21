import SwiftUI

struct DestinationButton: View {
    let destination: Destination
    @EnvironmentObject var destinationStorage: DestinationStorage
    @State private var isExpanded = false
    @State private var showDeleteConfirmation = false
    @State private var showEditView = false // ← Ajoute ceci
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Bouton principal (toujours visible)
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        isExpanded.toggle()
                    }
                }) {
                    HStack {
                        Text(destination.nom)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(Color.primaryText)
                        
                        Spacer()
                        
                        Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color.secondaryText)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 20)
                }
                .accessibilityIdentifier("\(destination.nom)Button")
                .accessibilityLabel(destination.nom)
                
                // Contenu déployé (adresse + boutons)
                if isExpanded {
                    VStack(spacing: 16) {
                        Divider()
                            .padding(.horizontal, 24)
                        
                        // Adresse avec icône
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "location.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.red)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(destination.rue)
                                    .font(.system(size: 17, weight: .regular))
                                    .foregroundColor(Color.primaryText)
                                    .multilineTextAlignment(.leading)
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal, 24)
                        
                        // Boutons Supprimer et Modifier
                        HStack(spacing: 16) {
                            // Bouton Supprimer (Corbeille)
                            Button(action: {
                                showDeleteConfirmation = true
                            }) {
                                Image(systemName: "trash.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.white)
                                    .frame(width: 50, height: 50)
                                    .background(Color.red)
                                    .clipShape(Circle())
                            }
                            .accessibilityLabel("Supprimer \(destination.nom)")
                            
                            Spacer()
                            
                            // Bouton Modifier
                            Button(action: {
                                showEditView = true
                            }) {
                                Text("Modifier")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 28)
                                    .padding(.vertical, 12)
                                    .background(Color.primaryBlue)
                                    .cornerRadius(20)
                            }
                            .accessibilityLabel("Modifier \(destination.nom)")
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 16)
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
            .accessibilityElement(children: .contain)
            .alert("Supprimer la destination", isPresented: $showDeleteConfirmation) {
                Button("Annuler", role: .cancel) { }
                Button("Supprimer", role: .destructive) {
                    deleteDestination()
                }
            } message: {
                Text("Voulez-vous vraiment supprimer '\(destination.nom)' ?")
            }
            
            // Page d'édition en plein écran
            if showEditView {
                AddressInputView(
                    isPresented: $showEditView,
                    editingDestination: destination // ← Passer la destination à éditer
                )
                .transition(.move(edge: .bottom))
                .zIndex(2)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showEditView)
    }
    
    private func deleteDestination() {
        withAnimation {
            destinationStorage.deleteDestination(destination)
        }
    }
}
