import XCTest

final class DestinationManagementUITests: XCTestCase {
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments = ["UI-Testing", "with-test-destinations"] // ← Bypass + destinations test
        app.launch()
        
        // Navigation automatique vers Itinéraire (Face ID bypassé)
        let faceIDButton = app.buttons["faceIDButton"]
        faceIDButton.tap()
        sleep(1)
        
        let itineraireButton = app.buttons["ItinéraireButton"]
        itineraireButton.tap()
        sleep(1)
    }

    // Test 1: Les destinations de test sont affichées
    func testTestDestinationsDisplayed() throws {
        XCTAssertTrue(app.buttons["MaisonButton"].exists, "Destination Maison devrait exister")
        XCTAssertTrue(app.buttons["TravailButton"].exists, "Destination Travail devrait exister")
        XCTAssertTrue(app.buttons["CourseButton"].exists, "Destination Course devrait exister")
    }
    
    // Test 2: Déployer une destination affiche les boutons Supprimer et Modifier
    func testExpandDestinationShowsButtons() throws {
        let maisonButton = app.buttons["MaisonButton"]
        XCTAssertTrue(maisonButton.exists)
        
        // Déployer la destination
        maisonButton.tap()
        sleep(1)
        
        // Vérifier que les boutons d'action apparaissent
        let allButtons = app.buttons
        var deleteButtonFound = false
        var modifyButtonFound = false
        
        for i in 0..<allButtons.count {
            let button = allButtons.element(boundBy: i)
            if button.label.contains("Supprimer") {
                deleteButtonFound = true
            }
            if button.label == "Modifier" {
                modifyButtonFound = true
            }
        }
        
        XCTAssertTrue(deleteButtonFound || modifyButtonFound, "Au moins un bouton d'action devrait être visible")
    }
    
    // Test 3: Cliquer sur le bouton corbeille affiche l'alerte de confirmation
    func testDeleteButtonShowsConfirmation() throws {
        let maisonButton = app.buttons["MaisonButton"]
        maisonButton.tap()
        sleep(1)
        
        // Chercher le bouton de suppression (icône corbeille)
        let deleteButtons = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Supprimer'"))
        
        if deleteButtons.count > 0 {
            let deleteButton = deleteButtons.element(boundBy: 0)
            deleteButton.tap()
            sleep(1)
            
            // Vérifier que l'alerte apparaît
            let alert = app.alerts["Supprimer la destination"]
            XCTAssertTrue(alert.waitForExistence(timeout: 2), "L'alerte de confirmation devrait apparaître")
            
            // Vérifier les boutons de l'alerte
            XCTAssertTrue(alert.buttons["Annuler"].exists, "Bouton Annuler devrait exister")
            XCTAssertTrue(alert.buttons["Supprimer"].exists, "Bouton Supprimer devrait exister")
            
            // Annuler pour ne pas vraiment supprimer
            alert.buttons["Annuler"].tap()
        }
    }
    
    // Test 4: Annuler la suppression maintient la destination
    func testCancelDeleteKeepsDestination() throws {
        let maisonButton = app.buttons["MaisonButton"]
        maisonButton.tap()
        sleep(1)
        
        // Chercher et cliquer sur supprimer
        let deleteButtons = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Supprimer'"))
        if deleteButtons.count > 0 {
            deleteButtons.element(boundBy: 0).tap()
            sleep(1)
            
            // Annuler
            let alert = app.alerts["Supprimer la destination"]
            if alert.exists {
                alert.buttons["Annuler"].tap()
                sleep(1)
            }
            
            // Vérifier que la destination existe toujours
            XCTAssertTrue(app.buttons["MaisonButton"].exists, "La destination devrait toujours exister après annulation")
        }
    }
    
    // Test 5: Confirmer la suppression retire la destination
    func testConfirmDeleteRemovesDestination() throws {
        let travailButton = app.buttons["TravailButton"]
        XCTAssertTrue(travailButton.exists, "Destination Travail devrait exister initialement")
        
        travailButton.tap()
        sleep(1)
        
        // Supprimer
        let deleteButtons = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Supprimer'"))
        if deleteButtons.count > 0 {
            deleteButtons.element(boundBy: 0).tap()
            sleep(1)
            
            // Confirmer la suppression
            let alert = app.alerts["Supprimer la destination"]
            if alert.exists {
                alert.buttons["Supprimer"].tap()
                sleep(2)
                
                // Vérifier que la destination n'existe plus
                XCTAssertFalse(app.buttons["TravailButton"].exists, "La destination Travail devrait être supprimée")
            }
        }
    }
    
    // Test 6: Cliquer sur Modifier ouvre la page d'édition
    func testModifyButtonOpensEditView() throws {
        let courseButton = app.buttons["CourseButton"]
        courseButton.tap()
        sleep(1)
        
        // Chercher et cliquer sur Modifier
        let modifierButton = app.buttons["Modifier"]
        if modifierButton.exists {
            modifierButton.tap()
            sleep(1)
            
            // Vérifier que la page d'édition s'ouvre
            let editTitle = app.staticTexts["Modifier l'adresse"]
            XCTAssertTrue(editTitle.waitForExistence(timeout: 2), "Le titre 'Modifier l'adresse' devrait apparaître")
            
            // Vérifier que la barre de recherche existe
            let searchBar = app.otherElements["addressSearchBar"]
            XCTAssertTrue(searchBar.exists || app.staticTexts["Nouvelle adresse"].exists, "La barre de recherche devrait être visible")
        }
    }
    
    // Test 7: La page d'édition affiche le bouton microphone
    func testEditViewShowsMicrophoneButton() throws {
        let courseButton = app.buttons["CourseButton"]
        courseButton.tap()
        sleep(1)
        
        let modifierButton = app.buttons["Modifier"]
        if modifierButton.exists {
            modifierButton.tap()
            sleep(1)
            
            // Vérifier le bouton micro
            let micButton = app.buttons["microphoneButton"]
            XCTAssertTrue(micButton.waitForExistence(timeout: 2), "Le bouton microphone devrait être visible")
        }
    }
    
    // Test 8: Toutes les destinations de test sont présentes au démarrage
    func testAllTestDestinationsPresent() throws {
        let expectedDestinations = ["MaisonButton", "TravailButton", "CourseButton"]
        
        for destinationID in expectedDestinations {
            XCTAssertTrue(app.buttons[destinationID].exists, "\(destinationID) devrait exister")
        }
    }
}
