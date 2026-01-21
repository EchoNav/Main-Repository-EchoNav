import Foundation

class DestinationStorage: ObservableObject {
    @Published var destinations: [Destination] = []
    
    private let destinationsKey = "savedDestinations"
    
    init() {
        loadDestinations()
    }
    
    // Charger les destinations depuis UserDefaults
    func loadDestinations() {
        // Vérifier si on est en mode test UI
        if ProcessInfo.processInfo.arguments.contains("with-test-destinations") {
            // Charger les destinations de test
            destinations = [
                Destination(nom: "Maison", rue: "123 Rue de la République, Paris"),
                Destination(nom: "Travail", rue: "456 Avenue des Champs-Élysées, Paris"),
                Destination(nom: "Course", rue: "789 Boulevard Saint-Germain, Paris")
            ]
            return
        }
        
        if let data = UserDefaults.standard.data(forKey: destinationsKey),
           let decoded = try? JSONDecoder().decode([Destination].self, from: data) {
            destinations = decoded
        } else {
            // Aucune destination par défaut en production
            destinations = []
        }
    }
    
    // Sauvegarder les destinations dans UserDefaults
    func saveDestinations() {
        if let encoded = try? JSONEncoder().encode(destinations) {
            UserDefaults.standard.set(encoded, forKey: destinationsKey)
        }
    }
    
    // Ajouter une destination
    func addDestination(nom: String, rue: String) {
        let newDestination = Destination(nom: nom, rue: rue)
        destinations.append(newDestination)
        saveDestinations()
    }
    
    // Supprimer une destination
    func deleteDestination(_ destination: Destination) {
        destinations.removeAll { $0.id == destination.id }
        saveDestinations()
        print("Destination '\(destination.nom)' supprimée")
    }
    
    // Mettre à jour l'adresse d'une destination
    func updateDestination(_ destination: Destination, newAddress: String) {
        if let index = destinations.firstIndex(where: { $0.id == destination.id }) {
            let updatedDestination = Destination(
                id: destination.id,
                nom: destination.nom,
                rue: newAddress
            )
            destinations[index] = updatedDestination
            saveDestinations()
            print("Destination '\(destination.nom)' mise à jour avec l'adresse: \(newAddress)")
        }
    }
}
