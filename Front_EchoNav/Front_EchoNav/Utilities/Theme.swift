import SwiftUI

struct Theme {
    // Typographie selon la charte graphique
    static func title1() -> Font {
        return .custom("SF Pro Display", size: 34).weight(.bold)
    }
    
    static func title2() -> Font {
        return .custom("SF Pro Display", size: 28).weight(.semibold)
    }
    
    static func body() -> Font {
        return .custom("SF Pro Text", size: 17)
    }
    
    static func label() -> Font {
        return .custom("SF Pro Text", size: 17).weight(.medium)
    }
}
