import Foundation

struct ParametreSection: Identifiable {
    let id = UUID()
    let titre: String
    let items: [ParametreItem]
}

enum ParametreItem {
    case volume
    case milieuUrbain
    case espaceInterieur
}
