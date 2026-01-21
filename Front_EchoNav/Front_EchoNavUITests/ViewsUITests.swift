import XCTest

final class ViewsUITests: XCTestCase {
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments = ["UI-Testing"] // ← Bypass Face ID
        app.launch()
    }

    
    // Test 1: Page Face ID affiche correctement
    func testFaceIDViewRendering() throws {
        // Vérifier le titre EchoNav
        let title = app.staticTexts["EchoNav"]
        XCTAssertTrue(title.exists, "Le titre EchoNav devrait exister")
        
        // Vérifier le bouton Face ID
        let faceIDButton = app.buttons["faceIDButton"]
        XCTAssertTrue(faceIDButton.exists, "Le bouton Face ID devrait exister")
    }
    
    // Test 2: Page LiDAR affiche correctement après navigation
    func testLidarViewRendering() throws {
        // Aller sur la page LiDAR
        let faceIDButton = app.buttons["faceIDButton"]
        faceIDButton.tap()
        sleep(1)
        
        // Vérifier que la NavBar existe
        let navButton = app.buttons["NavButton"]
        XCTAssertTrue(navButton.exists, "Le bouton Nav devrait exister sur la page LiDAR")
    }
    
    // Test 3: Page Itinéraire affiche les destinations
    func testItineraireViewRendering() throws {
        // Navigation
        let faceIDButton = app.buttons["faceIDButton"]
        faceIDButton.tap()
        sleep(1)
        
        let itineraireButton = app.buttons["ItinéraireButton"]
        itineraireButton.tap()
        sleep(1)
        
        // Vérifier les éléments
        XCTAssertTrue(app.buttons["MaisonButton"].exists, "Maison devrait être visible")
        XCTAssertTrue(app.buttons["CourseButton"].exists, "Course devrait être visible")
    }
    
    // Test 4: Page Paramètres affiche les sections
    func testParametresViewRendering() throws {
        // Navigation
        let faceIDButton = app.buttons["faceIDButton"]
        faceIDButton.tap()
        sleep(1)
        
        let parametreButton = app.buttons["ParamètreButton"]
        parametreButton.tap()
        sleep(1)
        
        // Vérifier les sections
        XCTAssertTrue(app.staticTexts["Son"].exists, "Section Son devrait exister")
        XCTAssertTrue(app.staticTexts["Type d'espace"].exists, "Section Type d'espace devrait exister")
    }
    
    // Test 5: Tous les éléments de la NavBar sont visibles
    func testAllNavBarElementsVisible() throws {
        // Aller sur n'importe quelle page avec NavBar
        let faceIDButton = app.buttons["faceIDButton"]
        faceIDButton.tap()
        sleep(1)
        
        // Compter les boutons de navigation
        let navButton = app.buttons["NavButton"]
        let itineraireButton = app.buttons["ItinéraireButton"]
        let parametreButton = app.buttons["ParamètreButton"]
        
        XCTAssertTrue(navButton.exists, "NavButton devrait être visible")
        XCTAssertTrue(itineraireButton.exists, "ItinéraireButton devrait être visible")
        XCTAssertTrue(parametreButton.exists, "ParamètreButton devrait être visible")
    }
}
