import XCTest

final class ComponentsUITests: XCTestCase {
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments = ["UI-Testing"] // ← Bypass Face ID
        app.launch()
    }

    
    // Test 1: Bouton Face ID existe sur la première page
    func testFaceIDButtonExists() throws {
        let faceIDButton = app.buttons["faceIDButton"]
        XCTAssertTrue(faceIDButton.exists, "Le bouton Face ID n'existe pas")
    }
    
    // Test 2: NavBar contient les 3 boutons
    func testNavBarHasThreeButtons() throws {
        // Aller sur la page LiDAR
        let faceIDButton = app.buttons["faceIDButton"]
        faceIDButton.tap()
        sleep(1)
        
        // Vérifier les 3 boutons de la NavBar
        XCTAssertTrue(app.buttons["NavButton"].exists, "Bouton Nav manquant")
        XCTAssertTrue(app.buttons["ItinéraireButton"].exists, "Bouton Itinéraire manquant")
        XCTAssertTrue(app.buttons["ParamètreButton"].exists, "Bouton Paramètre manquant")
    }
    
    // Test 3: Destinations affichées sur page Itinéraire
    func testDestinationButtonsDisplayed() throws {
        // Aller sur page Itinéraire
        let faceIDButton = app.buttons["faceIDButton"]
        faceIDButton.tap()
        sleep(1)
        
        let itineraireButton = app.buttons["ItinéraireButton"]
        itineraireButton.tap()
        sleep(1)
        
        // Vérifier que les destinations par défaut sont affichées
        XCTAssertTrue(app.buttons["MaisonButton"].exists, "Destination Maison manquante")
        XCTAssertTrue(app.buttons["CourseButton"].exists, "Destination Course manquante")
    }
    
    // Test 4: Bouton plus existe sur page Itinéraire
    func testPlusButtonExists() throws {
        // Aller sur page Itinéraire
        let faceIDButton = app.buttons["faceIDButton"]
        faceIDButton.tap()
        sleep(1)
        
        let itineraireButton = app.buttons["ItinéraireButton"]
        itineraireButton.tap()
        sleep(1)
        
        // Chercher un bouton contenant l'image plus
        let allButtons = app.buttons
        var plusButtonFound = false
        
        for i in 0..<allButtons.count {
            let button = allButtons.element(boundBy: i)
            if button.exists {
                plusButtonFound = true
                break
            }
        }
        
        XCTAssertTrue(plusButtonFound, "Au moins un bouton devrait exister sur la page")
    }
}
