import SwiftUI

@main
struct EchoNavApp: App {
    @StateObject private var destinationStorage = DestinationStorage()
    @StateObject private var appSettings = AppSettings()
    
    var body: some Scene {
        WindowGroup {
            FaceIDView()
                .environmentObject(destinationStorage)
                .environmentObject(appSettings)
        }
    }
}
