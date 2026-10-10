//
//  triunfoApp.swift
//  triunfo
//
//  Created by Henrique Delben on 09/09/26.
//

import SwiftUI

@main
struct triunfoApp: App {

    static let inboxLocation = URL.documentsDirectory.appending(path: "inbox", directoryHint: .isDirectory)

    @State private var inboxManager = InboxManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(inboxManager)
                .task {
                    do {
                        let fileManager = FileManager.default
                        if !fileManager.fileExists(atPath: triunfoApp.inboxLocation.path(percentEncoded: false)) {
                            try fileManager.createDirectory(
                                at: triunfoApp.inboxLocation,
                                withIntermediateDirectories: true
                            )
                        }
                        let store = try FSStore(location: triunfoApp.inboxLocation)
                        inboxManager.use(store: store)
                        inboxManager.loadEntries()
                    } catch {
                        // TODO: surface a user-facing error instead of crashing
                        print("Failed to set up Inbox: \(error)")
                    }
                }
        }
    }
}
