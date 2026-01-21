import SwiftUI

struct ParametreCard: View {
    let section: ParametreSection
    @Binding var volume: Double
    @Binding var isUrbanSpace: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Titre de la section
            Text(section.titre)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(Color.primaryText)
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 12)
            
            // Contenu de la section
            VStack(spacing: 0) {
                ForEach(Array(section.items.enumerated()), id: \.offset) { index, item in
                    if index > 0 {
                        Divider()
                            .padding(.horizontal, 24)
                    }
                    
                    parameterRow(for: item)
                }
            }
            .padding(.bottom, 16)
        }
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
    }
    
    @ViewBuilder
    private func parameterRow(for item: ParametreItem) -> some View {
        switch item {
        case .volume:
            VolumeSlider(volume: $volume)
        case .milieuUrbain:
            ToggleRow(
                title: "Milieu urbain",
                isOn: Binding(
                    get: { isUrbanSpace },
                    set: { newValue in
                        if newValue {
                            isUrbanSpace = true
                        }
                    }
                )
            )
        case .espaceInterieur:
            ToggleRow(
                title: "Espace intérieur",
                isOn: Binding(
                    get: { !isUrbanSpace },
                    set: { newValue in
                        if newValue {
                            isUrbanSpace = false
                        }
                    }
                )
            )
        }
    }
}

// Composant pour le slider de volume
struct VolumeSlider: View {
    @Binding var volume: Double
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "speaker.fill")
                .font(.system(size: 18))
                .foregroundColor(Color.secondaryText)
            
            Slider(value: $volume, in: 0...1)
                .tint(Color.primaryBlue)
                .accessibilityIdentifier("volumeSlider")
                .accessibilityLabel("Volume")
                .accessibilityValue("\(Int(volume * 100))%")
            
            Image(systemName: "speaker.wave.3.fill")
                .font(.system(size: 18))
                .foregroundColor(Color.secondaryText)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
    }
}

// Composant pour les lignes avec toggle
struct ToggleRow: View {
    let title: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(Color.primaryText)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(Color.primaryBlue)
                .accessibilityIdentifier("\(title)Toggle")
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title)
        .accessibilityValue(isOn ? "Activé" : "Désactivé")
    }
}
