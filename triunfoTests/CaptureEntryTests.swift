//
//  CaptureEntry.swift
//  triunfo
//
//  Created by Henrique Delben on 19/09/26.
//
import Testing
import Mockable
@testable import triunfo
import Foundation

@Suite("Unit Tests for InboxManager")
struct InboxManagerTests {
    @Test("when capturing an entry, InboxManager calls Store to save it and reloads entries")
    func captureInboxEntry() {
        lazy var store = MockStore()
        let note = "my first note"
        given(store).save(capture: .any).willReturn()
        given(store).load().willReturn([])
        
        let inbox = InboxManager(store: store)
        inbox.captureEntry(with: note)
        
        verify(store).save(capture: .value(note)).called(.once)
        verify(store).load().called(.once)
    }
    
    @Test("given there are inbox entries, loading refreshes the published entries")
    func retrieveInboxEntries() {
        lazy var store = MockStore()
        let entry1 = Entry(title: "My first note", content: "something", lastUpdatedDate: Date())
        let entry2 = Entry(title: "My first note", content: "something", lastUpdatedDate: Date())
        given(store).load().willReturn([entry1, entry2])
        
        let inbox = InboxManager(store: store)
        #expect(inbox.entries != [entry1, entry2])
        inbox.loadEntries()
        verify(store).load().called(.once)

        #expect(inbox.entries == [entry1, entry2])
    }
}

@Suite("Integration Tests for Store adapter layer")
struct StoreTests {
    let base = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    init() {
        let fileManager = FileManager.default
        if let contents = try? fileManager.contentsOfDirectory(at: base, includingPropertiesForKeys: nil) {
            for item in contents {
                try? fileManager.removeItem(at: item)
            }
        }
    }
    
    @Test("Given an entry, it persists the note in the documents directory")
    func persistsNoteWithoutRestrictedCharacters() throws {
        let entry = "my first note"
        let location = randomLocation()
        let store = try FSStore(location: location)
        try store.save(capture: entry)
        #expect(try FileManager.default.contentsOfDirectory(atPath: location.path(percentEncoded: false)).count > 0, "The note was not created")
    }
    
    @Test("Give two entries captured with same string, both exist as separate, diferent entries")
    func persistsTwoNotesWithoutOverriding() throws {
        let entry1 = "my first note"
        let entry2 = "my first note"
        let location = randomLocation()
        let store = try FSStore(location: location)
        
        try store.save(capture: entry1)
        try store.save(capture: entry2)
        let entries = try store.load()
        
        #expect(entries.count == 2, "Only \(entries.count) notes were created")
        for entry in entries {
            print("Nome do arquivo: ", entry.title)
            #expect(entry.title == "my first note", "doesn't equal title \"my first note\" ")
        }
    }
    
    @Test("Given a non-existing location, FSStore initialization throws an error")
    func throwsWhenLocationDoesNotExist() {
        let nonExisting = base.appending(path: "non-existing-\(UUID().uuidString)")
        #expect(throws: FSStore.Errors.self) {
            _ = try FSStore(location: nonExisting)
        }
    }
    
    @Test("Given files are not markdown, when loading inbox, they are ignored")
    func ignoresNotMarkdownFiles() {
        let location = randomLocation()
        let file = "arquivo-nao-markdown1"
        FileManager.default.createFile(atPath: location.appending(path: file).path(), contents: nil)
        do {
            let store = try! FSStore(location: location)
            let entries = try store.load()
            #expect(entries.isEmpty)
        }
        catch {
            print(error)
        }
        
    }
    
    func randomLocation() -> URL {
        let url = base.appending(path: UUID().uuidString)
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }
}

