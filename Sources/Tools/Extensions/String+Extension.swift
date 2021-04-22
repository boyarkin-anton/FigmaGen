//
//  String+Extension.swift
//  
//
//  Created by Anton Boyarkin on 22.04.2021.
//

import Foundation

extension String {

    func replace(_ pattern: String,
                 options: NSRegularExpression.Options = [],
                 collector: ([String]) -> String) -> String {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: options) else { return self }

        let matches = regex.matches(in: self,
                                    options: NSRegularExpression.MatchingOptions(rawValue: 0),
                                    range: NSMakeRange(0, (self as NSString).length))

        guard matches.count > 0 else { return self }

        var splitStart = startIndex

        return matches.map { (match) -> (String, [String]) in
            let range = Range(match.range, in: self)!
            let split = String(self[splitStart ..< range.lowerBound])
            splitStart = range.upperBound
            return (split, (0 ..< match.numberOfRanges)
                .compactMap { Range(match.range(at: $0), in: self) }
                .map { String(self[$0]) }
            )
        }.reduce("") { "\($0)\($1.0)\(collector($1.1))" } + self[Range(matches.last!.range, in: self)!.upperBound ..< endIndex]
    }

    func replace(_ regexPattern: String,
                 options: NSRegularExpression.Options = [],
                 collector: @escaping () -> String) -> String {
        return replace(regexPattern, options: options) { (_: [String]) in collector() }
    }

}

extension String {
    /// A Boolean value indicating whether this string is considered snake case.
    ///
    /// For example, the following strings are all snake case:
    ///
    /// - "snake_case"
    /// - "example"
    /// - "date_formatter"
    ///
    /// String can contain lowercase letters and underscores only.
    /// In snake case, words are separated by underscores.
    var isSnakeCase: Bool {
        // Strip all underscores and check if the rest is lowercase
        return self.filter{ $0 != "_" }.allSatisfy { $0.isLowercase || $0.isNumber }
    }
    
    /// A Boolean value indicating whether this string is considered lower camel case.
    ///
    /// For example, the following strings are all lower camel case:
    ///
    /// - "lowerCamelCase"
    /// - "example"
    /// - "dateFormatter"
    ///
    /// String can contain lowercase and uppercase letters only.
    /// In lower camel case, words are separated by uppercase letters.
    var isLowerCamelCase: Bool {
        // Check if the first character is lowercase and the rest contains letters
        if let firstCharacter = self.first, firstCharacter.isLowercase && self.allSatisfy({ $0.isLetter }) {
            return true
        }
        return false
    }
}

public extension String {
    /// Splits given string by variations between two characters and
    /// returns and array of strings.
    ///
    /// In this example, `lowercasedStrings` is used first to convert the names in the array
    /// to lowercase strings and then to count their characters.
    private func lowercasedStrings() -> [String] {
        var lastCharacter: Character = " "
        var results: [String] = []
        
        for character in Array<Character>(self) {
            if results.isEmpty && (character.isLetter || character.isNumber) {
                results.append(String(character))
            } else if ((lastCharacter.isLetter || lastCharacter.isNumber) && character.isLowercase) ||
                        (lastCharacter.isNumber && character.isNumber) {
                results[results.count - 1] = results[results.count - 1] + String(character)
            } else if (character.isLetter || character.isNumber) {
                results.append(String(character))
            }
            lastCharacter = character
        }
        
        return results.map { $0.capitalized }
    }
    
    /// Returns a lower camel case version of the string.
    ///
    /// Here's an example of transforming a string to lower camel case.
    ///
    ///     let event = "Keynote Event"
    ///     print(event.lowerCamelCased())
    ///     // Prints "keynoteEvent"
    ///
    /// - Returns: A lower camel case copy of the string.
    func lowerCamelCased() -> String {
        if self.isLowerCamelCase { return self }
        var strings = lowercasedStrings()
        if let firstString = strings.first {
            strings[0] = firstString.lowercased()
        }
        return strings.joined()
    }
    
    /// Returns snake case version of the string.
    ///
    /// Here's an example of transforming a string to snake case.
    ///
    ///     let event = "Keynote Event"
    ///     print(event.snakeCased())
    ///     // Prints "keynote_event"
    ///
    /// - Returns: A snake case copy of the string.
    func snakeCased() -> String {
        if self.isSnakeCase { return self }
        return lowercasedStrings().map{ $0.lowercased() }.joined(separator: "_")
    }

}
