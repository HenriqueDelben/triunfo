//
//  triunfoUITestsLaunchTests.swift
//  triunfoUITests
//
//  Created by Henrique Delben on 09/09/26.
//

import XCTest

final class captureUseCase: XCTestCase {
    
    override func setUpWithError() throws {
        if let content = try? FileManager.default.contentsOfDirectory(at: URL.documentsDirectory, includingPropertiesForKeys: nil) {
            for entry in content {
                print("Removing items from previous tests at relative path: \(entry.relativePath)")
                try! FileManager.default.removeItem(at: entry)
            }
        } else {
            print("Could not get contents of the file for deleting in setup()")
        }
        continueAfterFailure = false
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    /// # UC: Capture Task
     /// # Given I capture something, when I relaunch the app, then it's in my inbox.
    @MainActor
    func testGivenUserCapturesSomething_whenAppIsRelaunched_thenItsInInbox() {
        let appDriver = AppDriver()
        appDriver.start()
        appDriver.captureInputFieldHasBeenFocused()
        let note = "my first note"
        appDriver.capture(note)
        appDriver.stop()
        appDriver.start()
        appDriver.noteHasBeenCaptured(title: note)
    }
    
    // Given user entered text, when he presses delete button, then capture field is cleared
    // Given capture input is active, when user enters actionable phrase, then a task is created
    // GIven capture input is active, when user enters a non actionable phrase, then a refernece is created
    // Given capture input is active, when user enters an actionable phrase specifying a date, it creates a upcoming task
    // Given capture input is active, when user enters a actionable phrase specifying a project, it creates a task in the project
    // Given capture input is active, when user enters a actionable phrase specifying a reference note, it creates a task with associated reference
}
