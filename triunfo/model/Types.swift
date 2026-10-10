//
//  Types.swift
//  triunfo
//
//  Created by Henrique Delben on 19/09/26.
//
import Mockable
import Foundation

@Mockable
nonisolated protocol Store {
    func save(capture: String) throws -> ()
    func load() throws -> [Entry]
}


struct Entry: Equatable, Hashable {
    var title: String
    var content: String?
    var lastUpdatedDate: Date

    /*enum Kind {
        case task
        case note
    }*/
}

