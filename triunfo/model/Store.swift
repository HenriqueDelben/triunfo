//
//  Store.swift
//  triunfo
//
//  Created by Henrique Delben on 19/09/26.
//
import Foundation

struct FSStore: Store {
    let location: URL
    private let fileManager = FileManager.default
    private static let FRONTMATTER_REGEX = /^---\n([\s\S]*?)\n---/
    
    init(location: URL) throws {
        guard (try? location.resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true else {
            throw Errors.invalidDirectory(description: "Directory does not exist or is not a directory at \(location.path(percentEncoded: false))")
        }
        self.location = location
    }
    
    func save(capture: String) throws {
            let fileName = getFileName(from: capture)
            print("fileName set to \(fileName)")
            let metadata = createFrontmatter(for: [
                (key: "title", value: capture),
                (key: "id", value: UUID().uuidString)

            ])
        try metadata.write(to: location.appending(path: fileName).appendingPathExtension("md"), atomically: true, encoding: .utf8)
        }
    
    // TODO maybe in the future consider only loading initially the frontmatter (top of the file) in case performance hit is significant for considerable sized inbox using FileHandle
    func load() throws -> [Entry] {
        return try fileManager.contentsOfDirectory(at: location, includingPropertiesForKeys: [.contentModificationDateKey]).compactMap { fileUrl -> Entry? in
            let file = try String(contentsOf: fileUrl, encoding: .utf8)
            let frontmatter = getFrontmatter(of: file)
            guard let title = frontmatter["title"] else { return nil }
            let fileAttr = try fileUrl.resourceValues(forKeys: [.contentModificationDateKey])
            let date = fileAttr.contentModificationDate
            
            return Entry(title: title, content: withoutFrontmatter(of: file), lastUpdatedDate: date!)
        }
    }

    private func getFileName(from text: String) -> String {
        var sanitized = text
        let invalid = "\\/:"
        
        print("Sanitizing \(sanitized)")
        if sanitized.contains(where: { invalid.contains($0) }) {
            sanitized.removeAll(where: {invalid.contains($0)})
        }
        print("Santized to \(sanitized)")
        
        print("Checking if file exists at location: \(location.appending(path: sanitized).path(percentEncoded: false))")
        let exists  = fileManager.fileExists(atPath: location.appending(path: sanitized).appendingPathExtension("md").path(percentEncoded: false))
        print("File exists: \(exists)")
        guard exists else { return sanitized}
        
        return (1...).lazy
            .map() { sufix in "\(sanitized) \(sufix)"}
            .first() { candidate in
                return !fileManager.fileExists(atPath: location.appending(path: candidate).path(percentEncoded: false))
            }!
    }
    
    private func createFrontmatter(for attributes: [(key: String, value: String)]) -> String {
        var frontmatterString = "---\n"
        frontmatterString.append(attributes.map( {key, value in "\(key): \(value)"} ).joined(separator: "\n"))
        frontmatterString.append("\n---")
        return frontmatterString
    }

    private func getFrontmatter(of fileContents: String) -> [String: String] {
        var dictionary: [String: String] = [:]

        guard let match = try? FSStore.FRONTMATTER_REGEX.firstMatch(in: fileContents) else {
            return dictionary
        }

        // match.output.1 is already a Substring of the capture group — use it directly
        let innerContent = match.output.1
        innerContent.split(separator: "\n").forEach { row in
            let rowKeyValuePair = row.split(separator: ":", maxSplits: 1) // maxSplits: 1 handles values that contain ":"
            guard rowKeyValuePair.count == 2 else {
                dictionary[ String(rowKeyValuePair[0].trimmingCharacters(in: CharacterSet.whitespaces)) ] = ""
                return
            }
            let key = String(rowKeyValuePair[0]).trimmingCharacters(in: CharacterSet.whitespaces)
            let value = String(rowKeyValuePair[1]).trimmingCharacters(in: CharacterSet.whitespaces)
            dictionary[key] = value
        }

        return dictionary
    }

    private func withoutFrontmatter(of fileContents: String) -> String {
        guard let match = try? FSStore.FRONTMATTER_REGEX.firstMatch(in: fileContents) else {
            return fileContents
        }
        var result = fileContents
        result.removeSubrange(match.range)
        return result.trimmingCharacters(in: .newlines)
    }
    enum Errors: Error {
        case invalidDirectory(description: String)
    }
}

