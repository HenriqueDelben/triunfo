//
//  harness.swift
//  triunfo
//
//  Created by Henrique Delben on 09/09/26.
//
import XCTest

enum AppError: Error {
    case CaptureIsUnfocused
}
class AppDriver {
    private let CAPTURE_FIELD_NAME = "capture_input"
    private let app = XCUIApplication()
    private var appIsRunning: Bool {
        switch app.state {
        case .notRunning, .unknown:
            return false
        default:
            return true
        }
    }
    
    func captureInputFieldHasBeenFocused() {
        guard appIsRunning else {
            XCTFail("App is not running")
            return
        }
        
        let inputField = app.textFields[CAPTURE_FIELD_NAME]
        guard inputField.waitForExistence(timeout: 2) else {
            XCTFail("Couldn't find Capture input field")
            return
        }
        
        let hasFocus = inputField.hasFocus || ((inputField.value(forKey: "hasKeyboardFocus") as? Bool) ?? false)
        XCTAssertTrue(hasFocus, "Capture input field is not focused")
    }
    
    func start() {
        app.launch()
    }
    
    func stop() {
        app.terminate()
    }
    
    func capture(_ text: String) {
        let inputField = app.textFields[CAPTURE_FIELD_NAME]
        inputField.typeText(text)
        app.keyboards.buttons["Return"].tap()
    }
    
    func noteHasBeenCaptured(title: String) {
        let noteTitle = app.staticTexts[title]
        guard noteTitle.waitForExistence(timeout: 2) else {
            XCTFail("Couldn't find inbox entry. Note \"\(title)\" not created")
            return
        }
    }
}
// pegar view lista de inbox
// verificar que ha entrada na lista com titulo/texto $title
