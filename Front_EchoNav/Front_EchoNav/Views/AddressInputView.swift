import SwiftUI
import Speech

struct AddressInputView: View {
    @EnvironmentObject var destinationStorage: DestinationStorage
    @Binding var isPresented: Bool
    
    // Nouveau : paramètres pour le mode édition
    var editingDestination: Destination? = nil // Si non nil, on est en mode édition
    
    @StateObject private var speechRecognizer = SpeechRecognizer()
    @State private var currentStep: InputStep = .addressListening
    @State private var addressText: String = ""
    @State private var nameText: String = ""
    
    enum InputStep {
        case addressListening
        case addressValidation
        case nameListening
        case nameValidation
    }
    
    var body: some View {
        ZStack {
            Color.lightGray
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 40)
                
                // Titre selon le mode
                Text(isEditMode ? "Modifier l'adresse" : "Nouvelle destination")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color.primaryBlue)
                    .padding(.bottom, 20)
                
                // Barre de recherche
                SearchBar(
                    text: currentStep == .addressListening || currentStep == .addressValidation ? $addressText : $nameText,
                    placeholder: isEditMode ? "Nouvelle adresse" : (currentStep == .addressListening || currentStep == .addressValidation ? "L'adresse" : "Le nom")
                )
                .padding(.horizontal, 24)
                .padding(.bottom, 60)
                
                Spacer()
                
                // Bouton central (micro ou validation)
                if currentStep == .addressListening || currentStep == .nameListening {
                    MicrophoneButton(
                        isRecording: $speechRecognizer.isRecording,
                        action: {
                            handleMicrophonePress()
                        }
                    )
                } else {
                    ValidationButton(action: {
                        handleValidation()
                    })
                }
                
                Spacer()
                Spacer()
            }
        }
        .onChange(of: speechRecognizer.recognizedText) { oldValue, newValue in
            updateTextFromRecognition(newValue)
        }
        .onAppear {
            setupEditMode()
        }
    }
    
    // Vérifier si on est en mode édition
    private var isEditMode: Bool {
        return editingDestination != nil
    }
    
    // Configuration initiale pour le mode édition
    private func setupEditMode() {
        if let destination = editingDestination {
            // Mode édition : on édite juste l'adresse
            addressText = destination.rue
            nameText = destination.nom
            currentStep = .addressListening
        }
    }
    
    private func handleMicrophonePress() {
        if speechRecognizer.isRecording {
            speechRecognizer.stopRecording()
            // Basculer vers la validation
            if currentStep == .addressListening {
                currentStep = .addressValidation
            } else if currentStep == .nameListening {
                currentStep = .nameValidation
            }
        } else {
            if speechRecognizer.isAuthorized {
                speechRecognizer.startRecording()
            } else {
                print("Permission microphone refusée")
            }
        }
    }
    
    private func updateTextFromRecognition(_ text: String) {
        if currentStep == .addressListening {
            addressText = text
        } else if currentStep == .nameListening {
            nameText = text
        }
    }
    
    private func handleValidation() {
        if isEditMode {
            // Mode édition : on modifie juste l'adresse
            if currentStep == .addressValidation {
                // Mettre à jour la destination existante
                if let destination = editingDestination {
                    destinationStorage.updateDestination(destination, newAddress: addressText)
                }
                isPresented = false
            }
        } else {
            // Mode création : processus normal
            switch currentStep {
            case .addressValidation:
                currentStep = .nameListening
                
            case .nameValidation:
                destinationStorage.addDestination(nom: nameText, rue: addressText)
                isPresented = false
                
            default:
                break
            }
        }
    }
}

#Preview {
    AddressInputView(isPresented: .constant(true))
        .environmentObject(DestinationStorage())
}

