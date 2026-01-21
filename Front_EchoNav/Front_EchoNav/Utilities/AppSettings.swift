import Foundation

class AppSettings: ObservableObject {
    @Published var volume: Double {
        didSet {
            UserDefaults.standard.set(volume, forKey: "appVolume")
        }
    }
    
    @Published var isUrbanSpace: Bool {
        didSet {
            UserDefaults.standard.set(isUrbanSpace, forKey: "isUrbanSpace")
        }
    }
    
    init() {
        // Charger les valeurs sauvegardées ou utiliser les valeurs par défaut
        self.volume = UserDefaults.standard.object(forKey: "appVolume") as? Double ?? 0.5
        self.isUrbanSpace = UserDefaults.standard.object(forKey: "isUrbanSpace") as? Bool ?? true
    }
}
