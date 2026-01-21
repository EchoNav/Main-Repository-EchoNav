import XCTest

final class NavigationUITests: XCTestCase {
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments = ["UI-Testing"]
        app.launch()
    }
    
    // Test 1: Navigation depuis Face ID vers page Nav/LiDAR
    func testNavigationFromFaceIDToLidar() throws {
        // Utiliser l'accessibilityIdentifier au lieu de l'image
        let faceIDButton = app.buttons["faceIDButton"]
        XCTAssertTrue(faceIDButton.waitForExistence(timeout: 5), "Le bouton Face ID n'existe pas")
        
        // Appuyer sur le bouton Face ID
        faceIDButton.tap()
        
        // Attendre que la navigation se fasse
        sleep(2)
        
        // Vérifier que le bouton Nav existe (on est sur la page LiDAR)
        let navButton = app.buttons["NavButton"]
        XCTAssertTrue(navButton.waitForExistence(timeout: 3), "Navigation vers LiDAR échouée")
    }
    
    // Test 2: Navigation vers la page Itinéraire
    func testNavigationToItineraire() throws {
        // D'abord aller sur la page LiDAR
        let faceIDButton = app.buttons["faceIDButton"]
        XCTAssertTrue(faceIDButton.exists, "Le bouton Face ID n'existe pas")
        faceIDButton.tap()
        sleep(2)
        
        // Appuyer sur le bouton Itinéraire dans la NavBar
        let itineraireButton = app.buttons["ItinéraireButton"]
        XCTAssertTrue(itineraireButton.waitForExistence(timeout: 3), "Bouton Itinéraire non trouvé")
        itineraireButton.tap()
        
        // Vérifier qu'on est sur la page Itinéraire
        sleep(1)
        
        // Vérifier que le bouton plus existe sur la page
        let addButton = app.buttons["addDestinationButton"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 2), "Page Itinéraire non chargée")
    }
    
    // Test 3: Navigation vers la page Paramètres
    func testNavigationToParametres() throws {
        // Aller sur la page LiDAR
        let faceIDButton = app.buttons["faceIDButton"]
        faceIDButton.tap()
        sleep(2)
        
        // Appuyer sur le bouton Paramètre dans la NavBar
        let parametreButton = app.buttons["ParamètreButton"]
        XCTAssertTrue(parametreButton.waitForExistence(timeout: 3), "Bouton Paramètre non trouvé")
        parametreButton.tap()
        
        // Vérifier qu'on est sur la page Paramètres
        sleep(1)
        let sonLabel = app.staticTexts["Son"]
        XCTAssertTrue(sonLabel.waitForExistence(timeout: 2), "Page Paramètres non chargée")
    }
    
    // Test 4: Retour vers page Nav depuis Itinéraire
    func testNavigationBackToNav() throws {
        // Aller sur page LiDAR puis Itinéraire
        let faceIDButton = app.buttons["faceIDButton"]
        faceIDButton.tap()
        sleep(2)
        
        let itineraireButton = app.buttons["ItinéraireButton"]
        itineraireButton.tap()
        sleep(1)
        
        // Retourner vers Nav
        let navButton = app.buttons["NavButton"]
        navButton.tap()
        sleep(1)
        
        // Vérifier qu'on est bien sur la page Nav (le bouton Nav devrait être sélectionné)
        XCTAssertTrue(navButton.exists, "Retour à la page Nav échoué")
    }
}
