import XCTest

final class FaceIDAuthenticationUITests: XCTestCase {
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        
        // NE PAS ajouter UI-Testing pour forcer l'utilisation du vrai Face ID
        app.launchArguments = [] // Pas de bypass
        app.launch()
    }
    
    // Test 1: Le bouton Face ID existe sur la page d'accueil
    func testFaceIDButtonExists() throws {
        let faceIDButton = app.buttons["faceIDButton"]
        XCTAssertTrue(faceIDButton.exists, "Le bouton Face ID devrait exister sur la page d'accueil")
    }
    
    // Test 2: Le titre EchoNav est visible sur la page Face ID
    func testEchoNavTitleVisible() throws {
        let title = app.staticTexts["EchoNav"]
        XCTAssertTrue(title.exists, "Le titre EchoNav devrait être visible")
    }
    
    // Test 3: Cliquer sur Face ID déclenche une action (popup ou navigation)
    func testFaceIDButtonIsInteractive() throws {
        let faceIDButton = app.buttons["faceIDButton"]
        XCTAssertTrue(faceIDButton.exists)
        
        // Vérifier que le bouton est interactif
        XCTAssertTrue(faceIDButton.isHittable, "Le bouton Face ID devrait être cliquable")
    }
    
    // Test 4: Test avec bypass simulé (pour CI/CD)
    func testFaceIDBypassForAutomation() throws {
        // Relancer l'app avec le flag de test
        app.terminate()
        app.launchArguments = ["UI-Testing"]
        app.launch()
        
        let faceIDButton = app.buttons["faceIDButton"]
        faceIDButton.tap()
        
        // Avec bypass, la navigation devrait réussir rapidement
        let navButton = app.buttons["NavButton"]
        XCTAssertTrue(navButton.waitForExistence(timeout: 3), "Navigation avec bypass devrait réussir")
    }
}
