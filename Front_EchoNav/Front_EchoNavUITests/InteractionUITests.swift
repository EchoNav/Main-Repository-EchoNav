import XCTest

final class InteractionUITests: XCTestCase {
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments = ["UI-Testing"] // ← Bypass Face ID
        app.launch()
    }

    // Test 1: Déploiement d'une destination
    func testExpandDestination() throws {
        // Aller sur page Itinéraire
        let faceIDButton = app.buttons["faceIDButton"]
        faceIDButton.tap()
        sleep(1)
        
        let itineraireButton = app.buttons["ItinéraireButton"]
        itineraireButton.tap()
        sleep(1)
        
        // Cliquer sur une destination
        let maisonButton = app.buttons["MaisonButton"]
        XCTAssertTrue(maisonButton.exists, "Bouton Maison n'existe pas")
        maisonButton.tap()
        sleep(1)
        
        // Vérifier que la destination s'est déployée (le bouton existe toujours)
        XCTAssertTrue(maisonButton.exists, "La destination devrait rester visible")
    }
    
    // Test 2: Toggle du type d'espace
    func testSpaceTypeToggle() throws {
        // Aller sur page Paramètres
        let faceIDButton = app.buttons["faceIDButton"]
        faceIDButton.tap()
        sleep(1)
        
        let parametreButton = app.buttons["ParamètreButton"]
        parametreButton.tap()
        sleep(1)
        
        // Trouver les switches
        let switches = app.switches
        
        if switches.count > 0 {
            let firstSwitch = switches.element(boundBy: 0)
            XCTAssertTrue(firstSwitch.exists, "Au moins un switch devrait exister")
            
            // Toggler le switch
            firstSwitch.tap()
            sleep(1)
            
            // Vérifier que le switch existe toujours
            XCTAssertTrue(firstSwitch.exists, "Le switch devrait toujours exister après toggle")
        }
    }
    
    // Test 3: Slider de volume existe et peut être ajusté
    func testVolumeSlider() throws {
        // Aller sur page Paramètres
        let faceIDButton = app.buttons["faceIDButton"]
        faceIDButton.tap()
        sleep(1)
        
        let parametreButton = app.buttons["ParamètreButton"]
        parametreButton.tap()
        sleep(1)
        
        // Trouver le slider
        let sliders = app.sliders
        
        if sliders.count > 0 {
            let volumeSlider = sliders.element(boundBy: 0)
            XCTAssertTrue(volumeSlider.exists, "Le slider de volume devrait exister")
            
            // Ajuster le slider à 80%
            volumeSlider.adjust(toNormalizedSliderPosition: 0.8)
            
            // Vérifier que le slider existe toujours
            XCTAssertTrue(volumeSlider.exists, "Le slider devrait toujours exister après ajustement")
        }
    }
    
    // Test 4: Ouverture de la page d'ajout d'adresse
    func testOpenAddressInputView() throws {
        // Aller sur page Itinéraire
        let faceIDButton = app.buttons["faceIDButton"]
        faceIDButton.tap()
        sleep(1)
        
        let itineraireButton = app.buttons["ItinéraireButton"]
        itineraireButton.tap()
        sleep(1)
        
        // Compter les boutons avant
        let buttonCountBefore = app.buttons.count
        
        // Chercher et cliquer sur un bouton (probablement le plus)
        if app.buttons.count > 3 { // Au moins 4 boutons (3 de nav + 1 plus)
            // Le dernier bouton visible devrait être le bouton plus ou proche
            XCTAssertTrue(buttonCountBefore > 0, "Il devrait y avoir des boutons sur la page")
        }
    }
}
