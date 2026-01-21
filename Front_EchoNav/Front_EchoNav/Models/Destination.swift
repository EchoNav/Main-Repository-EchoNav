import Foundation

struct Destination: Identifiable, Codable {
    let id: UUID
    let nom: String
    let rue: String
    
    init(id: UUID = UUID(), nom: String, rue: String) {
        self.id = id
        self.nom = nom
        self.rue = rue
    }
}
