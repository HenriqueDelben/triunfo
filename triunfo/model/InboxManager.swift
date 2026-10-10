//
//  InboxManager.swift
//  triunfo
//
//  Created by Henrique Delben on 19/09/26.
//
import Observation
import Foundation

@Observable
class InboxManager {
    private var store: (any Store)?
    // TODO implement grouping by date: today, last 7 days, last 30 days
    private(set) var entries: [Entry] = []


    init(store: (any Store)? = nil) {
        self.store = store
    }

    func use(store: any Store) {
        self.store = store
    }

    func captureEntry(with entry: String) {
        guard let store else {
            print("Store not ready yet — cannot capture entry")
            return
        }
        do {
            try store.save(capture: entry)
            loadEntries()
        }
        catch {
            print("Could not capture note: \(error)")
            // TODO show an popup alerting invalid capture
        }
    }

    func loadEntries() {
        guard let store else { return }
        do {
            self.entries = try store.load()
        }
        catch {
            print("Couldn't fetch files in inbox: \(error)")
        }
    }
}

